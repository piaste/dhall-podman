let k8s =
      ./gh/package.dhall
        sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875

let P = https://prelude.dhall-lang.org/package.dhall

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
      P.List.concatMap
        S
        KV
        ( \(service : S) ->
            let serviceName = service.container.name

            in  [ kv "io.podman.annotations.autoremove/${serviceName}" "FALSE"
                , kv "io.podman.annotations.init/${serviceName}" "FALSE"
                , kv "io.podman.annotations.privileged/${serviceName}" "FALSE"
                , kv "io.podman.annotations.publish-all/${serviceName}" "FALSE"
                , kv "io.kubernetes.cri-o.TTY/${serviceName}" "false"
                ]
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
              ++  "___"
              ++  Text/replace "/" "-" containerPath

        let private = kv "bind-mount-options:${storage}/${hostPath}" "z"

        let shared = kv "bind-mount-options:${storage}/${hostPath}" "Z"

        in  { notes = merge { Shared = shared, Private = private } pathShareType
            , volume = k8s.Volume::{
              , hostPath = Some
                { path = "${storage}/${hostPath}"
                , type = Some
                    ( merge
                        { File = "File", Directory = "DirectoryOrCreate" }
                        pathType
                    )
                }
              , name
              , persistentVolumeClaim =
                  None k8s.PersistentVolumeClaimVolumeSource.Type
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

let mountNotes =
      P.List.concatMap
        S
        KV
        (\(s : S) -> P.List.map V KV (\(v : V) -> v.notes) s.volumes)

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
        let deploymentName = "${machine}-${podName}-deployment"

        in  k8s.Deployment::{
            , apiVersion = "v1"
            , kind = "Deployment"
            , metadata = k8s.ObjectMeta::{
              , name = Some deploymentName
              , labels = Some (toMap { app = podName })
              , annotations = Some
                  ( P.List.concat
                      KV
                      [ mountNotes services, defaultNotes services ]
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
                  , containers =
                      P.List.map
                        S
                        k8s.Container.Type
                        (\(s : S) -> s.container)
                        services
                  , volumes = mountVolumes services
                  }
                }
              }
            }

let H =
      \(storage : Text) ->
        { configFile = configFile storage
        , accessFolder = accessFolder storage
        , ownFolder = ownFolder storage
        , sharedFolder = sharedFolder storage        
        }

let Network = { name : Text, internal : Bool }

let createNetwork = 
  \(network: Network) -> 
      "podman network create " ++ (if network.internal then " --internal " else " ") ++ network.name

in  { 
      initDeployment = 
          \(machineName : Text) ->
          \(storage : Text) ->
          { container = baseContainer
          , deploy = baseDeployment machineName
          , mount = H storage
          }

      , createNetwork
      , VolumeDef = V
      , k8s
      , envs
      }
