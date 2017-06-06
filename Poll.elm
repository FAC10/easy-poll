module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { question : String
    , answers : List String
    , test : String
    }


model : Model
model =
    { question = ""
    , answers = [ "", "" ]
    , test = ""
    }



-- UPDATE


type Msg
    = ChangeQuestion String
    | ChangeAnswer Int String
    | AddAnswer


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

        AddAnswer ->
            { model | answers = model.answers ++ [ "" ] }


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


renderAnswerField : Int -> String -> Html Msg
renderAnswerField index answer =
    input [ type_ "text", aStyle, placeholder ("option " ++ toString (index + 1)), value answer, onInput (ChangeAnswer index) ]
        []


aStyle =
    class "w3"


qStyle =
    class "w5"


view : Model -> Html Msg
view model =
    div []
        [ input [ qStyle, placeholder "Your question here!", onInput ChangeQuestion ] [ text model.question ]
        , div [] (List.indexedMap renderAnswerField model.answers)
        , div [] [ text (toString model.answers) ]
        , button [ onClick AddAnswer ] [ text "another answer" ]
        ]
