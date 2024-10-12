module Main exposing (main)

import Browser
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder, Value)
import List as L


type alias Model =
    { files : List ( String, File )
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { files = [] }
    , Cmd.none
    )



-- Update


type Msg
    = DragOver
    | DragLeave
    | OnFiles (List ( String, File ))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        DragOver ->
            ( model, Cmd.none )

        DragLeave ->
            ( model, Cmd.none )

        OnFiles files ->
            ( { model | files = files }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    let
        dzAttrs_ =
            [ onDragOver DragLeave
            , onDragLeave DragOver
            , onDropRequestFileTree NoOp
            , onFileTree OnFiles
            ]

        viewFile_ : ( String, File ) -> Html Msg
        viewFile_ ( n, f ) =
            li []
                [ text n
                , span [] [ text <| " (" ++ (String.fromInt <| File.size f) ++ ")" ]
                ]
    in
    div []
        [ ul [] <| L.map viewFile_ model.files
        , div (id "dz" :: class "drop-zone" :: dzAttrs_) [ text "Drop File or Directory Here" ]
        ]


onDragOver : msg -> Attribute msg
onDragOver =
    onPreventDefault "dragover"


onDragLeave : msg -> Attribute msg
onDragLeave msgCreator =
    onPreventDefault "dragleave" msgCreator


onPreventDefault : String -> a -> Attribute a
onPreventDefault evt msgCreator =
    Events.preventDefaultOn evt (Decode.succeed ( msgCreator, True ))


{-| We attach a drop listener and request the `fileTree` field of the event.
This causes our custom code to run, which results in a custom "fileTree" event
-}
onDropRequestFileTree : msg -> Attribute msg
onDropRequestFileTree noop =
    Events.preventDefaultOn "drop"
        (Decode.map (\_ -> ( noop, True )) (Decode.field "fileTree" <| Decode.fail "I just needed to trigger this"))


{-| This custom event contains the data we want
-}
onFileTree : (List ( String, File ) -> msg) -> Attribute msg
onFileTree msgCreator =
    Events.on "fileTree"
        (Decode.map msgCreator (Decode.field "detail" <| Decode.list decEntry))


decEntry : Decoder ( String, File )
decEntry =
    Decode.map2 Tuple.pair
        (Decode.field "path" Decode.string)
        (Decode.field "file" File.decoder)



-- Program


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
