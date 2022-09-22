let k8s =
      ./gh/package.dhall
        sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875

let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/package.dhall

let storage = "/var/home/hokmah/homeserver/storage"

let kv = Prelude.Map.keyValue Text

let machine = "kubo"

let foo =
    
    
                    {- 
                     
                    , env = None (List { name : Text, value : Text })
                    , image = "docker.io/library/redis:7"
                    , name = "${machine}redis1"
                    , ports = None (List { containerPort : Natural, hostPort : Natural })
                    , securityContext.capabilities.drop
                      =
                      [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]
                    , volumeMounts =
                      [ { mountPath = "/data"
                        , name =
                            "957a97b635f12d60c8319129bd8ff3dc5d5b3dce108b51a7af1128cb9e51b677-pvc"
                        , readOnly = None Bool
                        }
                      ]
                    -}      
    {-
          , containers =
            [ { args =
                [ "sh"
                , "-c"
                , "rm -f /data/dump.rdb && redis-server --requirepass redis --maxmemory 2048mb --maxmemory-policy volatile-ttl --save ''"
                ]
              , env = None (List { name : Text, value : Text })
              , image = "docker.io/library/redis:7"
              , name = "${machine}redis1"
              , ports = None (List { containerPort : Natural, hostPort : Natural })
              , securityContext.capabilities.drop
                =
                [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]
              , volumeMounts =
                [ { mountPath = "/data"
                  , name =
                      "957a97b635f12d60c8319129bd8ff3dc5d5b3dce108b51a7af1128cb9e51b677-pvc"
                  , readOnly = None Bool
                  }
                ]
              }
            , { args = [ "postgres" ]
              , env = Some
                [ { name = "POSTGRES_PASSWORD", value = "postgres" }
                , { name = "POSTGRES_USER", value = "postgres" }
                , { name = "POSTGRES_DB", value = "postgres" }
                ]
              , image = "docker.io/library/postgres:15beta3"
              , name = "${machine}postgres1"
              , ports = None (List { containerPort : Natural, hostPort : Natural })
              , securityContext.capabilities.drop
                =
                [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]
              , volumeMounts =
                [ { mountPath = "/docker-entrypoint-initdb.d/init.sql"
                  , name =
                      "var-home-hokmah-homeserver-storage-postgres-init.sql-host-0"
                  , readOnly = Some True
                  }
                , { mountPath = "/var/lib/postgresql/data"
                  , name = "var-home-hokmah-homeserver-storage-postgres-data-host-1"
                  , readOnly = None Bool
                  }
                , { mountPath = "/backups"
                  , name = "var-home-hokmah-homeserver-storage-postgres-host-2"
                  , readOnly = None Bool
                  }
                ]
              }
            , { args = [ "apache2-foreground" ]
              , env = Some
                [ { name = "POSTGRES_PASSWORD", value = "nextcloud" }
                , { name = "POSTGRES_DB", value = "nextcloud" }
                , { name = "POSTGRES_HOST", value = "postgres" }
                , { name = "NEXTCLOUD_TRUSTED_DOMAINS"
                  , value = "piaste.com piaste.it"
                  }
                , { name = "REDIS_HOST", value = "redis" }
                , { name = "REDIS_HOST_PASSWORD", value = "redis" }
                , { name = "POSTGRES_USER", value = "nextcloud" }
                ]
              , image = "docker.io/library/nextcloud:latest"
              , name = "${machine}nextcloud1"
              , ports = Some [ { containerPort = 80, hostPort = 25003 } ]
              , securityContext.capabilities.drop
                =
                [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]
              , volumeMounts =
                [ { mountPath = "/usr/local/etc/php-fpm.d/www.conf"
                  , name =
                      "var-home-hokmah-homeserver-storage-nextcloud-www.conf-host-0"
                  , readOnly = Some True
                  }
                , { mountPath = "/var/www/html"
                  , name =
                      "var-home-hokmah-homeserver-storage-nextcloud-internal-host-1"
                  , readOnly = None Bool
                  }
                , { mountPath = "/external"
                  , name =
                      "var-home-hokmah-homeserver-storage-nextcloud-external-host-2"
                  , readOnly = None Bool
                  }
                ]
              }
            ]
          , volumes =
            [ { hostPath = None { path : Text, type : Text }
              , name =
                  "957a97b635f12d60c8319129bd8ff3dc5d5b3dce108b51a7af1128cb9e51b677-pvc"
              , persistentVolumeClaim = Some
                { claimName =
                    "957a97b635f12d60c8319129bd8ff3dc5d5b3dce108b51a7af1128cb9e51b677"
                }
              }
            , { hostPath = Some
                { path = "${storage}/postgres/init.sql"
                , type = "File"
                }
              , name = "var-home-hokmah-homeserver-storage-postgres-init.sql-host-0"
              , persistentVolumeClaim = None { claimName : Text }
              }
            , { hostPath = Some
                { path = "${storage}/postgres/data"
                , type = "Directory"
                }
              , name = "var-home-hokmah-homeserver-storage-postgres-data-host-1"
              , persistentVolumeClaim = None { claimName : Text }
              }
            , { hostPath = Some
                { path = "${storage}/postgres"
                , type = "Directory"
                }
              , name = "var-home-hokmah-homeserver-storage-postgres-host-2"
              , persistentVolumeClaim = None { claimName : Text }
              }
            , { hostPath = Some
                { path = "${storage}/nextcloud/www.conf"
                , type = "File"
                }
              , name =
                  "var-home-hokmah-homeserver-storage-nextcloud-www.conf-host-0"
              , persistentVolumeClaim = None { claimName : Text }
              }
            , { hostPath = Some
                { path = "${storage}/nextcloud/internal"
                , type = "Directory"
                }
              , name =
                  "var-home-hokmah-homeserver-storage-nextcloud-internal-host-1"
              , persistentVolumeClaim = None { claimName : Text }
              }
            , { hostPath = Some
                { path = "${storage}/nextcloud/external"
                , type = "Directory"
                }
              , name =
                  "var-home-hokmah-homeserver-storage-nextcloud-external-host-2"
              , persistentVolumeClaim = None { claimName : Text }
              }
            ]
          }
        }
    -}
      {=}

let defaultNotes = 
  Prelude.List.concatMap Text { mapKey : Text, mapValue : Text } (\(serviceName : Text) ->   
    [     
        kv "io.podman.annotations.autoremove/${machine}${serviceName}" "FALSE"
      , kv "io.podman.annotations.init/${machine}${serviceName}" "FALSE"
      , kv "io.podman.annotations.privileged/${machine}${serviceName}" "FALSE"
      , kv "io.podman.annotations.publish-all/${machine}${serviceName}" "FALSE"        
      , kv "io.kubernetes.cri-o.TTY/${machine}${serviceName}" "false"
    ]
  )

let private = \(hostPath : Text) -> kv "bind-mount-options:${storage}/${hostPath}" "z"
let shared  = \(hostPath : Text) -> kv "bind-mount-options:${storage}/${hostPath}" "Z"

let PathType = < File | Directory >

let fileMap = \(readOnly : Bool) -> \(pathType : PathType) -> \(hostPath : Text) -> \(containerPath: Text) ->
  let name = 
    Text/replace "/" "-" hostPath ++
    Text/replace "/" "-" containerPath
  in 
    { 
      volume = 
        k8s.Volume::{ hostPath = Some
          { path = "${storage}${hostPath}"
          , type = Some (merge { File = "File", Directory = "Directory" } pathType)
          }
        , name = name
        , persistentVolumeClaim = Some { claimName = "", readOnly = Some readOnly }
        }
    , volumeMount = 
        k8s.VolumeMount::
          { mountPath = containerPath
          , name = name
          , readOnly = Some readOnly
          }
    }

let volumeRO = fileMap True
let volumeRW = fileMap False


let redis = 
    k8s.Container::{
      , name = "${machine}redis1"
      , image = Some "docker.io/library/redis:7"
      , ports = Some [ k8s.ContainerPort::{ containerPort = 80 } ]
      , resources = Some
        { limits = Some (toMap { cpu = "500m" })
        , requests = Some (toMap { cpu = "10m" })
        }
      , args = Some
        [ "sh"
        , "-c"
        , "rm -f /data/dump.rdb && redis-server --requirepass redis --maxmemory 2048mb --maxmemory-policy volatile-ttl --save ''"
        ]
      , securityContext= Some (k8s.SecurityContext::{ capabilities = Some { add = None (List Text), drop = Some [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]}})
      , volumeMounts =
                Some [ k8s.VolumeMount::{ mountPath = "/docker-entrypoint-initdb.d/init.sql"
                  , name =
                      "var-home-hokmah-homeserver-storage-postgres-init.sql-host-0"
                  , readOnly = Some True
                  }
                , k8s.VolumeMount::{ mountPath = "/var/lib/postgresql/data"
                  , name = "var-home-hokmah-homeserver-storage-postgres-data-host-1"
                  }
                , k8s.VolumeMount::{ mountPath = "/backups"
                  , name = "var-home-hokmah-homeserver-storage-postgres-host-2"
                  }
                ]
      }
      

in  k8s.Deployment::{
    , apiVersion = "v1"
    , kind = "Pod"
    , metadata = k8s.ObjectMeta::{
      , annotations = Some
        (Prelude.List.concat { mapKey : Text, mapValue : Text }
          [ 
            [ private "nextcloud/external"
            , private "nextcloud/internal"
            , private "nextcloud/www.conf"
            , shared "postgres"
            , private "postgres/data"
            , private "postgres/init.sql"
            ]
            , defaultNotes [ "nextcloud1", "postgres1", "redis1" ]
          ]
        )
      , creationTimestamp = Some "2022-09-09T15:41:53Z"
      , labels = Some (toMap { app = "${machine}redis1-pod" })
      , name = Some "${machine}redis1-pod"
      }
    , spec = Some k8s.DeploymentSpec::{
      , replicas = Some 2
      , revisionHistoryLimit = Some 10
      , selector = k8s.LabelSelector::{
        , matchLabels = Some (toMap { app = "nextcloud" })
        }
      , strategy = Some k8s.DeploymentStrategy::{
        , type = Some "RollingUpdate"
        , rollingUpdate = Some
          { maxSurge = Some (k8s.NatOrString.Nat 5)
          , maxUnavailable = Some (k8s.NatOrString.Nat 0)
          }
        }
      , template = k8s.PodTemplateSpec::{
        , metadata = Some k8s.ObjectMeta::{
          , name = Some "nginx"
          , labels = Some (toMap { app = "nginx" })
          }
        , spec = Some k8s.PodSpec::{
          , containers =
            [ redis
            ]
          }
        }
      }
    }
