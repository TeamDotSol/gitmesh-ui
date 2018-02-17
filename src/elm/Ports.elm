port module Ports exposing (..)

import Json.Decode exposing (Value)


port ipfsCat : String -> Cmd msg


port ipfsCatData : (String -> msg) -> Sub msg


port ipfsList : String -> Cmd msg


port ipfsListData : (Value -> msg) -> Sub msg
