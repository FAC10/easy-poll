module Main exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { question : String
    , answers : List String
    }


model : Model
model =
    { question = ""
    , answers = [ "", "" ]
    }



-- UPDATE


type Msg
    = ToggleAnswer Int String
    | Vote


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleAnswer index answer ->
            { model | answers = List.indexedMap (replaceAtIndexWith index answer) model.answers }

        Vote ->
            { model | answers = model.answers ++ [ "" ] }


replaceAtIndexWith : Int -> String -> Int -> String -> String
replaceAtIndexWith replaceIndex newItem currIndex item =
    if replaceIndex == currIndex then
        newItem
    else
        item



-- VIEW


renderAnswerField : Int -> String -> Html Msg
renderAnswerField index answer =
    button [ createButtonClass, answerClass, placeholder ("option " ++ toString (index + 1)), value answer, onInput (ToggleAnswer index) ]
        []


view : Model -> Html Msg
view model =
    div [ containerClass ]
        ([ h1 [ titleClass ] [ text "Easy Poll" ] ]
            ++ List.indexedMap renderAnswerField model.answers
        )



-- STYLES


containerClass =
    class "avenir w-100 bg-white center pa4 br4"


titleClass =
    class "tc mv5"


questionClass =
    class "center f3 db w-90 br3 ba bw2 b--blue pa3 ma3"


answerClass =
    class "center db w-90 center ba br3 pa3 ma3"


createButtonClass =
    class "center db w4 br-pill ba bw2 b--yellow bg-white pa3 ma4"
