module Main exposing (..)

import Browser
import Debug
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, at, bool, index, map4, string, list)


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
    , offensive : Bool
    }
type alias Alternatives = List String
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
                { expect = Http.expectJson GotDef defDecoder
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
    if (index 0 (at [ "shortdef" ] (index 0 string))) == Err then
    map4 Definition
        (index 0 (at [ "meta", "app-shortdef", "hw" ] string))
        (index 0 (at [ "meta", "app-shortdef", "fl" ] string))
        (index 0 (at [ "shortdef" ] (index 0 string)))
        (index 0 (at [ "meta", "offensive" ] bool))
    else 
        Json.Decode.list string

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

        Success d ->
            div []
                [ div [] [ text d.word ]
                , div [] [ text d.fl ]
                , div [] [ text d.def ]
                , div [] [ checkOffense d.offensive ]
                ]

        Failure error ->
            text (Debug.toString error)


checkOffense : Bool -> Html msg
checkOffense b =
    if b == True then
        text "Offensive: true"

    else
        text "Offensive: false"
