#!/bin/bash
set -e 

(
echo Starting backup...
. ./.env
d=$(date +%F_%H%M%S)

echo Activate Nextcloud maintenance mode...
docker-compose exec -u www-data app php occ maintenance:mode --on

echo Dumping DB...
docker compose exec db mysqldump --single-transaction -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE | sudo tee /mnt/data/cloud/db_dump > /dev/null

set +e

echo Creating backup... THIS MAY TAKE FOR AGES!
export BORG_PASSPHRASE
borg create        \
  --show-rc        \
  --stats          \
  --exclude-caches \
  rsync:borg::nextcloud-$d              \
  /home/docker/git/nextcloud-rpi/.env   \
  /mnt/data/cloud/./db_dump             \
  /mnt/data/cloud/./nextcloud/config    \
  /mnt/data/cloud/./nextcloud/data
backup_exit=$?

echo Deactivate Nextcloud maintenance mode...
docker-compose exec -u www-data app php occ maintenance:mode --off

echo Prune backups...
borg prune \
  --show-rc                     \
  --progress                    \
  --glob-archives 'nextcloud-*' \
  --keep-daily=7                \
  --keep-weekly=4               \
  --keep-monthly=12             \
  --keep-yearly=2               \
  rsync:borg
prune_exit=$?

echo Compact backups...
borg compact rsync:borg
compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    echo "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    echo "Backup, Prune, and/or Compact finished with warnings"
else
    echo "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}

)
