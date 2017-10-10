module Main exposing (..)

import Html exposing (beginnerProgram)

import Types exposing (..)
import State exposing (init, update, subscriptions)
import View exposing (view)


main : Program Never Model Msg
main =
    beginnerProgram
        { model = init
        , view = view
        , update = update
        }
