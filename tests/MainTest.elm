module MainTest exposing (..)

import Expect exposing (equal)
import Json.Decode
import Main exposing (respDecoder)
import Test exposing (..)


suite : Test
suite =
    describe "The decoders"
        [ describe "Definition decoder"
            [ test "find according fields" <|
                \_ ->
                    let
                        input =
                            """
                            [{ "meta": 
                                { "app-shortdef" : 
                                    { "hw" : "apple", "fl" : "noun" }
                                , "offensive" : false
                                }
                            , "shortdef" : ["a kind of fruit"]
                            }]
                        
                            """

                        expected =
                            Result.Ok
                                (Main.Def
                                    { word = "apple"
                                    , fl = "noun"
                                    , def = "a kind of fruit"
                                    , isOffensive = False
                                    }
                                )

                        actual =
                            Json.Decode.decodeString respDecoder input
                    in
                    Expect.equal expected actual
            ]
        ,
        describe "Alternatives decoder"
            [ test "decode correctly" <|
                \_ ->
                    let
                        input =
                            """
                            ["boy", "coy", "ploy", "soya"]
                            """

                        expected =
                            Result.Ok
                                (Main.Alt
                                    { first = "boy"
                                    , second = "coy"
                                    , third = "ploy"
                                    , fourth = "soya"
                                    }
                                )

                        actual =
                            Json.Decode.decodeString respDecoder input
                    in
                    Expect.equal expected actual
            ]
        ]
    