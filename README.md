# Nextcloud docker

Nextcloud docker configuration for my setup.

## Nextcloud config 
(the default configuration should take care of this now)

Trusted domains:
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'your.domain.foo',
  ),

Also set (if behind apache proxy)
  'overwrite.cli.url' => 'https://your.domain.foo',
  'overwrite.host' => 'your.domain.foo',
  'overwrite.protocol' => 'https',
- 
