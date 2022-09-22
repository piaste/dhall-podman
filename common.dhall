let k8s =
      ./gh/package.dhall
        sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875

let P =
      https://prelude.dhall-lang.org/package.dhall
      --https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/package.dhall

let kv = P.Map.keyValue Text


let KV = { mapKey : Text, mapValue : Text }

let V =
      { notes : KV
      , volume : k8s.Volume.Type
      , volumeMount : k8s.VolumeMount.Type
      }

let S = { container : k8s.Container.Type, volumes : List V }

let envs =
      \(x : List KV) ->
        let f =
              \(kv : KV) ->
                k8s.EnvVar::{ name = kv.mapKey, value = Some kv.mapValue }

        in  Some (P.List.map KV k8s.EnvVar.Type f x)

let defaultNotes = 
  \(machine : Text) ->
      (P.List.concatMap
        S
        KV
        ( \(service : S) ->
            let serviceName = service.container.name

            in  [ kv
                    "io.podman.annotations.autoremove/${machine}${serviceName}"
                    "FALSE"
                , kv
                    "io.podman.annotations.init/${machine}${serviceName}"
                    "FALSE"
                , kv
                    "io.podman.annotations.privileged/${machine}${serviceName}"
                    "FALSE"
                , kv
                    "io.podman.annotations.publish-all/${machine}${serviceName}"
                    "FALSE"
                , kv "io.kubernetes.cri-o.TTY/${machine}${serviceName}" "false"
                ]
        )
      )

let PathType = < File | Directory >

let PathShareType = < Shared | Private >

let fileMap =
      \(readOnly : Bool) ->
      \(pathType : PathType) ->
      \(pathShareType : PathShareType) ->

      \(storage : Text) ->
      \(hostPath : Text) ->
      \(containerPath : Text) ->
        let name =
                  Text/replace "/" "-" hostPath
              ++  Text/replace "/" "-" containerPath

        let private = kv "bind-mount-options:${storage}/${hostPath}" "z"

        let shared = kv "bind-mount-options:${storage}/${hostPath}" "Z"

        in  { notes = merge { Shared = shared, Private = private } pathShareType
            , volume = k8s.Volume::{
              , hostPath = Some
                { path = "${storage}${hostPath}"
                , type = Some
                    (merge { File = "File", Directory = "Directory" } pathType)
                }
              , name
              , persistentVolumeClaim = Some
                { claimName = "", readOnly = Some readOnly }
              }
            , volumeMount = k8s.VolumeMount::{
              , mountPath = containerPath
              , name
              , readOnly = Some readOnly
              }
            }

let configFile = fileMap True PathType.File PathShareType.Shared

let accessFolder = fileMap True PathType.Directory PathShareType.Shared

let ownFolder = fileMap False PathType.Directory PathShareType.Private

let sharedFolder = fileMap False PathType.Directory PathShareType.Shared

let mount =
      \(vs : List V) ->
        Some (P.List.map V k8s.VolumeMount.Type (\(v : V) -> v.volumeMount) vs)

let mountVolumes =
      \(ss : List S) ->
        Some
          ( P.List.map
              V
              k8s.Volume.Type
              (\(v : V) -> v.volume)
              (P.List.concatMap S V (\(s : S) -> s.volumes) ss)
          )

let mountNotes = P.List.concatMap S KV (\(s : S) -> P.List.map V KV (\(v : V) -> v.notes) s.volumes)

let baseContainer =
      \(image : { repo : Text, name : Text, tag : Text }) ->
        k8s.Container::{
        , name = "${image.name}"
        , image = Some "docker.io/${image.repo}/${image.name}:${image.tag}"
        , securityContext = Some k8s.SecurityContext::{
          , capabilities = Some
            { add = None (List Text)
            , drop = Some [ "CAP_MKNOD", "CAP_NET_RAW", "CAP_AUDIT_WRITE" ]
            }
          }
        }

let baseDeployment =
      \(machine : Text) ->
      \(podName : Text) ->
      \(services : List S) ->
        k8s.Deployment::{
        , apiVersion = "v1"
        , kind = "Pod"
        , metadata = k8s.ObjectMeta::{
          , name = Some "${machine}${podName}"
          , labels = Some (toMap { app = "${machine}${podName}" })
          , annotations = Some
              ( P.List.concat
                  KV
                  [ mountNotes services
                  , defaultNotes machine services
                  ]
              )
          }
        , spec = Some k8s.DeploymentSpec::{
          , replicas = Some 1
          , revisionHistoryLimit = Some 5
          , selector = k8s.LabelSelector::{
            , matchLabels = Some (toMap { app = podName })
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
              , name = Some podName
              , labels = Some (toMap { app = podName })
              }
            , spec = Some k8s.PodSpec::{
              , containers = P.List.map S k8s.Container.Type (\(s : S) -> s.container) services
              , volumes = mountVolumes services
              }
            }
          }
        }

let H = 
    (\(storage : Text) -> 
      { configFile = configFile storage
      , accessFolder = accessFolder storage
      , ownFolder = ownFolder storage
      , sharedFolder = sharedFolder storage
      , envs 
      })

in  \(machine : Text) -> \(storage : Text) -> 
    { container = baseContainer
    , deployment = baseDeployment machine
    , Helpers = H storage
    , VolumeDef = V
    }
