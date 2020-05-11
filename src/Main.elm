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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model
            , Http.get
                { expect = Http.expectJson GotDef respDecoder
                , url = model.url
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
            , button [ onClick Search ] [ text "Search" ]
            , viewResult model
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


viewInput : String -> (String -> Msg) -> Html Msg
viewInput t toMsg =
    input [ type_ t, onInput toMsg ] []


viewResult : Model -> Html Msg
viewResult model =
    case model.status of
        Initial ->
            div [] [ text "" ]

        Success resp ->
            case resp of
                Def d ->
                    div []
                        [ div [] [ text d.word ]
                        , div [] [ text d.fl ]
                        , div [] [ text d.def ]
                        , div [] [ checkOffense d.isOffensive ]
                        ]

                Alt a ->
                    div []
                        [ div [] [ text a.first ]
                        , div [] [ text a.second ]
                        , div [] [ text a.third ]
                        , div [] [ text a.fourth ]
                        ]

        Failure error ->
            text (Debug.toString error)


checkOffense : Bool -> Html msg
checkOffense b =
    if b == True then
        text "Offensive: true"

    else
        text "Offensive: false"
