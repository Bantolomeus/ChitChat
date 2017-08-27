module CircularListSuite exposing (tests)

import CircularList exposing (CircularList(..))
import Test exposing (test, describe, Test)
import Expect


tests : Test
tests =
    describe "CircularList"
        [ test "get" <|
            \() ->
                let
                    s =
                        "bla"
                in
                    CircularList.single s
                        |> CircularList.get
                        |> Expect.equal s
        , test "take" <|
            \() ->
                let
                    s =
                        "bla"
                in
                    CircularList.single s
                        |> CircularList.take 5
                        |> Expect.equal [ s, s, s, s, s ]
        , test "fromList" <|
            \() ->
                let
                    ( s, m ) =
                        ( "bla", "blub" )
                in
                    CircularList.fromList s [ m, m, m ]
                        |> CircularList.take 8
                        |> Expect.equal [ s, m, m, m, s, m, m, m ]
        ]
