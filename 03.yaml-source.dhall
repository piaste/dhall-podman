let H = ./00.helpers.dhall 

in H.map H.DeploymentUnit H.k8s.Deployment.Type (\(u: H.DeploymentUnit) -> u.pod) ./02.layout.dhall 