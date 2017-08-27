port module Main exposing (..)

import CircularListSuite
import Test exposing (describe)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run
        emit
        (describe
            "ChitChat Tests"
            [ CircularListSuite.tests
            ]
        )


port emit : ( String, Value ) -> Cmd msg
