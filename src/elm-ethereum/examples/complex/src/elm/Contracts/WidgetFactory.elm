module Contracts.WidgetFactory
    exposing
        ( newWidget
        , sellWidget
        , widgetCount
        , Widget
        , widgets
        , widgetsDecoder
        , WidgetCreated
        , widgetCreatedEvent
        , widgetCreatedDecoder
        , WidgetSold
        , widgetSoldEvent
        , widgetSoldDecoder
        )

import BigInt exposing (BigInt)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, decode)
import Eth.Types exposing (..)
import Eth.Utils as U
import Abi.Decode as AbiDecode exposing (abiDecode, andMap, toElmDecoder, topic, data)
import Abi.Encode as AbiEncode exposing (Encoding(..), abiEncode)


{-

   This file was generated by https://github.com/cmditch/elm-ethereum-generator

-}


{-| "newWidget(uint256,uint256,address)" function
-}
newWidget : Address -> BigInt -> BigInt -> Address -> Call ()
newWidget contractAddress size_ cost_ owner_ =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "newWidget(uint256,uint256,address)" [ AbiEncode.uint size_, AbiEncode.uint cost_, AbiEncode.address owner_ ]
    , nonce = Nothing
    , decoder = Decode.succeed ()
    }


{-| "sellWidget(uint256)" function
-}
sellWidget : Address -> BigInt -> Call ()
sellWidget contractAddress id_ =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "sellWidget(uint256)" [ AbiEncode.uint id_ ]
    , nonce = Nothing
    , decoder = Decode.succeed ()
    }


{-| "widgetCount()" function
-}
widgetCount : Address -> Call BigInt
widgetCount contractAddress =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "widgetCount()" []
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.uint
    }


{-| "widgets(uint256)" function
-}
type alias Widget =
    { id : BigInt
    , size : BigInt
    , cost : BigInt
    , owner : Address
    , wasSold : Bool
    }


widgets : Address -> BigInt -> Call Widget
widgets contractAddress a =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "widgets(uint256)" [ AbiEncode.uint a ]
    , nonce = Nothing
    , decoder = widgetsDecoder
    }


widgetsDecoder : Decoder Widget
widgetsDecoder =
    abiDecode Widget
        |> andMap AbiDecode.uint
        |> andMap AbiDecode.uint
        |> andMap AbiDecode.uint
        |> andMap AbiDecode.address
        |> andMap AbiDecode.bool
        |> toElmDecoder


{-| "WidgetCreated(uint256,uint256,uint256,address)" event
-}
type alias WidgetCreated =
    { id : BigInt
    , size : BigInt
    , cost : BigInt
    , owner : Address
    }


widgetCreatedEvent : Address -> LogFilter
widgetCreatedEvent contractAddress =
    { fromBlock = LatestBlock
    , toBlock = LatestBlock
    , address = contractAddress
    , topics = [ Just <| U.keccak256 "WidgetCreated(uint256,uint256,uint256,address)" ]
    }


widgetCreatedDecoder : Decoder WidgetCreated
widgetCreatedDecoder =
    decode WidgetCreated
        |> custom (data 0 AbiDecode.uint)
        |> custom (data 1 AbiDecode.uint)
        |> custom (data 2 AbiDecode.uint)
        |> custom (data 3 AbiDecode.address)


{-| "WidgetSold(uint256)" event
-}
type alias WidgetSold =
    { id : BigInt }


widgetSoldEvent : Address -> LogFilter
widgetSoldEvent contractAddress =
    { fromBlock = LatestBlock
    , toBlock = LatestBlock
    , address = contractAddress
    , topics = [ Just <| U.keccak256 "WidgetSold(uint256)" ]
    }


widgetSoldDecoder : Decoder WidgetSold
widgetSoldDecoder =
    decode WidgetSold
        |> custom (data 0 AbiDecode.uint)