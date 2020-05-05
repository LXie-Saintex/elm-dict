module Main exposing (..)

import Browser
import Html exposing (Html, div, text, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, string, map4, bool, index, at)
import Debug

main = Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view }

type Model
    = Initial
    | Failure Http.Error
    | Success Definition

init : () -> (Model, Cmd Msg)
init _ = 
    ( 
        Initial, Cmd.none 
    )
type alias Definition = 
    { word : String
    , fl : String
    , def : String
    , offensive : Bool
    }
type Msg 
    = Search String
    | NewContent String
    | GotDef (Result Http.Error Definition)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 

    Search url -> 
        (Initial
        , Http.get 
            { expect = Http.expectJson GotDef defDecoder
            , url = url
            }
        )
    
    NewContent newContent -> 
        let 
            root = "https://www.dictionaryapi.com/api/v3/references/learners/json/"
            key = "24375962-78c5-4fbc-a585-b37ed4088caf"
            request : String -> String
            request word = 
                root ++ word ++ "?" ++ key
        in
            (Initial, updateUrl (request newContent) )
    
    GotDef result -> 
        case result of 
        Ok def -> 
            (Success def, Cmd.none)
        Err error -> 
            (Failure error, Cmd.none)

updateUrl : String -> Msg
updateUrl s =  Search s
    
defDecoder : Decoder Definition
defDecoder = 
    map4 Definition
        (index 0 (at ["meta", "id"] string ))
        (index 0 (at ["meta", "app-shortdef", "fl"] string ))
        (index 0 (at ["meta", "app-shortdef", "def"] (index 0 string) ))
        (index 0 (at ["meta", "offensive"] bool ))


view : Model -> Html Msg
view model =
    div []
    [
        div[][ text "Elm Dictionary" ]
        , viewInput "text" "" NewContent
        , viewInput "submit" "search" Search
        , viewResult model
    ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

viewInput : String -> String -> Msg -> Html Msg
viewInput t v toMsg= 
    if t == "text" then input[ type_ t, value v, onInput toMsg] []
    else input[ type_ t, value v, onClick toMsg] []

viewResult : Model -> Html msg 
viewResult model = 
    case model of 
        Initial -> 
            div[][text ""]
        Success d -> 
            div[]
            [ div[][text(d.word)]
            , div[][text(d.fl)] 
            , div[][text(d.def)]
            , checkOffense d.offensive
            ]
        Failure error -> 
            text(Debug.toString(error))

checkOffense : Bool -> Html msg
checkOffense b =  
    if b == True then text "Offensive: true" else text "Offensive: false"
    