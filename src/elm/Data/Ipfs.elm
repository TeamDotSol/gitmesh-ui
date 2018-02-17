module Data.Ipfs exposing (..)

import Json.Decode as Decode


type IpfsType
    = File
    | Directory


type alias IpfsObject =
    { depth : Int
    , name : String
    , path : String
    , size : Int
    , hash : String
    , nodeType : IpfsType
    }


decodeIpfsObject : Decode.Decoder IpfsObject
decodeIpfsObject =
    let
        decodeType : String -> Decode.Decoder IpfsType
        decodeType raw =
            case raw of
                "file" ->
                    Decode.succeed File

                "dir" ->
                    Decode.succeed Directory

                _ ->
                    Decode.fail "unknown ipfs object type"
    in
        Decode.map6 IpfsObject
            (Decode.field "depth" Decode.int)
            (Decode.field "name" Decode.string)
            (Decode.field "path" Decode.string)
            (Decode.field "size" Decode.int)
            (Decode.field "hash" Decode.string)
            (Decode.field "type" (Decode.string |> Decode.andThen decodeType))


decodeIpfsList : Decode.Value -> Result String (List IpfsObject)
decodeIpfsList =
    Decode.decodeValue <| Decode.list decodeIpfsObject
