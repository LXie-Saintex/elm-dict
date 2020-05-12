module Main exposing (..)

import Browser
import Debug
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, at, bool, index, map, map4, oneOf, string)


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { status : AppStatus
    , url : String
    }


type AppStatus
    = Initial
    | Failure Http.Error
    | Success Response


type alias Definition =
    { word : String
    , fl : String
    , def : String
    , isOffensive : Bool
    }


type alias Alternatives =
    { first : String
    , second : String
    , third : String
    , fourth : String
    }


type Response
    = Def Definition
    | Alt Alternatives


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = Initial, url = "" }
    , Cmd.none
    )


type Msg
    = Search
    | NewContent String
    | GotDef (Result Http.Error Response)
    | GotProgress Http.Progress

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model
            , Http.request
                    { method = "GET"
                    , headers = []
                    , url = model.url
                    , body = Http.emptyBody
                    , expect = Http.expectJson GotDef respDecoder
                    , timeout = Just 2000.0
                    , tracker = Just "word"
                    }
            )

        NewContent s ->
            let
                root =
                    "https://www.dictionaryapi.com/api/v3/references/learners/json/"

                key =
                    "24375962-78c5-4fbc-a585-b37ed4088caf"

                request : String -> String
                request word =
                    root ++ word ++ "?key=" ++ key
            in
            ( { model | url = request s }, Cmd.none )

        GotDef result ->
            case result of
                Ok def ->
                    ( { model | status = Success def }, Cmd.none )

                Err error ->
                    ( { model | status = Failure error }, Cmd.none )

        GotProgress p -> 
            case p of 
                Http.Sending track -> 
                    if Http.fractionSent track /= 0.0 then 
                    (model, Http.cancel "word")
                    else 
                    (model, Cmd.none)

                Http.Receiving track -> 
                    (model, Cmd.none)

defDecoder : Decoder Response
defDecoder =
    Decode.map Def
        (map4 Definition
            (index 0 (at [ "meta", "app-shortdef", "hw" ] string))
            (index 0 (at [ "meta", "app-shortdef", "fl" ] string))
            (index 0 (at [ "shortdef" ] (index 0 string)))
            (index 0 (at [ "meta", "offensive" ] bool))
        )


altDecoder : Decoder Response
altDecoder =
    Decode.map Alt
        (map4 Alternatives
            (index 0 string)
            (index 1 string)
            (index 2 string)
            (index 3 string)
        )


respDecoder : Decoder Response
respDecoder =
    oneOf
        [ defDecoder
        , altDecoder
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Dictionary"
    , body =
        [ div []
            [ div [] [ text "Elm Dictionary" ]
            , viewInput "text" NewContent
            , button [ onClick Search, attribute "data-cy" "submit"] [ text "Search" ]
            , viewResult model
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Http.track "word" GotProgress


viewInput : String -> (String -> Msg) -> Html Msg
viewInput t toMsg =
    input [ type_ t, onInput toMsg, attribute "data-cy" "input" ] []


viewResult : Model -> Html Msg
viewResult model =
    case model.status of
        Initial ->
            div [] [ text "" ]

        Success resp ->
            case resp of
                Def d ->
                    div []
                        [ div [ attribute "data-cy" "word" ] [ text d.word ]
                        , div [ attribute "data-cy" "fl" ] [ text d.fl ]
                        , div [ attribute "data-cy" "def" ] [ text d.def ]
                        , div [ attribute "data-cy" "isOffensive" ] [ checkOffense d.isOffensive ]
                        ]

                Alt a ->
                    div []
                        [ text "Did you mean: "
                        , div [] [ text a.first ]
                        , div [] [ text a.second ]
                        , div [] [ text a.third ]
                        , div [] [ text a.fourth ]
                        ]

        Failure error ->
            case error of 
                Http.BadBody _->     
                    div [ attribute "data-cy" "msg"] [ text "Invalid entries"  ]

                Http.NetworkError -> 
                    div [ attribute "data-cy" "msg"] [text "No internet connection" ]
                
                Http.BadStatus _ -> 
                    div [ attribute "data-cy" "msg"] [text "Something's wrong with Merriam-Webster API, try later?" ]

                Http.BadUrl _ -> 
                    div [ attribute "data-cy" "msg"] [text "URL invalid" ]
                
                Http.Timeout -> 
                    div [ attribute "data-cy" "msg"] [text "Time out, try again?" ]
                

checkOffense : Bool -> Html msg
checkOffense b =
    if b == True then
        text "Offensive: true"

    else
        text "Offensive: false"
