module State exposing (about, update, subscriptions)

import Types exposing (..)
import Pages exposing (..)


-- INIT

about = Model "About" aboutText


-- UPDATE

update : Msg -> Model -> Model
update msg model =
  case msg of
    About ->
      about
    Projects ->
      Model "Projects" projectText


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
