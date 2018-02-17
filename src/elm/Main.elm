module Main exposing (..)

import Element exposing (..)
import Html exposing (Html)
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
    , data : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { ipfsHash = Nothing
      , data = Nothing
      }
    , Cmd.batch
        [ Ports.ipfsCat "QmWwdX8shph24fZw3Rtyr3ucobmBQEzqoW8YrnNgUf6H4J"
        ]
    )


type Msg
    = IPFSData String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IPFSData data ->
            { model | data = Just data } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.ipfsData IPFSData
        ]


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
