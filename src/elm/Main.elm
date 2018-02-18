module Main exposing (..)

import Color exposing (rgb)
import Data.Ipfs exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html exposing (Html, pre)
import Html.Attributes
import Navigation exposing (Location)
import Ports
import Routing exposing (..)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


main : Program Never Model Msg
main =
    Navigation.program LocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { errors : List String
    , route : Route
    , view : View
    , org : String
    , repo : String
    , currentPath : List String
    , objects : Maybe (List IpfsObject)
    , content : Maybe String
    }


rootHash : String
rootHash =
    "QmSiLq2wVRyioJ8eBzyUL9UBzRYPia2hNGPDUnzgMin24i"


init : Location -> ( Model, Cmd Msg )
init location =
    ( { errors = []
      , route = parseLocation location
      , org = "team.sol"
      , repo = "example"
      , currentPath = [ rootHash ]
      , objects = Nothing
      , content = Nothing
      , view = List
      }
    , Cmd.batch
        [ Ports.ipfsList rootHash ]
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
    | LocationChange Location
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

        LocationChange location ->
            let
                route =
                    parseLocation location
            in
                case route of
                    RepoRoute org repo ->
                        { model | route = route, org = org, repo = repo } ! []

                    NotFoundRoute ->
                        { model | route = route } ! []

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
    | Container
    | ListItem


styleSheet : StyleSheet Style variation
styleSheet =
    Style.styleSheet
        [ style None []
        , style ErrorMessage [ Color.text Color.red ]
        , style Header [ Font.size 30 ]
        , style Container
            [ Border.all 1.0
            , Border.solid
            , Border.rounded 5.0
            , Color.border Color.gray
            ]
        , style ListItem
            [ hover [ Color.background <| rgb 248 248 248 ] ]
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
    case model.route of
        NotFoundRoute ->
            Element.viewport styleSheet <|
                column None
                    []
                    [ text "404" ]

        RepoRoute org repo ->
            Element.viewport styleSheet <|
                column None
                    [ width fill, height fill, center ]
                    [ column None
                        [ width <| px 1000, spacing 20 ]
                        [ when (not <| List.isEmpty model.errors) <|
                            column None [] <|
                                (flip List.map) model.errors (\err -> el ErrorMessage [] <| text err)
                        , h3 Header [ paddingTop 20 ] <| text <| viewHeader org repo
                        , viewPath model.currentPath
                        , case model.view of
                            List ->
                                column Container [] <|
                                    (flip List.map) (withDefaultList model.objects)
                                        (\object ->
                                            el ListItem [ objectOnClick object, paddingXY 20 10 ] <|
                                                row None
                                                    [ spacing 10, verticalCenter ]
                                                    [ viewIcon object.nodeType
                                                    , text object.name
                                                    ]
                                        )

                            Single ->
                                column Container
                                    [ padding 10 ]
                                    [ html <|
                                        pre []
                                            [ Html.text <| withDefaultString model.content
                                            ]
                                    ]
                        ]
                    ]


viewIcon : IpfsType -> Element Style variation Msg
viewIcon t =
    case t of
        File ->
            html <| Html.i [ Html.Attributes.class "far fa-file-alt" ] []

        Directory ->
            html <| Html.i [ Html.Attributes.class "far fa-folder" ] []


viewPath : List String -> Element Style variation Msg
viewPath path =
    row None [] <|
        (path
            |> ((::) "ipfs")
            |> List.map (\p -> text p)
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
