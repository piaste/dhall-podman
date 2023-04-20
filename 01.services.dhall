let H = ./00.helpers.dhall 

let limitedResources = Some { limits = Some (toMap { cpu = "500m", memory = "8G" }), requests = Some (toMap { cpu = "10m" }) }

in

\(machineName2 : Text) -> 
\(storage2 : Text) -> 

  let D = H.initDeployment machineName2 storage2
  in

  { redis =
        { container =
            D.container (H.Image::{ name = "redis", tag = "7" })
            //  { resources = limitedResources
                , args = Some
                  [ "sh"
                  , "-c"
                  , "rm -f /data/dump.rdb && redis-server --requirepass redis --maxmemory 2048mb --maxmemory-policy volatile-ttl --save ''"
                  ]
                }
        , volumes = [] : List H.Volume
        }

  , postgres =
        { container =
              D.container (H.Image::{ name = "postgres", tag = "15" })
            //  { env = H.envs (toMap { POSTGRES_PASSWORD = "postgres" }) }
        , volumes =
          [ D.mount.own "postgres/data" "/var/lib/postgresql/data"
          , D.mount.shared "postgres/backups" "/backups"
          ]
        }

  , nextcloud =
        { container =
                D.container (H.Image::{ name = "nextcloud", tag = "24" })
            //  { ports = Some [ H.k8s.ContainerPort::{ containerPort = 80, hostPort = Some 8000 } ]
                , args = Some [ "apache2-foreground" ]
                , name = "nextcloud-server"
                }
        , volumes =
          [ -- mount.readFile "nextcloud/www.conf" "/usr/local/etc/php-fpm.d/www.conf"
          , D.mount.shared "nextcloud/external" "/external"
          , D.mount.own "nextcloud/internal" "/var/www/html"
          ]
        }

  , Deploy = D.deploy
  }
