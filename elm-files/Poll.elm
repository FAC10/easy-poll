module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Style exposing (..)
import Http
--import Json.Decode as Decode
import Json.Encode as Encode
-- import Json.Encode.Pipeline exposing (encode, required)
--import Json.Decode.Pipeline exposing (decode, required)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Question =
    { id : String
    , text : String
    , answers : List Answer
    }


type alias Answer =
    { text : String
    , isSelected : Bool
    , votes : Int
    }

type Display
    = Create
    | Success


type alias Model =
    { question : Question
    , display : Display
    , hasEditedAnswers : Bool
    }


model : Model
model =
    { question =
        { text = ""
        , id = ""
        , answers =
            [
            ]
        }
    , display = Create
    , hasEditedAnswers = False
    }


yesNoWords =
    [ "am", "are", "is", "do", "does", "was", "were", "did", "will", "have", "can", "has", "could", "should", "may", "must", "dare", "ought", "shall", "might", "would" ]


-- POST REQUEST

postQuestionData : Question -> Cmd Msg
postQuestionData question =
    let
        url =
            "http://localhost:4000/questions?id=2"
        request =
            Http.post url questionsEncoder
    in
        Http.send question request |>
            { model | display = Success }


questionsEncoder : Encode.Encoder (List Question)
questionsEncoder =
    Encode.list questionEncoder

questionEncoder : Encode.Encoder Question
questionEncoder data =
    case data of
        Question.id -> Encode.string "id"
        Question.text -> Encode.string "text"
        Question.answers -> (Encode.list answerEncoder)

answerEncoder : Encode.Encoder Answer
answerEncoder =
    case data of
        Answer.text -> "text" Encode.string "text"
        Answer.isSelected -> "isSelected" Encode.bool "isSelected"
        Answer.votes -> "votes" Encode.int "votes"



--- IGNORE BELOW

-- getQuestionData : String -> Cmd Msg
-- getQuestionData questionId =
--     let
--         url =
--             "http://localhost:4000/questions?id=" ++ questionId
--
--         request =
--             Http.get url questionsDecoder
--     in
--     Http.send NewQuestion request





-- UPDATE


type Msg
    = NewQuestion (Result Http.Error (List Question))
    | ChangeQuestion String
    | ChangeAnswer Int String
    | CreatePoll


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewQuestion (Ok questionList) ->
            ( { model | question.text = Maybe.withDefault model.question.text (List.head questionList) }, Cmd.none )

        NewQuestion (Err err) ->
            ( model, Cmd.none )

        ChangeQuestion newQuestion ->
            if not (model.hasEditedAnswers) then
                let
                    questionWords =
                        String.split " " newQuestion

                    firstWord =
                        Maybe.withDefault "" (List.head questionWords)

                    containsOr =
                        List.member "or" questionWords
                in
                if List.length (String.split " or " newQuestion) == 2 then
                    let
                        firstSection =
                            Maybe.withDefault "" (List.head (String.split " or " newQuestion))

                        firstOption =
                            Maybe.withDefault "" (List.head (List.reverse (String.split " " firstSection)))

                        secondSection =
                            Maybe.withDefault "" (List.head (List.reverse (String.split " or " newQuestion)))

                        secondOption = Maybe.withDefault "" (List.head (String.split "?" (
                            Maybe.withDefault "" (List.head (String.split " " secondSection)))))
                    in
                    { model | question.text = newQuestion, question.answers = addOrOptions firstOption secondOption model.question.answers }
                else if List.member (String.toLower firstWord) yesNoWords then
--                    if List.isEmpty (List.filter (\a -> String.length a > 0) model.question.answers) then
                    if not (model.hasEditedAnswers) then
                        if (List.length model.question.answers == 2) then
                            { model | question.text = newQuestion, question.answers = addYesAndNo model.question.answers ++ [ "" ] }
                        else
                            { model | question.text = newQuestion, question.answers = addYesAndNo model.question.answers }
                    else
                        { model | question.text = newQuestion }
                else
                    { model | question.text = newQuestion }
            else
                if List.length (List.filter (\a -> not(a == "")) model.question.answers) == 0 then
                    { model | question.text = newQuestion, hasEditedAnswers = False }
                else
                    { model | question.text = newQuestion }

        ChangeAnswer index newAnswer ->
            let
                updatedList =
                    List.indexedMap (replaceAtIndexWith index newAnswer) model.question.answers
            in
            if not (List.member "" updatedList) then
                { model | question.answers = updatedList ++ [ "" ], hasEditedAnswers = True }
            else
                { model | question.answers = updatedList, hasEditedAnswers = True }

        CreatePoll ->
            -- request to api here
            postQuestionData model.question
            --


replaceAtIndexWith : Int -> String -> Int -> String -> String
replaceAtIndexWith replaceIndex newItem currIndex item =
    if replaceIndex == currIndex then
        newItem
    else
        item


addOrOptions opt1 opt2 list =
    List.indexedMap (replaceAtIndexWith 1 opt2)
        (List.indexedMap (replaceAtIndexWith 0 opt1) list)


addYesAndNo list =
    List.indexedMap (replaceAtIndexWith 1 "no")
        (List.indexedMap (replaceAtIndexWith 0 "yes") list)



-- listIsEmpty : List -> Bool
-- listIsEmpty list =
--     List.isEmpty (List.filter String.isEmpty list)
-- VIEW


generatePlaceholder : Int -> Attribute Msg
generatePlaceholder index =
    if index < 2 then
        placeholder ("option " ++ toString (index + 1))
    else
        placeholder "(optional)"


renderAnswerField : Int -> String -> Html Msg
renderAnswerField index answer =
    input [ type_ "text", answerClass, generatePlaceholder index, value answer, onInput (ChangeAnswer index) ]
        []


view : Model -> Html Msg
view model =
    if model.display == Create then
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text "Easy Poll" ]
             , textarea [ questionClass, placeholder "Your question here!", onInput ChangeQuestion ] [ text model.question.text ]
             ]
                ++ List.indexedMap renderAnswerField model.question.answers
                ++ [ button [ createButtonClass, onClick CreatePoll ] [ text "Create!" ]
                   ]
            )
    else if model.display == Success then
        div [ containerClass ]
            [ text "Success Page"
            ]
    else
        div [] [ text "Something went wrong" ]
