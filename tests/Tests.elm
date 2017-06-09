module Tests exposing (..)

import Expect
import Fuzz exposing (int, list, string)
import Poll
import Test exposing (..)


suite : Test
suite =
    describe "The Poll page"
        [ describe "replaceAtIndexWith"
            -- Nest as many descriptions as you like.
            [ test "does nothing when indexes don't match" <|
                \_ ->
                    Poll.replaceAtIndexWith 0 "new" 1 "old"
                        |> Expect.equal "old"
            , test "returns new value when indexes match" <|
                \_ ->
                    Poll.replaceAtIndexWith 3 "new" 3 "old"
                        |> Expect.equal "new"
            ]
        , describe "addYesAndNo"
            [ test "does nothing to empty list" <|
                \_ ->
                    Poll.addYesAndNo []
                        |> Expect.equal []
            , test "puts yes and no in list of 2 empty elements" <|
                \_ ->
                    Poll.addYesAndNo [ "", "" ]
                        |> Expect.equal [ "yes", "no" ]
            ]
        ]
