port module Ports exposing (..)


port ipfsCat : String -> Cmd msg


port ipfsData : (String -> msg) -> Sub msg
