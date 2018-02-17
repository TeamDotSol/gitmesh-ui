port module Ports exposing (..)

import Json.Decode exposing (Value)


port ipfsList : String -> Cmd msg


port ipfsListData : (Value -> msg) -> Sub msg
