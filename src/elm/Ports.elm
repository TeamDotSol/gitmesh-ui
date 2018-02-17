port module Ports exposing (..)

import Json.Decode exposing (Value)


port error : (String -> msg) -> Sub msg


port ipfsCat : String -> Cmd msg


port ipfsCatData : (String -> msg) -> Sub msg


port ipfsList : String -> Cmd msg


port ipfsListData : (Value -> msg) -> Sub msg
