module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, h1, h3, input, label, span, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Style exposing (..)


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
    , url : String
    , hasEditedAnswers : Bool
    }


model : Model
model =
    { question =
        { text = ""
        , id = ""
        , answers =
            [ "", "" ]
        }
    , display = Create
    , url = "www.easy-poll.co.uk/#p0ll1d"
    , hasEditedAnswers = False
    }


yesNoWords =
    [ "am", "are", "is", "do", "does", "was", "were", "did", "will", "have", "can", "has", "could", "should", "may", "must", "dare", "ought", "shall", "might", "would" ]



-- init and main


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- UPDATE


type Msg
    = ChangeQuestion String
    | ChangeAnswer Int String
    | CreatePoll


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
                    ( { model | question = updatedQuestion }, Cmd.none )
                else if List.member (String.toLower firstWord) yesNoWords then
                    -- if question begins with a yes or no word
                    if not model.hasEditedAnswers then
                        if List.length model.question.answers == 2 then
                            ( { model | question = { question | text = newQuestion, answers = addYesAndNo model.question.answers ++ [ "" ] } }, Cmd.none )
                        else
                            ( { model | question = { question | text = newQuestion, answers = addYesAndNo model.question.answers } }, Cmd.none )
                    else
                        ( { model | question = { question | text = newQuestion } }, Cmd.none )
                else
                    ( { model | question = { question | text = newQuestion } }, Cmd.none )
            else if List.length (List.filter (\a -> not (a == "")) model.question.answers) == 0 then
                -- if all answers are empty strings
                ( { model | question = { question | text = newQuestion }, hasEditedAnswers = False }, Cmd.none )
            else
                ( { model | question = { question | text = newQuestion } }, Cmd.none )

        ChangeAnswer index newAnswer ->
            let
                updatedList =
                    List.indexedMap (replaceAtIndexWith index newAnswer) model.question.answers

                question =
                    model.question
            in
            if not (List.member "" updatedList) then
                ( { model | question = { question | answers = updatedList ++ [ "" ] }, hasEditedAnswers = True }, Cmd.none )
            else
                ( { model | question = { question | answers = updatedList }, hasEditedAnswers = True }, Cmd.none )

        CreatePoll ->
            -- request to api here
            ( { model | display = Success }, Cmd.none )


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
            [ span [ successIconStyle, class "fa fa-check-circle-o" ] []
            , h3 [ style [ ( "text-align", "center" ) ] ] [ text "Poll created successfully!" ]
            , label [ urlLabelStyle ] [ text "Share the following vote URL:" ]
            , input [ value model.url, urlInputClass ] []
            , button [ createButtonClass ] [ text "Share!" ]
            ]
    else
        div [] [ text "Something went wrong" ]
