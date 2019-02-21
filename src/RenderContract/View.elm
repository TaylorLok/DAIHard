module RenderContract.View exposing (render)

import Contracts.Types
import Element
import Element.Background
import Element.Border
import Element.Font
import ElementHelpers as EH
import Eth.Utils
import Flip exposing (flip)
import Maybe.Extra
import RenderContract.Types exposing (..)
import Time
import TimeHelpers
import TokenValue exposing (TokenValue)


render : ViewMode -> Contracts.Types.FullParameters -> Element.Element Msg
render viewMode parameters =
    let
        postCommitBalance =
            TokenValue.add parameters.uncoiningAmount parameters.responderDeposit

        claimFailBurnAmount =
            TokenValue.divByInt parameters.responderDeposit 2

        totalTime =
            TimeHelpers.add parameters.autorecallInterval parameters.depositDeadlineInterval
                |> TimeHelpers.add parameters.autoreleaseInterval

        titleElement =
            Element.column [ Element.centerX ]
                [ Element.el
                    [ Element.Font.size 42
                    , Element.centerX
                    ]
                    (Element.text "Uncoining Contract")
                , case viewMode of
                    Draft ->
                        Element.el [ Element.Font.size 36, Element.Font.light, Element.Font.italic, Element.centerX ]
                            (Element.text "Draft")

                    Active context ->
                        Element.el [ Element.Font.size 36, Element.Font.italic, Element.centerX ]
                            (Element.text (Contracts.Types.phaseToString context.state.phase))
                ]

        mainParametersElement =
            Element.column
                [ Element.Font.size 24
                , Element.Font.italic
                ]
                [ Element.paragraph []
                    [ EH.initiator []
                    , Element.text (": " ++ Eth.Utils.addressToString parameters.initiatorAddress)
                    ]
                , Element.paragraph []
                    [ Element.text "Trading "
                    , EH.tokenValue parameters.uncoiningAmount
                    , Element.text " for "
                    , EH.usdValue parameters.price
                    ]
                , Element.paragraph []
                    [ Element.text "to be finalized within "
                    , EH.timeValue totalTime
                    , Element.text " of contract creation."
                    ]
                ]
    in
    Element.el
        [ Element.paddingXY 10 0
        , Element.width Element.fill
        ]
        (Element.column
            [ Element.padding 60
            , Element.spacing 40
            , Element.Border.rounded 3
            , Element.Border.color EH.contractBorderColor
            , Element.Border.width 1
            , Element.width Element.fill
            , Element.Background.color EH.contractBackgroundColor
            , EH.contractShadowAttribute
            ]
            [ titleElement
            , mainParametersElement
            , openPhaseElement viewMode parameters
            , committedPhaseElement viewMode parameters postCommitBalance claimFailBurnAmount
            , claimedPhaseElement viewMode parameters postCommitBalance
            ]
        )


openPhaseElement : ViewMode -> Contracts.Types.FullParameters -> Element.Element Msg
openPhaseElement viewMode parameters =
    Element.column (phaseStyleWithViewMode Contracts.Types.Open viewMode)
        [ phaseHeading Contracts.Types.Open parameters viewMode
        , EH.clauseList
            [ Element.paragraph []
                [ Element.text "This contract is listed on "
                , EH.fakeLink "CoinerTool browse"
                , Element.text " (and possibly other third-party tools)."
                ]
            , Element.paragraph []
                [ Element.text "Any other Ethereum user may become the "
                , EH.responder []
                , Element.text " by depositing "
                , EH.tokenValue parameters.responderDeposit
                , Element.text " into this contract. This immediately moves the contract to the "
                , EH.sectionReference "Committed Phase"
                , Element.text ". Thenceforth, the identity of the "
                , EH.responder []
                , Element.text " will never change, and the "
                , EH.initiator []
                , Element.text " will be unable to "
                , EH.methodName "recall"
                , Element.text " the trade."
                ]
            , Element.paragraph []
                [ Element.text "Until and unless an Ethereum user "
                , EH.methodName "commit"
                , Element.text "s, the "
                , EH.initiator []
                , Element.text " may execute the "
                , EH.methodName "recall"
                , Element.text " method. This "
                , EH.sectionReference "cancels the contract"
                , Element.text " and refunds the "
                , EH.initiator []
                , Element.text "'s "
                , EH.tokenValue parameters.uncoiningAmount
                , Element.text ". "
                ]
            , Element.paragraph []
                [ Element.text "If no Ethereum user "
                , EH.methodName "commit"
                , Element.text "s within "
                , EH.timeValue parameters.autorecallInterval
                , Element.text ", "
                , EH.methodName "recall"
                , Element.text " will be automatically triggered."
                ]
            ]
        , case viewMode of
            Draft ->
                Element.none

            Active context ->
                if context.state.phase == Contracts.Types.Open then
                    Element.row [ Element.spacing 50, Element.padding 20, Element.centerX ]
                        (Maybe.Extra.values
                            [ if context.userIsInitiator then
                                Just <| EH.contractActionButton "Recall" EH.buttonBlue Recall

                              else
                                Nothing
                            , if not context.userIsInitiator then
                                Just <| EH.contractActionButton "Commit" EH.buttonBlue Commit

                              else
                                Nothing
                            ]
                        )

                else
                    Element.none
        ]


committedPhaseElement : ViewMode -> Contracts.Types.FullParameters -> TokenValue -> TokenValue -> Element.Element Msg
committedPhaseElement viewMode parameters postCommitBalance claimFailBurnAmount =
    Element.column (phaseStyleWithViewMode Contracts.Types.Committed viewMode)
        [ phaseHeading Contracts.Types.Committed parameters viewMode
        , EH.clauseList
            [ Element.paragraph []
                [ Element.text "The contract has two parties ("
                , EH.initiator []
                , Element.text " and "
                , EH.responder []
                , Element.text "), and a total balance of "
                , EH.tokenValue postCommitBalance
                , Element.text "."
                ]
            , Element.paragraph []
                [ Element.text "The "
                , EH.responder []
                , Element.text " is expected to transfer "
                , EH.usdValue parameters.price
                , Element.text " to the "
                , EH.initiator []
                , Element.text " according to the following "
                , EH.sectionReference "Fiat Transfer Methods"
                , Element.text ", then mark the deposit as complete by calling "
                , EH.methodName "claim"
                , Element.text ". This immediately moves the contract to the "
                , EH.sectionReference "Claimed Phase"
                , Element.text "."
                ]
            , fiatTransferMethodsElement parameters.transferMethods
            , Element.paragraph []
                [ Element.text "The "
                , EH.initiator []
                , Element.text " is expected to communicate any additional information the "
                , EH.responder []
                , Element.text " needs to complete the transfer (such as bank account numbers, contact info, etc.), either via CoinerTool's secure messaging or some other medium."
                ]
            , Element.paragraph []
                [ Element.text "If the "
                , EH.responder []
                , Element.text " does not claim within "
                , EH.timeValue parameters.depositDeadlineInterval
                , Element.text ", "
                , EH.sectionReference "the contract is closed"
                , Element.text ", and the balance of "
                , EH.tokenValue postCommitBalance
                , Element.text " is handled as follows:"
                , EH.clauseList
                    [ Element.paragraph []
                        [ Element.text "Half of the "
                        , EH.responder []
                        , Element.text "’s deposit ("
                        , EH.tokenValue claimFailBurnAmount
                        , Element.text ") is burned and half ("
                        , EH.tokenValue claimFailBurnAmount
                        , Element.text ") is returned to the "
                        , EH.responder []
                        , Element.text "."
                        ]
                    , Element.paragraph []
                        [ Element.text "The "
                        , EH.initiator []
                        , Element.text "’s original investment of "
                        , EH.tokenValue parameters.uncoiningAmount
                        , Element.text " is refunded."
                        ]
                    ]
                ]
            ]
        , case viewMode of
            Draft ->
                Element.none

            Active context ->
                if context.state.phase == Contracts.Types.Committed then
                    Element.row [ Element.spacing 50, Element.padding 20, Element.centerX ]
                        (if context.userIsResponder then
                            [ EH.contractActionButton "Claim" EH.buttonGreen Claim
                            ]

                         else
                            []
                        )

                else
                    Element.none
        ]


fiatTransferMethodsElement : String -> Element.Element Msg
fiatTransferMethodsElement transferMethodsString =
    Element.column [ Element.width Element.fill, Element.spacing 5 ]
        [ Element.el [ Element.Font.size 24, Element.Font.italic, Element.Font.bold ]
            (Element.text "Transfer Methods")
        , Element.el
            [ Element.Border.width 1
            , Element.Border.color EH.contractBorderColor
            , Element.Border.rounded 6
            , Element.Background.color EH.contractInsetBackgroundColor
            , Element.padding 10
            ]
            (Element.text transferMethodsString)
        ]


claimedPhaseElement : ViewMode -> Contracts.Types.FullParameters -> TokenValue -> Element.Element Msg
claimedPhaseElement viewMode parameters postCommitBalance =
    Element.column (phaseStyleWithViewMode Contracts.Types.Claimed viewMode)
        [ phaseHeading Contracts.Types.Claimed parameters viewMode
        , indentedElement
            (Element.column []
                [ Element.paragraph []
                    [ Element.text "During the "
                    , EH.sectionReference "Claimed Phase"
                    , Element.text ", the "
                    , EH.initiator []
                    , Element.text " is expected to "
                    , EH.methodName "release"
                    , Element.text " the contract's balance ("
                    , EH.tokenValue postCommitBalance
                    , Element.text ") to the "
                    , EH.responder []
                    , Element.text ", or if not, burn it. "
                    , Element.el [ Element.Font.bold ] (Element.text "At this point, in no case does the ")
                    , EH.initiator [ Element.Font.bold ]
                    , Element.el [ Element.Font.bold ] (Element.text " get a refund of his original investment. ")
                    , EH.fakeLink "why?"
                    ]
                , Element.paragraph [] [ Element.text "Specifically:" ]
                , EH.clauseList
                    [ Element.paragraph []
                        [ Element.text "The "
                        , EH.initiator []
                        , Element.text " is expected to verify with certainty whether the "
                        , EH.responder []
                        , Element.text " has irreversibly transferred at least "
                        , EH.usdValue parameters.uncoiningAmount
                        , Element.text " to the "
                        , EH.initiator []
                        , Element.text "."
                        ]
                    , Element.paragraph []
                        [ Element.text "If the transfer has taken place for at least "
                        , EH.usdValue parameters.uncoiningAmount
                        , Element.text ", the "
                        , EH.initiator []
                        , Element.text " is expected to execute the "
                        , EH.methodName "release"
                        , Element.text " method. This releases the entire balance of the contract ("
                        , EH.tokenValue postCommitBalance
                        , Element.text ") to the "
                        , EH.responder []
                        , Element.text " and closes the contract. Thus, the "
                        , EH.responder []
                        , Element.text " will have made a profit of ??? by servicing this Uncoining contract."
                        ]
                    , Element.paragraph []
                        [ Element.text "If the transfer has not taken place, or if the transfer amount was less than "
                        , EH.usdValue parameters.uncoiningAmount
                        , Element.text ", the "
                        , EH.initiator []
                        , Element.text " is expected to execute the "
                        , EH.methodName "burn"
                        , Element.text " method. This burns the entire balance of the contract ("
                        , EH.tokenValue postCommitBalance
                        , Element.text ") and "
                        , EH.sectionReference "closes the contract"
                        , Element.text ". Thus, the "
                        , EH.responder []
                        , Element.text " will have suffered a loss of "
                        , EH.tokenValue parameters.responderDeposit
                        , Element.text " for failing to make the deposit."
                        ]
                    , Element.paragraph []
                        [ Element.text "If the "
                        , EH.initiator []
                        , Element.text " is not sure whether the transfer has taken place, the "
                        , EH.initiator []
                        , Element.text " and the "
                        , EH.responder []
                        , Element.text " are expected to communicate to resolve any ambiguity."
                        ]
                    , Element.paragraph []
                        [ Element.text "If the "
                        , EH.initiator []
                        , Element.text " has not executed a "
                        , EH.methodName "burn"
                        , Element.text " or "
                        , EH.methodName "release"
                        , Element.text " within "
                        , EH.timeValue parameters.autoreleaseInterval
                        , Element.text ", "
                        , EH.methodName "release"
                        , Element.text " is triggered automatically."
                        ]
                    ]
                ]
            )
        , case viewMode of
            Draft ->
                Element.none

            Active context ->
                if context.state.phase == Contracts.Types.Claimed then
                    Element.row [ Element.spacing 50, Element.padding 20, Element.centerX ]
                        (Maybe.Extra.values
                            [ if context.userIsInitiator then
                                Just <| EH.contractActionButton "Release" EH.buttonGreen Release

                              else
                                Nothing
                            , if context.userIsInitiator then
                                Just <| EH.contractActionButton "Burn" EH.buttonRed Burn

                              else
                                Nothing
                            ]
                        )

                else
                    Element.none
        ]


phaseStyleWithViewMode : Contracts.Types.Phase -> ViewMode -> List (Element.Attribute a)
phaseStyleWithViewMode phase viewMode =
    case viewMode of
        Draft ->
            [ Element.width Element.fill
            ]

        Active context ->
            if context.state.phase == phase then
                [ Element.width Element.fill
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0 0 1)
                , Element.Background.color (Element.rgb 0.8 0.8 1)
                ]

            else
                [ Element.width Element.fill
                , Element.Font.color (Element.rgb 0.5 0.5 0.5)
                ]


phaseHeading : Contracts.Types.Phase -> Contracts.Types.FullParameters -> ViewMode -> Element.Element msg
phaseHeading phase parameters viewMode =
    let
        textElement =
            Element.paragraph [ Element.Font.size 30, Element.Font.bold ]
                (case viewMode of
                    Draft ->
                        [ Element.text "During the "
                        , Element.el [ Element.Font.italic ] (Element.text (Contracts.Types.phaseToString phase ++ " phase:"))
                        ]

                    Active context ->
                        [ Element.el [ Element.Font.italic ] (Element.text (Contracts.Types.phaseToString phase ++ " phase "))
                        , Element.el [ Element.Font.size 20 ] (Element.text (phaseCountdownString phase parameters context))
                        ]
                )
    in
    Element.column [ Element.spacing 30 ]
        [ textElement
        , Element.el [] Element.none
        ]


phaseCountdownString : Contracts.Types.Phase -> Contracts.Types.FullParameters -> ViewContext -> String
phaseCountdownString phase parameters context =
    if phase == context.state.phase then
        "("
            ++ EH.secondsRemainingString
                (TimeHelpers.add
                    context.state.phaseStartTime
                    (phaseInterval phase parameters)
                )
                context.currentTime
            ++ " left)"

    else
        ""


phaseInterval : Contracts.Types.Phase -> Contracts.Types.FullParameters -> Time.Posix
phaseInterval phase parameters =
    case phase of
        Contracts.Types.Created ->
            Time.millisToPosix 0

        Contracts.Types.Open ->
            parameters.autorecallInterval

        Contracts.Types.Committed ->
            parameters.depositDeadlineInterval

        Contracts.Types.Claimed ->
            parameters.autoreleaseInterval

        Contracts.Types.Closed ->
            Time.millisToPosix 0


indentedElement : Element.Element msg -> Element.Element msg
indentedElement element =
    Element.row [ Element.width Element.fill ]
        [ Element.el [ Element.width (Element.px 50) ] Element.none
        , Element.el [ Element.width Element.fill ] element
        ]
