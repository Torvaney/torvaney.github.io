module State exposing (init, update, subscriptions)

import Types exposing (..)
import Pages exposing (..)


-- INIT

init = Model "Projects" projectText


-- UPDATE

update : Msg -> Model -> Model
update msg model =
  case msg of
    About ->
      Model "About" aboutText
    Projects ->
      Model "Projects" projectText


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
