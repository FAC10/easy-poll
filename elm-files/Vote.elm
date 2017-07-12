module Vote exposing (..)

import Html exposing (Attribute, Html, button, div, h1, input, span, text, textarea)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Navigation
import Style exposing (..)


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
    = Voting
    | Result


type alias Model =
    { question : Question
    , selectedIndex : Int
    , display : Display
    }


model : Model
model =
    { question =
        { text = "Loading..."
        , id = ""
        , answers =
            []
        }
    , selectedIndex = -1
    , display = Voting
    }



-- REQUEST


getQuestionData : String -> Cmd Msg
getQuestionData questionId =
    let
        url =
            "http://localhost:4000/questions/" ++ questionId

        request =
            Http.get url questionsDecoder
    in
    Http.send NewQuestion request

voteForAnswer : String -> Int -> Cmd Msg
voteForAnswer questionId selectedIndex = 

    -- need to add what to do if selectedIndex is -1

    let 
        url =
            "http://localhost:4000/questions/" ++ questionId ++ "/vote"

        jsonIndex = indexEncoder selectedIndex

        request =
            Http.post url (Http.jsonBody jsonIndex) questionDecoder
    
    in
    Http.send ResultsReceived request


indexEncoder : Int -> Encode.Value
indexEncoder index =
    Encode.object
        [ ("index", Encode.int index)
        ]

questionsDecoder : Decode.Decoder (List Question)
questionsDecoder =
    Decode.list questionDecoder


answerDecoder : Decode.Decoder Answer
answerDecoder =
    decode Answer
        |> required "text" Decode.string
        |> required "isSelected" Decode.bool
        |> required "votes" Decode.int


questionDecoder : Decode.Decoder Question
questionDecoder =
    decode Question
        |> required "id" Decode.string
        |> required "text" Decode.string
        |> required "answers" (Decode.list answerDecoder)



-- INIT and MAIN


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( model, getQuestionData (String.dropLeft 1 location.hash) )


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

updateSelectedIndex : Int -> Int -> Int
updateSelectedIndex curr new = 
    if curr == new then
        -1
    else
        new

type Msg
    = NewQuestion (Result Http.Error (List Question))
    | UrlChange Navigation.Location
    | ToggleAnswer Int
    | Vote
    | ResultsReceived (Result Http.Error Question)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewQuestion (Ok questionList) ->
            ( { model | question = Maybe.withDefault model.question (List.head questionList) }, Cmd.none )

        NewQuestion (Err err) ->
            ( model, Cmd.none )

        UrlChange location ->
            ( model, getQuestionData (String.dropLeft 1 location.hash) )

        ToggleAnswer indexToToggle ->
            let
                question =
                    model.question

                updatedAnswers =
                    toggleSpecificAnswer indexToToggle model.question.answers

                updatedSelectedIndex = 
                    updateSelectedIndex model.selectedIndex indexToToggle

                updatedQuestion =
                    { question | answers = updatedAnswers}

                -- = { model.question | answers = ( toggleSpecificAnswer indexToToggle model.question.answers ) }
            in
            ( { model | question = updatedQuestion, selectedIndex = updatedSelectedIndex  }, Cmd.none )

        Vote ->
            ( { model | display = Result }, voteForAnswer model.question.id model.selectedIndex )

        ResultsReceived (Ok question) -> 
            ( { model | question = question }, Cmd.none )

        ResultsReceived (Err err) ->
            ( model, Cmd.none )



-- VIEW


renderAnswerButton : Int -> Answer -> Html Msg
renderAnswerButton index answer =
    button [ answerButtonClass answer.isSelected, onClick (ToggleAnswer index) ]
        [ text answer.text ]



-- renderVoteGradient : Int -> String
-- renderVoteGradient votes =
--     let percentage = model.question.answers in
--         "linear-gradient(90deg, green 50%, white 50%);"
--     -- "linear-gradient(90deg, green 50%, white 50%);"


getVoteGradient : Model -> Int -> Answer -> String
getVoteGradient model index answer =
    if Maybe.withDefault 0 (List.maximum (List.map .votes model.question.answers)) <= answer.votes then
        "#B1FFBD " ++ toString ((toFloat answer.votes / toFloat (List.sum (List.map .votes model.question.answers))) * 100)
    else
        "#FFB1B1 " ++ toString ((toFloat answer.votes / toFloat (List.sum (List.map .votes model.question.answers))) * 100)


renderResultAnswer : Model -> Int -> Answer -> Html Msg
renderResultAnswer model index answer =
    div [ answerButtonClass False, style [ ( "background", "linear-gradient(90deg, " ++ getVoteGradient model index answer ++ "%, white 0%)" ) ] ]
        [ --div [style [("width", "50%"), ("background", "#B1FFBD")]] []
          span [] [ text answer.text ]
        , span [ resultAnswerVotes ] [ text (toString answer.votes ++ " votes") ]
        ]


view : Model -> Html Msg
view model =
    if model.display == Voting then
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text model.question.text ] ]
                ++ List.indexedMap renderAnswerButton model.question.answers
                ++ [ button [ createButtonClass, onClick Vote ] [ text "Vote" ]
                   ]
            )
    else
        div [ containerClass ]
            ([ h1 [ titleClass ] [ text model.question.text ] ]
                ++ List.indexedMap (renderResultAnswer model) model.question.answers
                ++ [ div [ class "tc" ] [ text "Share this poll!" ]
                   ]
            )
