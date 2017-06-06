module Poll exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, text, textarea)
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
                if not (List.member "" model.answers) then
                    { model | question = newQuestion, answers = addYesAndNo model.answers ++ [ "" ] }
                else if (List.length model.answers == 2) then
                    { model | question = newQuestion, answers = addYesAndNo model.answers ++ [ "" ] }
                else
                    { model | question = newQuestion, answers = addYesAndNo model.answers }
            else
                { model | question = newQuestion }

        ChangeAnswer index newAnswer ->
            let
                updatedList =
                    List.indexedMap (replaceAtIndexWith index newAnswer) model.answers
            in
                if not (List.member "" updatedList) then
                    { model | answers = updatedList ++ [ "" ] }
                else
                    { model | answers = updatedList }

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
    div [ containerClass ]
        ([ h1 [ titleClass ] [ text "Easy Poll" ]
         , textarea [ questionClass, placeholder "Your question here!", onInput ChangeQuestion ] [ text model.question ]
         ]
            ++ List.indexedMap renderAnswerField model.answers
            ++ [ button [ createButtonClass, onClick AddAnswer ] [ text "Create!" ]
               ]
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
