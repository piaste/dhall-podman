let storage = "/root/servertest/storage"
let machineName = "p72"

let X = ./makeDeployment.dhall machineName storage

let redis =
      { container =
          X.container { name = "redis", repo = "library", tag = "7" }
          //  { resources = Some
                { limits = Some (toMap { cpu = "500m", memory = "8G" })
                , requests = Some (toMap { cpu = "10m" })
                }
              , args = Some
                [ "sh"
                , "-c"
                , "rm -f /data/dump.rdb && redis-server --requirepass redis --maxmemory 2048mb --maxmemory-policy volatile-ttl --save ''"
                ]
              }
      , volumes = [] : List X.VolumeDef
      }

let postgres =
      { container =
              X.container
                { name = "postgres", repo = "library", tag = "15beta4" }
          //  { env = X.envs (toMap { POSTGRES_PASSWORD = "postgres" }) }
      , volumes =
        [ X.mount.ownFolder "postgres/data" "/var/lib/postgresql/data"
        , X.mount.sharedFolder "postgres/backups" "/backups"
        ]
      }

let nextcloud =
      { container =
              X.container { name = "nextcloud", repo = "library", tag = "24" }
          //  { ports = Some [ X.k8s.ContainerPort::{ containerPort = 80 } ]
              , args = Some [ "apache2-foreground" ]
              }
      , volumes =
        [ -- mount.configFile "nextcloud/www.conf" "/usr/local/etc/php-fpm.d/www.conf"
        , X.mount.sharedFolder "nextcloud/external" "/external"
        , X.mount.ownFolder "nextcloud/internal" "/var/www/html"
        ]
      }

in X.deploy "nextcloud" [ postgres, redis, nextcloud ]
