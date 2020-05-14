module Home exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Url.Builder


main =
    Browser.document
        { init =
            \() ->
                ( { projects = projects
                  }
                , Cmd.none
                )
        , view = view
        , update = update
        , subscriptions =
            \_ ->
                Sub.none
        }


type alias Model =
    { projects : List Project
    }


type alias Project =
    { name : String
    , description : List String
    , link : Link
    , code : Link
    }


type Link
    = ProjectUrl String
    | GithubUrl String
    | ExternalUrl String
    | NoLink


type alias ExternalUrl =
    String


type Msg
    = Void Msg


projects =
    [ Project
        "xG interactive"
        [ "An interactive demonstration of 'Expected Goals' in football" ]
        (ProjectUrl "xG.html")
        NoLink
    , Project
        "Soccer event logger"
        [ "Collect your own soccer event-data" ]
        (ProjectUrl "tracker.html")
        (GithubUrl "elm-soccer-tracker")
    , Project
        "XGEEFAX"
        [ "CEEFAX, but with xG" ]
        (ExternalUrl "https://twitter.com/XGEEFAX")
        NoLink
    , Project
        "FPL optimiser twitter bot"
        [ "A twitter bot posting the best possible Fantasy Premier League lineup each week" ]
        (ExternalUrl "https://twitter.com/fpl_optimiser")
        NoLink
    , Project
        "Stats and Snakeoil"
        [ "A Soccer Analytics Blog" ]
        (ExternalUrl "http://www.statsandsnakeoil.com")
        NoLink
    , Project
        "regista"
        [ "An R package for soccer modelling" ]
        (ProjectUrl "regista")
        (GithubUrl "regista")
    , Project
        "ggsoccer"
        [ "An R package for plotting event data with ggplot2" ]
        (ProjectUrl "ggsoccer")
        (GithubUrl "ggsoccer")
    , Project
        "soccerstan"
        [ "A collection of team strength models implemented in Stan" ]
        NoLink
        (GithubUrl "soccerstan")
    , Project
        "Human language model"
        [ "Test your language model on a given text corpus" ]
        (ProjectUrl "human-language-model.html")
        (GithubUrl "human-language-model")
    , Project
        "The Duck Debugger"
        [ "Stuck on a problem? Talk to the duck!" ]
        (ProjectUrl "duck-debugger.html")
        (GithubUrl "duck-debugger")
    , Project
        "Flow solver"
        ["Solving the 'Flow Free' puzzle game with SAT and Clojure"]
        (ProjectUrl "flow-solver.html")
        (GithubUrl "flow-solver")
    , Project
        "Chaos game"
        [ "Explore interesting patterns arising from some simple rules" ]
        (ProjectUrl "chaosgame.html")
        (GithubUrl "elm-chaos-game")
    , Project
        "How to pick a number from 1-10 (Human RNG)"
        [ "How could we generate uniform random numbers from human suggestions?" ]
        (ProjectUrl "human-rng.html")
        NoLink
    , Project
        "Terminal Snake"
        ["Play snake in the terminal! A Haskell project"]
        NoLink
        (GithubUrl "terminal-snake")
    , Project
        "Messenger and army puzzle"
        [ "Explore a popular puzzle the intuitive way!" ]
        (ProjectUrl "messenger-army-puzzle.html")
        NoLink
    , Project
        "Wolf and Hare (2 player game)"
        [ "A 2-player game in which the starting player can only win if the opponent makes a mistake" ]
        (ProjectUrl "wolf-and-hare.html")
        (GithubUrl "wolf-and-hare")
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Torvaney | Home"
    , body =
        [ layout [] <|
            row [ centerX ]
                [ column [ width (fillPortion 1) ] []
                , column
                    [ width (fillPortion 6)
                    , spacing 10
                    ]
                    [ el [Font.bold, Font.size 32] (text "torvaney.github.io")
                    , paragraph []
                        [ text "Some projects and things that I have done" ]
                    , wrappedRow [ spacing 8 ] <|
                        List.map viewProject model.projects
                    ]
                , column [ width (fillPortion 1) ] []
                ]
        ]
    }


viewProject : Project -> Element Msg
viewProject project =
    column
        [ Background.color (gray 1)
        , Border.color (gray 0.5)
        , Border.rounded 5
        , Border.width 1
        , spacing 5
        , padding 10
        , width (px 300)
        , height (px 200)
        ]
        [ paragraph
            [ height (fillPortion 1)
            , padding 2
            , Font.bold
            ]
            [ text project.name ]
        , paragraph
            [ height (fillPortion 4)
            , padding 2
            , Font.size 14
            ]
            (List.map text project.description)
        , row
            [ height (fillPortion 1), width fill ]
            [ Element.el [ alignLeft ]
                (viewLink  [ Font.color (gray 0.5) ] "source" project.code)
            , Element.el [ alignRight ]
                (viewLink [ Background.color pink, Border.color (gray 0) ] " → " project.link)
            ]
        ]


viewLink : List (Attribute Msg) -> String -> Link -> Element Msg
viewLink attrs label link =
    let defaultAttrs = [ Background.color (gray 1)
                , Border.color (gray 0.5)
                , Border.rounded 10
                , Border.width 1
                , padding 5
                ]
    in
    case link of
        NoLink ->
            none

        _ ->
            el
                (defaultAttrs ++ attrs)
                (Element.link [] { url = getUrl link, label = text label })


getUrl : Link -> String
getUrl link =
    case link of
        ProjectUrl x ->
            Url.Builder.relative [ "projects", x ] []

        GithubUrl x ->
            Url.Builder.crossOrigin "https://github.com" [ "torvaney", x ] []

        ExternalUrl url ->
            url

        NoLink ->
            -- TODO
            "TODO"


pink =
    rgb 1 0.9 0.9

gray x =
    rgb x x x
