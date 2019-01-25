module DecodeAbiBeta exposing (..)

-- import Fuzz exposing (Fuzzer, int, list, string)

import BigInt exposing (BigInt)
import Expect
import Test exposing (..)
import Abi.Decode as Abi


-- arrayOfString : Test
-- arrayOfString =
--     describe "Array of String Decoding"
--         [ test "decode ComplexStorageBeta.arrayOfStrings()" <|
--             \_ ->
--                 Abi.fromString arrayOfStringDecoder arrayOfStringsData
--                     |> Expect.equal arrayOfStringExpect
--         ]
-- arrayOfStringDecoder : Abi.AbiDecoder (List String)
-- arrayOfStringDecoder =
--     Abi.dynamicArray Abi.string
-- arrayOfStringExpect : Result String (List String)
-- arrayOfStringExpect =
--     Ok [ "testingthisshouldbequiteabitlongerthan1word", "shorter", "s" ]
-- arrayOfStringsData : String
-- arrayOfStringsData =
--     "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000002b74657374696e677468697373686f756c6462657175697465616269746c6f6e6765727468616e31776f7264000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000773686f727465720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017300000000000000000000000000000000000000000000000000000000000000"
--
-- 0000000000000000000000000000000000000000000000000000000000000020 -- 0    -   Dyn Array starts at hex 32
-- 0000000000000000000000000000000000000000000000000000000000000003 -- 32   -   Dyn Array is 3 long
-- 0000000000000000000000000000000000000000000000000000000000000060 -- 64   -   1st element (string) starts at 96
-- 00000000000000000000000000000000000000000000000000000000000000c0 -- 96   -   2nd element (string) starts at 192
-- 0000000000000000000000000000000000000000000000000000000000000100 -- 128  -   3rd element (string) starts at 256
-- 000000000000000000000000000000000000000000000000000000000000002b -- 160  -   43 hex-length data
-- 74657374696e677468697373686f756c6462657175697465616269746c6f6e6765727468616e31776f7264000000000000000000000000000000000000000000 -- 192 & 224 - 43 char hex string plus padding ("testingthisshouldbequiteabitlongerthan1word")
-- 0000000000000000000000000000000000000000000000000000000000000007 -- 256  -   7 hex-length data
-- 73686f7274657200000000000000000000000000000000000000000000000000 -- 288  -   7 char hex string plus padding ("shorter")
-- 0000000000000000000000000000000000000000000000000000000000000001 -- 318  -   1 hex-length data
-- 7300000000000000000000000000000000000000000000000000000000000000 -- 340  -   1 char hex string plus padding ("s")
{--}
---------------------------------------------------------------------------------------------
-- arrayOfBytes : Test
-- arrayOfBytes =
--     describe "Array of String Decoding"
--         [ test "decode ComplexStorageBeta.arrayOfStrings()" <|
--             \_ ->
--                 Abi.fromString arrayOfStringDecoder arrayOfStringsData
--                     |> Expect.equal arrayOfStringExpect
--         ]
-- arrayOfBytesDecoder : Abi.AbiDecoder (List String)
-- arrayOfBytesDecoder =
--     Abi.dynamicArray Abi.dynamicBytes
-- arrayOfBytesExpect : Result String (List String)
-- arrayOfBytesExpect =
--     Ok [ "testingthisshouldbequiteabitlongerthan1word", "shorter", "s" ]


arrayOfBytesData : String
arrayOfBytesData =
    "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000002b74657374696e677468697373686f756c6462657175697465616269746c6f6e6765727468616e31776f7264000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000773686f727465720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017300000000000000000000000000000000000000000000000000000000000000"
