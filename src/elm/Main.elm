module Main exposing (..)

import Element exposing (..)
import Html exposing (Html)
import Style exposing (..)
import Style.Border as Border


-- APP


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    Int


model : Model
model =
    0



-- UPDATE


type Msg
    = NoOp
    | Increment


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        Increment ->
            model + 1


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
