module View exposing (root)

import Browser
import Contracts.Types
import Create.View
import Element exposing (Attribute, Element)
import Element.Background
import Element.Border
import Element.Events
import Element.Font
import Element.Input
import ElementHelpers as EH
import Routing
import Search.View
import Types exposing (..)


root : Model -> Browser.Document Msg
root maybeValidModel =
    { title = "Toastytrade"
    , body =
        [ case maybeValidModel of
            Running model ->
                let
                    mainElementAttributes =
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , Element.Font.family
                            [ Element.Font.typeface "Soleil"
                            , Element.Font.sansSerif
                            ]
                        ]
                in
                Element.layout
                    mainElementAttributes
                    (pageElement model)

            Failed str ->
                Element.layout []
                    (Element.text ("ERROR: " ++ str))
        ]
    }


pageElement : ValidModel -> Element Msg
pageElement model =
    Element.column
        [ Element.behindContent <| headerBackground
        , Element.inFront <| headerContent model
        , Element.width Element.fill
        , Element.height Element.fill
        , Element.Background.color EH.pageBackgroundColor
        , Element.padding 30
        ]
        [ Element.el
            [ Element.height (Element.px 50) ]
            Element.none
        , subModelElement model
        ]


headerBackground : Element Msg
headerBackground =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px 150
        , Element.Background.color EH.headerBackgroundColor
        ]
        Element.none


headerContent : ValidModel -> Element Msg
headerContent model =
    Element.el
        [ Element.width Element.fill
        ]
        (Element.row
            [ Element.width Element.fill
            , Element.spacing 75
            ]
            [ logoElement
            , myOffersElement
            ]
        )


logoElement : Element Msg
logoElement =
    Element.el
        [ Element.Font.size 22
        , Element.Font.color EH.white
        , Element.Font.bold
        , Element.pointer
        , Element.padding 20
        , Element.Events.onClick <| GotoRoute Routing.Home
        ]
        (Element.text "DAI | HARD")


dropdownStyles : List (Attribute Msg)
dropdownStyles =
    [ Element.padding 10
    , Element.spacing 10
    , Element.Border.rounded 4
    , Element.Background.color <| Element.rgb 0.5 0.5 1
    ]


myOffersElement =
    Element.el
        headerMenuAttributes
        (Element.text "My Trades")


headerMenuAttributes : List (Attribute Msg)
headerMenuAttributes =
    [ Element.Font.size 19
    , Element.Font.color EH.white
    , Element.Font.semiBold
    , Element.padding 20
    , Element.pointer
    ]


subModelElement : ValidModel -> Element.Element Msg
subModelElement model =
    Element.el
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.Border.rounded 10
        ]
        (case model.submodel of
            HomeModel ->
                Element.none

            CreateModel createModel ->
                Element.map CreateMsg (Create.View.root createModel)

            -- InteractModel interactModel ->
            --     Element.map InteractMsg (Interact.View.root model.time interactModel)
            SearchModel searchModel ->
                Element.map SearchMsg (Search.View.root model.time searchModel)
        )