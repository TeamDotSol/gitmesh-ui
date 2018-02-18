module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = RepoRoute String String
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map RepoRoute (string </> string) ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
