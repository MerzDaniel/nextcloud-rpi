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
borg create        \
  --stats          \
  --exclude-caches \
  rsync:borg::nextcloud-$d              \
  /home/docker/git/nextcloud-rpi/.env   \
  /mnt/data/cloud/./db_dump             \
  /mnt/data/cloud/./nextcloud/config    \
  /mnt/data/cloud/./nextcloud/data


echo Activate Nextcloud maintenance mode...
docker-compose exec -u www-data app php occ maintenance:mode --off

)
