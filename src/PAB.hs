{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module PAB
    ( Address
    , TokenContracts (..)
    ) where

import           Data.Aeson                          (FromJSON, ToJSON)
import           Data.OpenApi.Schema                 (ToSchema)
import           GHC.Generics                        (Generic)
import           Ledger                              (Address)
import           Plutus.PAB.Effects.Contract.Builtin (Empty,
                                                      HasDefinitions (..),
                                                      SomeBuiltin (..),
                                                      endpointsToSchemas)
import           Prettyprinter                       (Pretty (..), viaShow)
import           Wallet.Emulator.Wallet              (knownWallet,
                                                      mockWalletAddress)

import qualified Monitor
import qualified Plutus.V1.Ledger.Credential         as V1.Credential
import qualified Schema
import qualified Token.OffChain                      as Token

data TokenContracts = Mint Token.TokenParams
                    | Monitor Address
    deriving (Eq, Ord, Show, Generic, FromJSON, ToJSON, ToSchema)

-- instance Schema.ToSchema Token.TokenParams

instance Pretty TokenContracts where
    pretty = viaShow

instance HasDefinitions TokenContracts where

    getDefinitions             = [Mint exampleTP, Monitor exampleAddr]

    getContract (Mint tp)      = SomeBuiltin $ Token.mintToken @() tp
    getContract (Monitor addr) = SomeBuiltin $ Monitor.monitor addr

    -- getSchema (Mint _)    = endpointsToSchemas @Empty  -- Token.MintSchema
    getSchema = const $ endpointsToSchemas @Empty

exampleAddr :: Address
exampleAddr = mockWalletAddress $ knownWallet 1

exampleTP :: Token.TokenParams
exampleTP = Token.TokenParams
    { Token.tpAddress = exampleAddr
    , Token.tpToken   = "PPP"
    }
