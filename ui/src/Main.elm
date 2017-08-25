module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Routing exposing (Route)
import Navigation exposing (Location)
import Dom.Scroll as Scroll
import Task


type Msg
    = Input String
    | Send
    | NewMessage String
    | OnLocationChange Location
    | NoOp


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
            , Task.attempt (always NoOp) <| Scroll.toBottom "chat"
            )

        OnLocationChange location ->
            ( { model
                | route = Routing.parseLocation location
                , location = location
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



--auto scroll:
-- var objDiv = document.getElementById("chat");
-- objDiv.scrollTop = objDiv.scrollHeight;


view : Model -> Html Msg
view model =
    div
        [ class "mdc-typography app" ]
        [ div [ hidden True ]
            [ model |> toString |> text ]
        , div
            [ class "mdc-layout-grid chat"
            , id "chat"
            ]
            [ div
                [ class "mdc-layout-grid__inner" ]
                [ div
                    [ class "mdc-layout-grid__cell mdc-layout-grid__cell--span-12" ]
                    [ ul
                        [ class "mdc-list mdc-list--avatar-list" ]
                        (List.map viewMessage (List.reverse model.messages))
                    ]
                ]
            ]
        , Html.form
            [ onSubmit Send ]
            [ div
                [ class "mdc-layout-grid footer" ]
                [ div
                    [ class "mdc-layout-grid__inner" ]
                    [ div
                        [ class "mdc-layout-grid__cell mdc-layout-grid__cell--span-12" ]
                        [ div
                            [ class "mdc-textfield msg-input"
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
                        , button
                            [ type_ "submit"
                            , class "mdc-button mdc-button--raised mdc-button--accent"
                            ]
                            [ text "Send" ]
                        ]
                    ]
                ]
            ]
        ]


viewMessage : String -> Html Msg
viewMessage msg =
    li
        [ class "mdc-list-item msg" ]
        [ img
            [ class "md-list-item__start-detail"
            , src "https://material-components-web.appspot.com/images/animal1.svg"
            , width 56
            , height 56
            , style [ ( "margin-right", "16px" ) ]
            , alt "Avatar"
            ]
            []
        , text msg
        ]


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
