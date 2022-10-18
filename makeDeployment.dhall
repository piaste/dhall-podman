-- Imports
let k8s = ./gh/package.dhall sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875

let map      = https://prelude.dhall-lang.org/List/map
let concat   = https://prelude.dhall-lang.org/List/concat
let flatMap  = https://prelude.dhall-lang.org/List/concatMap
let keyValue = https://prelude.dhall-lang.org/Map/keyValue Text
let KV     = { mapKey : Text, mapValue : Text }

-- Custom types

let Volume =
      { notes : KV
      , volume : k8s.Volume.Type
      , volumeMount : k8s.VolumeMount.Type
      }

let Service = { container : k8s.Container.Type, volumes : List Volume }

let PathType = < File | Directory >

let PathShareType = < Shared | Private >

let Network = { name : Text, internal : Bool }

-- Basic helpers

let fromServices = 
      \(T : Type) ->
      \(selector: (Service -> List T)) ->
      \(ss : List Service) ->
      
        flatMap Service T selector ss

let envs =
      \(vars : List KV) ->
        let toEnvVar =
              \(kv : KV) -> k8s.EnvVar::{ name = kv.mapKey, value = Some kv.mapValue }

        in  Some (map KV k8s.EnvVar.Type toEnvVar vars)

let defaultNotes =
      fromServices
        KV
        ( \(service : Service) ->
            let serviceName = service.container.name

            in  [ keyValue "io.podman.annotations.autoremove/${serviceName}" "FALSE"
                , keyValue "io.podman.annotations.init/${serviceName}" "FALSE"
                , keyValue "io.podman.annotations.privileged/${serviceName}" "FALSE"
                , keyValue "io.podman.annotations.publish-all/${serviceName}" "FALSE"
                , keyValue "io.kubernetes.cri-o.TTY/${serviceName}" "false"
                ]
        )

-- Storage helpers

let storageMount =
      \(readOnly : Bool) ->
      \(pathType : PathType) ->
      \(pathShareType : PathShareType) ->
      \(storage : Text) ->
      \(hostPath : Text) ->
      \(containerPath : Text) ->
        let name =
                  Text/replace "/" "-" hostPath
              ++  "--"
              ++  Text/replace "/" "-" containerPath

        let bindMountOptions = 
            keyValue "bind-mount-options:${storage}/${hostPath}" (merge { Shared = "Z", Private = "z" } pathShareType)
            
        let hostPath = 
            { path = "${storage}/${hostPath}"
            , type = Some ( merge { File = "File", Directory = "DirectoryOrCreate" } pathType )
            }

        in  { notes = bindMountOptions
            , volume = k8s.Volume::{
              , hostPath = Some hostPath
              , name
              , persistentVolumeClaim = None k8s.PersistentVolumeClaimVolumeSource.Type
              }
            , volumeMount = k8s.VolumeMount::{
              , mountPath = containerPath
              , name
              , readOnly = Some readOnly
              }
            }

let readFile = storageMount True  PathType.File      PathShareType.Shared
let read     = storageMount True  PathType.Directory PathShareType.Shared
let shared   = storageMount False PathType.Directory PathShareType.Shared
let own      = storageMount False PathType.Directory PathShareType.Private
let ownFile  = storageMount False PathType.File      PathShareType.Private

let mount =
      \(vs : List Volume) ->
        Some (map Volume k8s.VolumeMount.Type (\(v : Volume) -> v.volumeMount) vs)

let mountVolumes =
      \(ss : List Service) ->
        let volumes = (fromServices Volume (\(s : Service) -> s.volumes) ss)
        in Some
            ( map Volume k8s.Volume.Type (\(v : Volume) -> v.volume) volumes )

let mountNotes =
    fromServices KV
      (\(s : Service) -> map Volume KV (\(v : Volume) -> v.notes) s.volumes)


-- Service helpers

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
      \(services : List Service) ->

        let deploymentName = "${machine}-${podName}-deployment"

        in k8s.Deployment::{
            , apiVersion = "v1"
            , kind = "Deployment"
            , metadata = k8s.ObjectMeta::{
              , name = Some deploymentName
              , labels = Some (toMap { app = podName })
              , annotations = Some
                  ( concat KV
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
                      map Service k8s.Container.Type
                        (\(s : Service) -> s.container)
                        services
                  , volumes = mountVolumes services
                  }
                }
              }
            }

-- Network management

let createNetwork = 
  \(network: Network) -> 
      "podman network create " ++ (if network.internal then " --internal " else " ") ++ network.name

-- Final export

in  { 
      initDeployment = 
          \(machineName : Text) ->
          \(storage : Text) ->
          { container = baseContainer
          , deploy = baseDeployment machineName
          , mount = 
              { readFile = readFile storage
              , read = read storage
              , own = own storage
              , shared = shared storage        
              }
          }

    -- exported helpers

    , k8s
    , envs
    , Volume
    , createNetwork
    }
