module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Routing exposing (Route)
import Navigation exposing (Location)
import Dom.Scroll as Scroll
import Task
import Markdown
import Json.Decode as Json
import CircularList exposing (CircularList)


type Msg
    = Input String
    | Send
    | NewMessage String
    | RotateAvatar
    | OnLocationChange Location
    | ClearInput
    | NoOp


type alias Model =
    { input : String
    , messages : List (Html Msg)
    , location : Location
    , route : Route
    , avatar : CircularList String
    }


echoServer : String
echoServer =
    "ws://localhost:8081/ws"


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model
        ""
        []
        location
        (Routing.parseLocation location)
        (CircularList.fromList
            "https://material-components-web.appspot.com/images/animal1.svg"
            [ "https://material-components-web.appspot.com/images/animal2.svg"
            , "https://material-components-web.appspot.com/images/animal3.svg"
            ]
        )
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

        ClearInput ->
            ( { model | input = "" }, Cmd.none )

        Send ->
            ( { model
                | input = ""
              }
            , Cmd.batch
                [ WebSocket.send echoServer model.input
                , sendMsg ClearInput -- clear input as next message because the "\n" gets deliverd as Input right after this
                ]
            )

        NewMessage str ->
            ( { model
                | messages = (Markdown.toHtmlWith markdownParserOptions [] str) :: model.messages
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

        RotateAvatar ->
            ( { model | avatar = CircularList.next <| model.avatar }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


markdownParserOptions : Markdown.Options
markdownParserOptions =
    { githubFlavored = Just { tables = True, breaks = True }
    , defaultHighlighting = Nothing
    , sanitize = True
    , smartypants = False
    }


sendMsg : msg -> Cmd msg
sendMsg message =
    Task.perform identity (Task.succeed message)


onShiftEnterHandler : Attribute Msg
onShiftEnterHandler =
    let
        tagger ( code, shift ) =
            if code == 13 && (not shift) then
                Send
            else
                NoOp

        keyExtractor =
            Json.map2 (,)
                (Json.field "keyCode" Json.int)
                (Json.field "shiftKey" Json.bool)
    in
        on "keydown" <| Json.map tagger keyExtractor


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
                        [ img
                            [ class "md-list-item__start-detail"
                            , src <| CircularList.get <| model.avatar
                            , onClick RotateAvatar
                            , width 56
                            , height 56
                            , style [ ( "margin-right", "16px" ), ( "vertical-align", "bottom" ) ]
                            , alt "Avatar"
                            ]
                            []
                        , div
                            [ class "mdc-textfield mdc-textfield--multiline mdc-textfield--upgraded msg-input-container" ]
                            [ textarea
                                [ onShiftEnterHandler
                                , onInput Input
                                , class "mdc-textfield__input msg-input"
                                , id "demo-input"
                                , rows <| countNewLines model.input
                                , placeholder "What's on your mind?"
                                , value model.input
                                ]
                                []
                            ]
                        , button
                            [ type_ "submit"
                            , class "mdc-button mdc-button--raised mdc-button--accent"
                            , style
                                [ ( "vertical-align", "bottom" )
                                , ( "margin-bottom", "8px" )
                                ]
                            ]
                            [ text "Send" ]
                        ]
                    ]
                ]
            ]
        ]


countNewLines : String -> Int
countNewLines input =
    String.lines input |> List.length


viewMessage : Html Msg -> Html Msg
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
        , msg
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen
        (locationToWsUrl model.location)
        NewMessage


locationToWsUrl : Location -> String
locationToWsUrl location =
    let
        wsProtocol =
            if (String.contains "https" location.protocol) then
                "wss"
            else
                "ws"
    in
        String.concat
            [ wsProtocol
            , "://"
            , location.host
            , "/ws"
            ]


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
