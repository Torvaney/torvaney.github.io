module Main exposing (..)

import Html exposing (beginnerProgram)

import Types exposing (..)
import State exposing (about, update, subscriptions)
import View exposing (view)


main : Program Never Model Msg
main =
    beginnerProgram
        { model = about
        , view = view
        , update = update
        }
