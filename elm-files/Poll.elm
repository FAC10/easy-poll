module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, h1, h3, input, label, span, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Style exposing (..)


-- MODEL


type Display
    = Create
    | Success


type alias Model =
    { question : String
    , answers : List String
    , display : Display
    , url : String
    , hasEditedAnswers : Bool
    }


model : Model
model =
    { question = ""
    , answers = [ "", "" ]
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
                    in
                    ( { model | question = newQuestion, answers = addOrOptions firstOption secondOption model.answers }, Cmd.none)
                else if List.member (String.toLower firstWord) yesNoWords then
                    --                    if List.isEmpty (List.filter (\a -> String.length a > 0) model.answers) then
                    if not model.hasEditedAnswers then
                        if List.length model.answers == 2 then
                            ( { model | question = newQuestion, answers = addYesAndNo model.answers ++ [ "" ] }, Cmd.none )
                        else
                            ( { model | question = newQuestion, answers = addYesAndNo model.answers }, Cmd.none )
                    else
                        ( { model | question = newQuestion }, Cmd.none )
                else
                    ( { model | question = newQuestion }, Cmd.none )
            else if List.length (List.filter (\a -> not (a == "")) model.answers) == 0 then
                ( { model | question = newQuestion, hasEditedAnswers = False }, Cmd.none )
            else
                ( { model | question = newQuestion }, Cmd.none )

        ChangeAnswer index newAnswer ->
            let
                updatedList =
                    List.indexedMap (replaceAtIndexWith index newAnswer) model.answers
            in
            if not (List.member "" updatedList) then
                ( { model | answers = updatedList ++ [ "" ], hasEditedAnswers = True }, Cmd.none )
            else
                ( { model | answers = updatedList, hasEditedAnswers = True }, Cmd.none )

        CreatePoll ->
            -- request to api here
            ( { model | display = Success }, Cmd.none )


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
             , textarea [ questionClass, placeholder "Your question here!", onInput ChangeQuestion ] [ text model.question ]
             ]
                ++ List.indexedMap renderAnswerField model.answers
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
