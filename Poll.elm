module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Style exposing (..)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type Display
    = Create
    | Success


type alias Model =
    { question : String
    , answers : List String
    , display : Display
    }


model : Model
model =
    { question = ""
    , answers = [ "", "" ]
    , display = Create
    }



-- UPDATE


type Msg
    = ChangeQuestion String
    | ChangeAnswer Int String
    | CreatePoll


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeQuestion newQuestion ->
            if newQuestion == "is" then
                { model | question = newQuestion, answers = addYesAndNo model.answers }
            else
                { model | question = newQuestion }

        ChangeAnswer index newAnswer ->
            { model | answers = List.indexedMap (replaceAtIndexWith index newAnswer) model.answers }

        CreatePoll ->
            -- request to api here
            { model | display = Success }


replaceAtIndexWith : Int -> String -> Int -> String -> String
replaceAtIndexWith replaceIndex newItem currIndex item =
    if replaceIndex == currIndex then
        newItem
    else
        item


addYesAndNo list =
    List.indexedMap (replaceAtIndexWith 1 "no")
        (List.indexedMap (replaceAtIndexWith 0 "yes") list)



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
            [ text "Success Page"
            ]
    else
        div [] [ text "Something went wrong" ]
