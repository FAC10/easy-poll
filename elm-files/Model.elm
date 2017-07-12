module Model exposing (Answer, VoteQuestion, questionDecoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)


type alias Answer =
    { text : String
    , isSelected : Bool
    , votes : Int
    }

type alias VoteQuestion =
    { id : String
    , text : String
    , answers : List Answer
    }

answerDecoder : Decode.Decoder Answer
answerDecoder =
    decode Answer
        |> required "text" Decode.string
        |> required "isSelected" Decode.bool
        |> required "votes" Decode.int

questionDecoder : Decode.Decoder VoteQuestion
questionDecoder =
    decode VoteQuestion
        |> required "id" Decode.string
        |> required "text" Decode.string
        |> required "answers" (Decode.list answerDecoder)