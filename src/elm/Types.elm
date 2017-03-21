module Types exposing (..)

import Html exposing (Html)


type Msg
    = About
    | Projects


type alias Model =
  { title : String
  , main : String
  }
