module Vote exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (..)
import Style exposing (..)


-- MODEL


type alias Answer =
    { text : String
    , isSelected : Bool
    , votes : Int
    }


type alias Model =
    { question : String
    , canSelectMultiple : Bool
    , answers : List Answer
    }


model : Model
model =
    { question = "Is this test question useful or not?"
    , canSelectMultiple = False
    , answers =
        [ { text = "test answer", isSelected = False, votes = 0 }
        , { text = "test answer 2", isSelected = False, votes = 0 }
        ]
    }


getQuestionData =
    Cmd.none


init : ( Model, Cmd Msg )
init =
    ( model, getQuestionData )


main =
    Html.program
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
    | ToggleAnswer Int
    | Vote


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewQuestion (Ok data) ->
            ( { model | question = data }, Cmd.none )

        NewQuestion (Err _) ->
            ( model, Cmd.none )

        ToggleAnswer indexToToggle ->
            ( { model | answers = toggleSpecificAnswer indexToToggle model.answers }, Cmd.none )

        Vote ->
            ( model, Cmd.none )



-- VIEW


renderAnswerButton : Int -> Answer -> Html Msg
renderAnswerButton index answer =
    button [ answerButtonClass answer.isSelected, onClick (ToggleAnswer index) ]
        [ text answer.text ]


view : Model -> Html Msg
view model =
    div [ containerClass ]
        ([ h1 [ titleClass ] [ text model.question ] ]
            ++ List.indexedMap renderAnswerButton model.answers
            ++ [ button [ createButtonClass, onClick Vote ] [ text "Vote" ]
               ]
        )