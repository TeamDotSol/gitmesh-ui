module Main exposing (..)

import Element exposing (..)
import Html exposing (Html)
import Json.Decode as Decode
import Ports
import Style exposing (..)
import Style.Border as Border


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { ipfsHash : Maybe String
    , data : Maybe (List IpfsObject)
    }


init : ( Model, Cmd Msg )
init =
    ( { ipfsHash = Nothing
      , data = Nothing
      }
    , Cmd.batch
        [ Ports.ipfsList "QmaQZJXMyAcakZrgEmAKdwpMa5V9uzNL1vwZnchUHzbSR5"
        ]
    )


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


type Msg
    = IpfsList (Result String (List IpfsObject))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IpfsList (Ok result) ->
            { model | data = Just result } ! []

        _ ->
            model ! []


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


decodeListResult : Decode.Value -> Result String (List IpfsObject)
decodeListResult =
    Decode.decodeValue <| Decode.list decodeIpfsObject


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.ipfsListData (decodeListResult >> IpfsList)


type Style
    = View


styleSheet : StyleSheet Style variation
styleSheet =
    Style.styleSheet
        [ style View [ Border.all 1.0, Border.solid ]
        ]


view : Model -> Html Msg
view model =
    Element.viewport styleSheet <|
        el View [] <|
            text (toString model)
