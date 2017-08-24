module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Routing exposing (Route)
import Navigation exposing (Location)


type Msg
    = Input String
    | Send
    | NewMessage String
    | OnLocationChange Location


type alias Model =
    { input : String
    , messages : List String
    , location : Location
    , route : Route
    }


echoServer : String
echoServer =
    "ws://echo.websocket.org"


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model
        ""
        []
        location
        (Routing.parseLocation location)
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( { model
                | input = newInput
              }
            , Cmd.none
            )

        Send ->
            ( { model
                | input = ""
              }
            , WebSocket.send echoServer model.input
            )

        NewMessage str ->
            ( { model
                | messages = str :: model.messages
              }
            , Cmd.none
            )

        OnLocationChange location ->
            ( { model
                | route = Routing.parseLocation location
                , location = location
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div
        [ class "mdc-typography" ]
        [ div []
            [ model |> toString |> text ]
        , div []
            [ div [] (List.map viewMessage (List.reverse model.messages))
            ]
        , div
            [ class "mdc-layout-grid" ]
            [ div
                [ class "mdc-layout-grid__inner" ]
                [ div
                    [ class "mdc-layout-grid__cell mdc-layout-grid__cell--span-11" ]
                    [ div
                        [ class "mdc-textfield mdc-textfield--fullwidth"
                        , style [ ( "height", "40px" ) ]
                        ]
                        [ input
                            [ type_ "text"
                            , onInput Input
                            , class "mdc-textfield__input"
                            , id "demo-input"
                            , placeholder "What's on your mind?"
                            , value model.input
                            ]
                            []
                        ]
                    ]
                , div
                    [ class "mdc-layout-grid__cell mdc-layout-grid__cell--span-1" ]
                    [ button
                        [ onClick Send
                        , class "mdc-button mdc-button--raised mdc-button--accent"
                        ]
                        [ text "Send" ]
                    ]
                ]
            ]
        ]


viewMessage : String -> Html Msg
viewMessage msg =
    div []
        [ text msg ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen echoServer NewMessage


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
