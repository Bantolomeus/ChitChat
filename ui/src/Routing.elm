module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = MainRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map MainRoute top
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            MainRoute



-- main route is always fine :)
