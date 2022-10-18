let storage = "/root/servertest/storage"
let machineName = "p72"

let X = ./makeDeployment.dhall
let D = X.initDeployment machineName storage

let redis =
      { container =
          D.container { name = "redis", repo = "library", tag = "7" }
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
      , volumes = [] : List X.Volume
      }

let postgres =
      { container =
            D.container
                { name = "postgres", repo = "library", tag = "15beta4" }
          //  { env = X.envs (toMap { POSTGRES_PASSWORD = "postgres" }) }
      , volumes =
        [ D.mount.own "postgres/data" "/var/lib/postgresql/data"
        , D.mount.shared "postgres/backups" "/backups"
        ]
      }

let nextcloud =
      { container =
              D.container { name = "nextcloud", repo = "library", tag = "24" }
          //  { ports = Some [ X.k8s.ContainerPort::{ containerPort = 80, hostPort = Some 8000 } ]
              , args = Some [ "apache2-foreground" ]
              , name = "nextcloud-server"
              }
      , volumes =
        [ -- mount.readFile "nextcloud/www.conf" "/usr/local/etc/php-fpm.d/www.conf"
        , D.mount.shared "nextcloud/external" "/external"
        , D.mount.own "nextcloud/internal" "/var/www/html"
        ]
      }

in 
      D.deploy "nextcloud" [ postgres, redis, nextcloud ]
