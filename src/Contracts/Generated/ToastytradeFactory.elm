module Contracts.Generated.ToastytradeFactory exposing
    ( NewToastytradeSell
    , createToastytradeSell
    , createdSells
    , getNumToastytradeSells
    , newToastytradeSellDecoder
    , newToastytradeSellEvent
    , tokenContract
    )

import Abi.Decode as AbiDecode exposing (abiDecode, andMap, data, toElmDecoder, topic)
import Abi.Encode as AbiEncode exposing (Encoding(..), abiEncode)
import BigInt exposing (BigInt)
import Eth.Types exposing (..)
import Eth.Utils as U
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline exposing (custom)



{-

   This file was generated by https://github.com/cmditch/elm-ethereum-generator

-}


{-| "createToastytradeSell(address,uint256,uint256,uint256,uint256,uint256,uint256,string)" function
-}
createToastytradeSell : Address -> Address -> BigInt -> BigInt -> BigInt -> BigInt -> BigInt -> BigInt -> String -> Call Address
createToastytradeSell contractAddress initiator sellAmount price responderDeposit autorecallInterval depositDeadlineInterval autoreleaseInterval logisticsString =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "createToastytradeSell(address,uint256,uint256,uint256,uint256,uint256,uint256,string)" [ AbiEncode.address initiator, AbiEncode.uint sellAmount, AbiEncode.uint price, AbiEncode.uint responderDeposit, AbiEncode.uint autorecallInterval, AbiEncode.uint depositDeadlineInterval, AbiEncode.uint autoreleaseInterval, AbiEncode.string logisticsString ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.address
    }


{-| "createdSells(uint256)" function
-}
createdSells : Address -> BigInt -> Call Address
createdSells contractAddress a =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "createdSells(uint256)" [ AbiEncode.uint a ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.address
    }


{-| "getNumToastytradeSells()" function
-}
getNumToastytradeSells : Address -> Call BigInt
getNumToastytradeSells contractAddress =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "getNumToastytradeSells()" []
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.uint
    }


{-| "tokenContract()" function
-}
tokenContract : Address -> Call Address
tokenContract contractAddress =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "tokenContract()" []
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.address
    }


{-| "NewToastytradeSell(uint256,address)" event
-}
type alias NewToastytradeSell =
    { id : BigInt
    , toastytradeSellAddress : Address
    }


newToastytradeSellEvent : Address -> LogFilter
newToastytradeSellEvent contractAddress =
    { fromBlock = LatestBlock
    , toBlock = LatestBlock
    , address = contractAddress
    , topics = [ Just <| U.keccak256 "NewToastytradeSell(uint256,address)" ]
    }


newToastytradeSellDecoder : Decoder NewToastytradeSell
newToastytradeSellDecoder =
    succeed NewToastytradeSell
        |> custom (data 0 AbiDecode.uint)
        |> custom (data 1 AbiDecode.address)
