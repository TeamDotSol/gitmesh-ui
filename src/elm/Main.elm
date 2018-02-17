module Main exposing (..)

import Data.Ipfs exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html exposing (Html)
import Json.Decode as Decode
import Ports
import Style exposing (..)
import Style.Border as Border
import Style.Font as Font


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { org : String
    , repo : String
    , objects : Maybe (List IpfsObject)
    , data : Maybe String
    , view : View
    }


init : ( Model, Cmd Msg )
init =
    ( { org = "team.sol"
      , repo = "example"
      , objects = Nothing
      , data = Nothing
      , view = List
      }
    , Cmd.batch
        [ Ports.ipfsList "QmSiLq2wVRyioJ8eBzyUL9UBzRYPia2hNGPDUnzgMin24i"
        ]
    )


type View
    = Single
    | List


type Msg
    = IpfsList (Result String (List IpfsObject))
    | IpfsCatRequest String
    | IpfsCat String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IpfsList (Ok result) ->
            { model | objects = Just result } ! []

        IpfsCatRequest hash ->
            model ! [ Ports.ipfsCat hash ]

        IpfsCat data ->
            { model | data = Just data, view = Single } ! []

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.ipfsListData (decodeIpfsList >> IpfsList)
        , Ports.ipfsCatData IpfsCat
        ]


type Style
    = None
    | Header


styleSheet : StyleSheet Style variation
styleSheet =
    Style.styleSheet
        [ style None []
        , style Header [ Font.size 30 ]
        ]


objectOnClick : IpfsObject -> Attribute variation Msg
objectOnClick object =
    case object.nodeType of
        File ->
            onClick <| IpfsCatRequest object.path

        Directory ->
            onClick NoOp


view : Model -> Html Msg
view model =
    Element.viewport styleSheet <|
        column None
            []
            [ h3 Header [] <| text <| viewHeader model.org model.repo
            , case model.view of
                List ->
                    column None [] <|
                        (flip List.map) (withDefaultList model.objects)
                            (\object -> el None [ objectOnClick object ] <| text object.path)

                Single ->
                    text <| withDefaultString model.data
            ]


viewHeader : String -> String -> String
viewHeader org repo =
    org ++ " / " ++ repo


withDefaultList : Maybe (List a) -> List a
withDefaultList =
    Maybe.withDefault []


withDefaultString : Maybe String -> String
withDefaultString =
    Maybe.withDefault ""
