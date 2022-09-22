let Common = ./common.dhall 
let k8s = ./gh/package.dhall sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875


let storage = "/var/home/hokmah/homeserver/storage"
let machine = "kubo"

let C = Common machine storage
let H = C.Helpers

let redis =
    { container = 
        C.container { name = "redis", repo = "library", tag = "7" } // {    
        , resources = Some
          { limits = Some (toMap { cpu = "500m", memory = "8g" })
          , requests = Some (toMap { cpu = "10m" })
          }
        , args = Some
          [ "sh"
          , "-c"
          , "rm -f /data/dump.rdb && redis-server --requirepass redis --maxmemory 2048mb --maxmemory-policy volatile-ttl --save ''"
          ]
      }
    , volumes = [] : List C.VolumeDef
    }

let postgres = 
    { container = 
        C.container { name = "postgres", repo = "library", tag = "15beta4"} // {   
      , env = H.envs (toMap { POSTGRES_PASSWORD = "postgres" })      
      }
    , volumes = [ 
          H.configFile "postgres/init.sql" "docker-entrypoint-initdb.d/init.sql"
        , H.ownFolder "postgres/data" "/var/lib/postgresql/data"
        , H.sharedFolder  "postgres/backups" "/backups"
        ]
    }
      

let nextcloud = 
    { container = 
        C.container { name = "nextcloud", repo = "library", tag = "24" } // {      
          , ports = Some [ k8s.ContainerPort::{ containerPort = 80 } ]
          , args = Some
            [ "apache2-foreground"
            ]
          }
    , volumes = [ 
      H.configFile "nextcloud/www.conf" "/usr/local/etc/php-fpm.d/www.conf"
    , H.sharedFolder  "nextcloud/external" "/external"
    , H.ownFolder "nextcloud/internal" "/var/www/html"
    ]
    }

in C.deployment "nextcloud-pod" [ postgres, redis, nextcloud ]