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

let KV = { mapKey : Text, mapValue : Text }

let envs = \(x : List KV) -> 
  let f = \(kv : KV) -> k8s.EnvVar::{ name = kv.mapKey, value = Some kv.mapValue } in
  Some (Prelude.List.map KV k8s.EnvVar.Type f x)

let defaultNotes = 
  Prelude.List.concatMap Text KV (\(serviceName : Text) ->   
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
let PathShareType = < Shared | Private >

let V = { notes : KV, volume : k8s.Volume.Type, volumeMount : k8s.VolumeMount.Type }

let fileMap = \(readOnly : Bool) -> \(pathType : PathType) -> \(pathShareType : PathShareType) -> \(hostPath : Text) -> \(containerPath: Text) ->
  let name = 
    Text/replace "/" "-" hostPath ++
    Text/replace "/" "-" containerPath
  in 
    { 
      notes = merge { Shared = shared hostPath, Private = private hostPath } pathShareType
    , volume = 
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

let configFile = fileMap True PathType.File PathShareType.Shared
let accessFolder = fileMap True PathType.Directory PathShareType.Shared
let ownFolder = fileMap False PathType.Directory PathShareType.Private
let sharedFolder = fileMap False PathType.Directory PathShareType.Shared

let mount = \(vs : List V) -> Some (Prelude.List.map V k8s.VolumeMount.Type (\(v : V) -> v.volumeMount) vs)
let mountVolumes = \(vs : List V) -> Some (Prelude.List.map V k8s.Volume.Type (\(v : V) -> v.volume) vs)
let mountNotes = \(vs : List V) -> (Prelude.List.map V KV (\(v : V) -> v.notes) vs)


let nextcloudVolumes = 
    [ 
      configFile "/nextcloud/www.conf" "/usr/local/etc/php-fpm.d/www.conf"
    , sharedFolder  "/nextcloud/external" "/external"
    , ownFolder "/nextcloud/internal" "/var/www/html"
    ]

let postgresVolumes = 
    [ 
      configFile "/postgres/init.sql" "docker-entrypoint-initdb.d/init.sql"
    , ownFolder "/postgres/data" "/var/lib/postgresql/data"
    , sharedFolder  "/postgres/backups" "/backups"
    ]

let baseContainer =     
    \(image : { repo : Text, name : Text, tag : Text}) -> k8s.Container::{      
      name = "${machine}_${image.name}"
    , image = Some "docker.io/${image.repo}/${image.name}:${image.tag}"
    , securityContext= Some (k8s.SecurityContext::{ capabilities = Some { add = None (List Text), drop = Some [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]}})
    }

let redis =
    baseContainer { name = "redis", repo = "library", tag = "7" } // {        
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
    }

let postgres = 
    baseContainer { name = "postgres", repo = "library", tag = "15beta4"} // {   
      , env = envs (toMap { POSTGRES_PASSWORD = "postgres" })
      , volumeMounts = mount postgresVolumes
      }
      

let nextcloud = 
    baseContainer { name = "nextcloud", repo = "library", tag = "24" } // {      
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
      , volumeMounts =
          mount nextcloudVolumes
      }

let podName = "nextcloud-pod"

in  k8s.Deployment::{
    , apiVersion = "v1"
    , kind = "Pod"
    , metadata = k8s.ObjectMeta::{
      , annotations = Some
        (Prelude.List.concat { mapKey : Text, mapValue : Text }
          [ 
              mountNotes postgresVolumes
            , mountNotes nextcloudVolumes            
            , defaultNotes [ "nextcloud1", "postgres1", "redis1" ]
          ]
        )
      , creationTimestamp = Some "2022-09-09T15:41:53Z"
      , labels = Some (toMap { app = "${machine}${podName}" })
      , name = Some "${machine}${podName}"
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
    
    
