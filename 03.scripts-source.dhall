let H = ./00.helpers.dhall 
let L = ./02.layout.dhall

let networkScripts = H.flatMap H.DeploymentUnit Text (\(u: H.DeploymentUnit) -> u.networkCreationScripts) L

let createPodScript = 
    \(u: H.DeploymentUnit) -> 
        let fileName = "${u.name}.yml"
        let args = H.map Text Text (\(n: Text) -> "--network=${n}") u.networkNames
        
        in "podman kube play ${fileName} ${H.textConcatSep " " args}"
    

let podScripts = 
    H.map H.DeploymentUnit Text createPodScript L
    


in H.textConcatSep "\n" (H.concat Text [networkScripts, podScripts])