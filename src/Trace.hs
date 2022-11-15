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
import           Data.Text              (Text)
import           Ledger                 (CurrencySymbol)
import qualified Plutus.Contract        as Contract
import qualified Plutus.Trace.Emulator  as Emulator
import           PlutusTx.Prelude       hiding (Semigroup (..), unless)
import           Prelude                (IO)
import           Token.OffChain
import           Wallet.Emulator.Wallet

testToken :: IO ()
testToken = Emulator.runEmulatorTraceIO tokenTrace

tokenTrace :: Emulator.EmulatorTrace ()
tokenTrace = do
    let w1 = knownWallet 1
        params =  TokenParams
          { tpToken   = "USDT"
          , tpAddress = mockWalletAddress w1
          }
        contract :: Contract.Contract ()  MintSchema Text CurrencySymbol
        contract = mintToken params
    void $ Emulator.activateContractWallet w1 $ void contract
