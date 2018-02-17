module Main exposing (..)

import Color
import Data.Ipfs exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html exposing (Html)
import Json.Decode as Decode
import Ports
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
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
    { errors : List String
    , org : String
    , repo : String
    , currentPath : List String
    , objects : Maybe (List IpfsObject)
    , content : Maybe String
    , view : View
    }


init : ( Model, Cmd Msg )
init =
    ( { errors = []
      , org = "team.sol"
      , repo = "example"
      , currentPath = [ "QmSiLq2wVRyioJ8eBzyUL9UBzRYPia2hNGPDUnzgMin24i" ]
      , objects = Nothing
      , content = Nothing
      , view = List
      }
    , Cmd.batch
        [ Ports.ipfsList "QmSiLq2wVRyioJ8eBzyUL9UBzRYPia2hNGPDUnzgMin24i" ]
    )


type View
    = Single
    | List


type Msg
    = IpfsListRequest String
    | IpfsList (Result String (List IpfsObject))
    | IpfsCatRequest String
    | IpfsCat String
    | Error String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IpfsListRequest hash ->
            { model | currentPath = hashComponents hash } ! [ Ports.ipfsList hash ]

        IpfsList (Ok result) ->
            { model | objects = Just result, view = List } ! []

        IpfsList (Err error) ->
            { model | errors = error :: model.errors } ! []

        IpfsCatRequest hash ->
            { model | currentPath = hashComponents hash }
                ! [ Ports.ipfsCat hash ]

        IpfsCat content ->
            { model | content = Just content, view = Single } ! []

        Error error ->
            { model | errors = error :: model.errors } ! []

        NoOp ->
            model ! []


hashComponents : String -> List String
hashComponents =
    String.split "/"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.error Error
        , Ports.ipfsListData (decodeIpfsList >> IpfsList)
        , Ports.ipfsCatData IpfsCat
        ]


type Style
    = None
    | ErrorMessage
    | Header


styleSheet : StyleSheet Style variation
styleSheet =
    Style.styleSheet
        [ style None []
        , style ErrorMessage [ Color.text Color.red ]
        , style Header [ Font.size 30 ]
        ]


objectOnClick : IpfsObject -> Attribute variation Msg
objectOnClick object =
    case object.nodeType of
        File ->
            onClick <| IpfsCatRequest object.path

        Directory ->
            onClick <| IpfsListRequest object.path


view : Model -> Html Msg
view model =
    Element.viewport styleSheet <|
        column None
            []
            [ when (not <| List.isEmpty model.errors) <|
                column None [] <|
                    (flip List.map) model.errors (\err -> el ErrorMessage [] <| text err)
            , h3 Header [] <| text <| viewHeader model.org model.repo
            , viewPath model.currentPath
            , case model.view of
                List ->
                    column None [] <|
                        (flip List.map) (withDefaultList model.objects)
                            (\object -> el None [ objectOnClick object ] <| text object.name)

                Single ->
                    text <| withDefaultString model.content
            ]


viewPath : List String -> Element Style variation Msg
viewPath path =
    row None [] <|
        (List.map (\p -> text p) path
            |> List.intersperse (text " > ")
        )


viewHeader : String -> String -> String
viewHeader org repo =
    org ++ " / " ++ repo


withDefaultList : Maybe (List a) -> List a
withDefaultList =
    Maybe.withDefault []


withDefaultString : Maybe String -> String
withDefaultString =
    Maybe.withDefault ""
