let H = ./00.helpers.dhall 

let storage = "/home/hokmah//servertest/storage"
let machineName = "p72"

let S = ./01.services.dhall machineName storage

let networks =
  { internal = { name = "foo", internal = True } 
  , external = { name = "bar", internal = False } 
  }


in
[ 
      S.Deploy "internal" [ networks.internal ]
        [ S.redis, S.postgres ]

    , S.Deploy "external" [ networks.external ]
        [ S.nextcloud ]
]
