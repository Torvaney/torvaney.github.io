module View exposing (view)

import Html exposing (Html, div, nav, a, h1, img, button, text)
import Html.Attributes exposing (class, src, href)
import Html.Events exposing (onClick)
import Color
import Markdown
import FontAwesome exposing (twitter, github)

import Types exposing (..)


view : Model -> Html Msg
view model =
  divContainer
      [ navbar
      , divRow
          [ divColN 5 [ ]
          , divColN 5 [ h1 [ ] [ text model.title ] ]
          , divColN 2 [ ]
          ]
      , divRow
          [ divColN 2 [ ]
          , divColN 3 [ leftColumn ]
          , divColN 5 [ Markdown.toHtml [ ] model.main ]
          , divColN 2 [ ]
          ]
      ]

-- NAVBAR

navbar =
  nav
      [ class "navbar navbar-static-top navbar-light bg-faded"]
      [ divClass "container-fluid text-center"
          [ divClass "btn-group"
              [ linkButton "About" About
              , linkButton "Projects" Projects
              ]
          ]
      ]


linkButton : String -> Msg -> Html Msg
linkButton txt msg =
  a [ class "btn btn-secondary", onClick msg ] [ text txt]


-- LEFT HAND SIDE

leftColumn =
  div
      []
      [ img
          [ src "src/static/img/me.jpg", class "img-circle" ]
          [ ]
      , socialLinks
      ]


socialLinks =
  div [ ]
    [ linkProfile (twitter Color.charcoal 50) "https://twitter.com/Torvaney"
    , linkProfile (github Color.charcoal 50) "http://github.com/Torvaney"
    ]


linkProfile : Html msg -> String -> Html msg
linkProfile icon url =
  a [ class "btn", href url ] [icon]


-- DIV

divContainer =
  div [ class "container-fullwidth"]

divRow =
  div [ class "row"]

divClass classString =
  div [ class classString ]

divColN n =
  div [ class ("col-md-" ++ toString n) ]
