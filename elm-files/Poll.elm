module Poll exposing (..)

import Http
import Html exposing (Attribute, Html, button, div, h1, h3, input, label, span, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Style exposing (..)
import Vote exposing (Answer, questionDecoder)
import Json.Encode as Encode
import Json.Decode as Decode
import Random


-- MODEL


type alias Question =
    { id : String
    , text : String
    , answers : List String
    }


type Display
    = Create
    | Success


type alias Model =
    { question : Question
    , display : Display
    , hasEditedAnswers : Bool
    , errorMessage : String
    }


model : Model
model =
    { question =
        { text = ""
        , id = "needToRandomiseThis"
        , answers =
            [ "", "" ]
        }
    , display = Create
    , hasEditedAnswers = False
    , errorMessage = ""
    }


yesNoWords =
    [ "am", "are", "is", "do", "does", "was", "were", "did", "will", "have", "can", "has", "could", "should", "may", "must", "dare", "ought", "shall", "might", "would" ]



-- init and main


init : ( Model, Cmd Msg )
init =
    ( model, Random.generate IdGenerated (Random.int 1000000000000 9999999999999) )


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


-- POST request

type alias QuestionForDb =
    { id : String
    , text : String
    , answers: List Answer
    }

stringToAnswerObj : String -> Answer
stringToAnswerObj answerStr =
    { text = answerStr
    , isSelected = False
    , votes = 0
    }

convertForDb : Question -> QuestionForDb
-- also remove empty fields
convertForDb question =
    { question | answers = List.map stringToAnswerObj (List.filter (\a -> not (a == "")) question.answers) }


postQuestionData : QuestionForDb -> Cmd Msg
postQuestionData question =
    let
        url =
            "http://localhost:4000/questions"

        jsonQuestion = questionEncoder question

        request =
            Http.post url (Http.jsonBody jsonQuestion) questionDecoder

    in
    Http.send PollCreated request


questionEncoder : QuestionForDb -> Encode.Value
questionEncoder question = questionObjectifier question

questionObjectifier : QuestionForDb -> Encode.Value
questionObjectifier question =
    Encode.object
        [ ("id", Encode.string question.id)
        , ("text", Encode.string question.text)
        , ("answers", Encode.list (List.map answerObjectifier question.answers) )
        ]

answerObjectifier : Answer -> Encode.Value
answerObjectifier answer =
    Encode.object
        [ ("text", Encode.string answer.text)
        , ("isSelected", Encode.bool answer.isSelected)
        , ("votes", Encode.int answer.votes)
        ]

-- UPDATE


type Msg
    = ChangeQuestion String
    | ChangeAnswer Int String
    | CreatePoll
    | PollCreated (Result Http.Error Vote.Question)
    | IdGenerated Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeQuestion newQuestion ->
            let
                question =
                    model.question
            in
            if not model.hasEditedAnswers then
                let
                    questionWords =
                        String.split " " newQuestion

                    firstWord =
                        Maybe.withDefault "" (List.head questionWords)

                    containsOr =
                        List.member "or" questionWords
                in
                if List.length (String.split " or " newQuestion) == 2 then
                    -- if one "or" in the question
                    let
                        firstSection =
                            Maybe.withDefault "" (List.head (String.split " or " newQuestion))

                        firstOption =
                            Maybe.withDefault "" (List.head (List.reverse (String.split " " firstSection)))

                        secondSection =
                            Maybe.withDefault "" (List.head (List.reverse (String.split " or " newQuestion)))

                        secondOption =
                            Maybe.withDefault ""
                                (List.head
                                    (String.split "?"
                                        (Maybe.withDefault "" (List.head (String.split " " secondSection)))
                                    )
                                )

                        updatedQuestion =
                            { question | text = newQuestion, answers = addOrOptions firstOption secondOption question.answers }
                    in
                    ( { model | errorMessage = "", question = updatedQuestion }, Cmd.none )
                else if List.member (String.toLower firstWord) yesNoWords then
                    -- if question begins with a yes or no word
                    if not model.hasEditedAnswers then
                        if List.length model.question.answers == 2 then
                            ( { model | errorMessage = "", question = { question | text = newQuestion, answers = addYesAndNo model.question.answers ++ [ "" ] } }, Cmd.none )
                        else
                            ( { model | errorMessage = "", question = { question | text = newQuestion, answers = addYesAndNo model.question.answers } }, Cmd.none )
                    else
                        ( { model | errorMessage = "", question = { question | text = newQuestion } }, Cmd.none )
                else
                    ( { model | errorMessage = "", question = { question | text = newQuestion } }, Cmd.none )
            else if List.length (List.filter (\a -> not (a == "")) model.question.answers) == 0 then
                -- if all answers are empty strings
                ( { model | errorMessage = "", question = { question | text = newQuestion }, hasEditedAnswers = False }, Cmd.none )
            else
                ( { model | errorMessage = "", question = { question | text = newQuestion } }, Cmd.none )

        ChangeAnswer index newAnswer ->
            let
                updatedList =
                    List.indexedMap (replaceAtIndexWith index newAnswer) model.question.answers

                question =
                    model.question
            in
            if not (List.member "" updatedList) then
                ( { model | errorMessage = "", question = { question | answers = updatedList ++ [ "" ] }, hasEditedAnswers = True }, Cmd.none )
            else
                ( { model | errorMessage = "", question = { question | answers = updatedList }, hasEditedAnswers = True }, Cmd.none )

        IdGenerated id ->
            let
                question =
                    model.question
            in
                ( { model | question = { question | id = toString id } }, Cmd.none )

        CreatePoll ->
            -- Validation, should really be abstracted into a utility function
            if String.isEmpty <| String.trim model.question.text then
              ( { model | errorMessage = "Please enter a question." }, Cmd.none )
            else if List.length (List.filter (\a -> not (String.isEmpty <| String.trim a)) model.question.answers) < 2 then
              ( { model | errorMessage = "Please enter at least 2 possible answers." }, Cmd.none )
            else
            -- TODO: create loading screen or similar?
            ( model, postQuestionData (convertForDb model.question) )

        PollCreated (Ok question) ->
            ( { model | display = Success }, Cmd.none )

        PollCreated (Err _) ->
          -- TODO: improve this?
            ( model, Cmd.none )

replaceAtIndexWith : Int -> String -> Int -> String -> String
replaceAtIndexWith replaceIndex newItem currIndex item =
    if replaceIndex == currIndex then
        newItem
    else
        item


addOrOptions : String -> String -> List String -> List String
addOrOptions opt1 opt2 list =
    List.indexedMap (replaceAtIndexWith 1 opt2)
        (List.indexedMap (replaceAtIndexWith 0 opt1) list)


addYesAndNo : List String -> List String
addYesAndNo list =
    List.indexedMap (replaceAtIndexWith 1 "no")
        (List.indexedMap (replaceAtIndexWith 0 "yes") list)


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

createUrl : String -> String
createUrl id =
    "http://localhost:4000/vote.html#" ++ id


view : Model -> Html Msg
view model =
    if model.display == Create then
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text "Easy Poll" ]
             , textarea [ questionClass, placeholder "Your question here!", onInput ChangeQuestion ] [ text model.question.text ]
             ]
                ++ List.indexedMap renderAnswerField model.question.answers
                ++ [ span [ errorMessageClass ] [ text model.errorMessage ]
                   , button [ createButtonClass, onClick CreatePoll ] [ text "Create!" ]
                   ]
            )
    else if model.display == Success then
        div [ containerClass ]
            [ span [ successIconStyle, class "fa fa-check-circle-o" ] []
            , h3 [ style [ ( "text-align", "center" ) ] ] [ text "Poll created successfully!" ]
            , label [ urlLabelStyle ] [ text "Share the following vote URL:" ]
            , input [ value (createUrl model.question.id) , urlInputClass ] []
            , button [ createButtonClass ] [ text "Share!" ]
            ]
    else
        div [] [ text "Something went wrong" ]
