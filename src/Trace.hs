{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE NumericUnderscores    #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}

module Trace
    ( testToken
    , tokenTrace
    ) where

import           Control.Monad          hiding (fmap)
import           Plutus.Contract        as Contract
import           Plutus.Trace.Emulator  as Emulator
import           PlutusTx.Prelude       hiding (Semigroup (..), unless)
import           Prelude                (IO)
import           Wallet.Emulator.Wallet

import           Token.OffChain

testToken :: IO ()
testToken = runEmulatorTraceIO tokenTrace

tokenTrace :: EmulatorTrace ()
tokenTrace = do
    let w1 = knownWallet 1
    void $ activateContractWallet w1 $ void $ mintToken @() @Empty TokenParams
        { tpToken   = "USDT"
        , tpAddress = mockWalletAddress w1
        }
