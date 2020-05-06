module Main exposing (..)

import Browser
import Debug
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (resolve)


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


type alias Alternatives =
    List String


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
    let
        toDecoder : String -> String -> String -> Bool -> Decoder Response
        toDecoder shortDef hw fl isOffensive =
            Definition shortDef fl hw isOffensive
                |> Def
                |> Decode.succeed
    in
    Decode.succeed toDecoder
        |> Pipeline.required "shortdef" Decode.string
        |> Pipeline.requiredAt [ "meta", "app-shortdef", "hw" ] Decode.string
        |> Pipeline.requiredAt [ "meta", "app-shortdef", "fl" ] Decode.string
        |> Pipeline.requiredAt [ "meta", "offensive" ] Decode.bool
        |> resolve


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
subscriptions _ =
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
                Def def ->
                    div []
                        [ div [] [ text def.word ]
                        , div [] [ text def.fl ]
                        , div [] [ text def.def ]
                        , div [] [ checkOffense def.offensive ]
                        ]

                Alt _ ->
                    div [] []

        Failure error ->
            text (Debug.toString error)


checkOffense : Bool -> Html msg
checkOffense b =
    if b == True then
        text "Offensive: true"

    else
        text "Offensive: false"
