module Style exposing (..)

import Html.Attributes exposing (class)


containerClass =
    class "avenir w-100 bg-white center pa4 br4"


titleClass =
    class "tc mv5"



-- create page


questionClass =
    class "center f3 db w-90 br3 ba bw2 b--blue pa3 ma3"


answerClass =
    class "center db w-90 center ba br3 pa3 ma3"


createButtonClass =
    class "center db w4 br-pill ba bw2 b--yellow bg-white pa3 ma4"



-- Vote page


answerButtonClass isSelected =
    if isSelected == True then
        class "center db w-90 center ba bg-green br3 pa3 ma3"
    else
        class "center db w-90 center ba bg-white br3 pa3 ma3"


resultAnswerVotes =
    class "fr cf"
