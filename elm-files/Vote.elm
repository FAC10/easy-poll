module Vote exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (..)
import Style exposing (..)
import Navigation


-- MODEL


type alias Answer =
    { text : String
    , isSelected : Bool
    , votes : Int
    }

type Display
    = Voting
    | Result


type alias Model =
    { question : String
    , questionId : String
    , canSelectMultiple : Bool
    , answers : List Answer
    , display : Display
    }


model : Model
model =
    { question = "Is this test question useful or not?"
    , questionId = "1"
    , canSelectMultiple = False
    , answers =
        [ { text = "test answer", isSelected = False, votes = 4 }
        , { text = "test answer 2", isSelected = False, votes = 2 }
        , { text = "test answer 3", isSelected = False, votes = 20 }
        , { text = "test answer 4", isSelected = False, votes = 15 }
        , { text = "test answer 5", isSelected = False, votes = 6 }
        ]
    , display = Voting
    }


getQuestionData =
    Cmd.none


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { model | questionId = String.dropLeft 1 location.hash }, getQuestionData )


main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- UPDATE


toggleSpecificAnswer : Int -> List Answer -> List Answer
toggleSpecificAnswer indexToToggle answers =
    List.indexedMap
        (\index answer ->
            if index == indexToToggle then
                { answer | isSelected = not answer.isSelected }
            else
                { answer | isSelected = False }
        )
        answers


type Msg
    = NewQuestion (Result Http.Error String)
    | UrlChange Navigation.Location
    | ToggleAnswer Int
    | Vote


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewQuestion (Ok data) ->
            ( { model | question = data }, Cmd.none )

        UrlChange location ->
            ( { model | questionId = String.dropLeft 1 location.hash }, Cmd.none )

        NewQuestion (Err _) ->
            ( model, Cmd.none )

        ToggleAnswer indexToToggle ->
            ( { model | answers = toggleSpecificAnswer indexToToggle model.answers }, Cmd.none )

        Vote ->
            ( { model | display = Result }, Cmd.none )



-- VIEW


renderAnswerButton : Int -> Answer -> Html Msg
renderAnswerButton index answer =
    button [ answerButtonClass answer.isSelected, onClick (ToggleAnswer index) ]
        [ text answer.text ]

-- renderVoteGradient : Int -> String
-- renderVoteGradient votes =
--     let percentage = model.answers in
--         "linear-gradient(90deg, green 50%, white 50%);"
--     -- "linear-gradient(90deg, green 50%, white 50%);"
getVoteGradient : Int -> Answer -> String
getVoteGradient index answer =
    if Maybe.withDefault 0 (List.maximum (List.map .votes model.answers)) <= answer.votes then
        "#B1FFBD " ++ toString ((toFloat answer.votes / toFloat (List.sum (List.map .votes model.answers))) * 100)
    else
        "#FFB1B1 " ++ toString ((toFloat answer.votes / toFloat (List.sum (List.map .votes model.answers))) * 100)


renderResultAnswer : Int -> Answer -> Html Msg
renderResultAnswer index answer =
    div [ answerButtonClass False, style [("background", "linear-gradient(90deg, " ++ (getVoteGradient index answer) ++ "%, white 0%)")] ]
        [ --div [style [("width", "50%"), ("background", "#B1FFBD")]] []
         span [] [text answer.text]
        , span [ resultAnswerVotes ] [text ( toString answer.votes ++ " votes" ) ]
    ]


view : Model -> Html Msg
view model =
    if model.display == Voting then
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text model.question ] ]
                ++ List.indexedMap renderAnswerButton model.answers
                ++ [ button [ createButtonClass, onClick Vote ] [ text "Vote" ]
                   , div [] [ text model.questionId ]
                   ]
            )
    else
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text model.question ] ]
                ++ List.indexedMap renderResultAnswer model.answers
                ++ [ div [] [ text model.questionId ]
                   ]
            )
