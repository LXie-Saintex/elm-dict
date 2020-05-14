module Styles exposing(..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)

theme : { secondary : Color, primary : Color }
theme = 
    { primary = hex "55af6a"
    , secondary = rgb 250 240 230
    }

btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button
        [ margin (px 12)
        , color (rgb 250 250 250)
        , hover
            [ backgroundColor theme.primary
            , textDecoration underline
            ]
        ]

normalDiv : List (Attribute msg) -> List (Html msg) -> Html msg
normalDiv = 
    styled div 
        [ padding (px 20)
        , color theme.primary 
        ]

largeInput : List (Attribute msg) -> List (Html msg) -> Html msg
largeInput = 
    styled input 
        [ fontSize (Css.em 1.2)
        , padding (px 30)
        , marginBottom (px 10)
        ]