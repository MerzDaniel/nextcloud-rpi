# Nextcloud docker

## Nextcloud config
Trusted domains:
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'cloud.danielmerz.de',
  ),

Also set (if behind apache proxy)
  'overwrite.cli.url' => 'https://cloud.danielmerz.de',
  'overwrite.host' => 'cloud.danielmerz.de',
  'overwrite.protocol' => 'https',
- 
