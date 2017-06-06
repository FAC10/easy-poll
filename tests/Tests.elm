module Tests exposing (..)

import Expect
import Fuzz exposing (int, list, string)
import Poll
import Test exposing (..)


suite : Test
suite =
    describe "The Poll app"
        [ describe "replaceAtIndexWith"
            -- Nest as many descriptions as you like.
            [ test "does nothing when indexes don't match" <|
                \_ ->
                    Poll.replaceAtIndexWith 0 "new" 1 "old"
                        |> Expect.equal "old"
            ]
        ]
