{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}

{-|
Module      : Monitor
Description : Shamesly stolen from plutus-pioneer lecture 6
Stability   : experimental
Portability : POSIX

@Monitors@ given addres for changes.
-}
module Monitor
    ( monitor
    ) where

import           Data.Functor    (void)
import qualified Data.Map        as Map
import           Data.Monoid     (Last (..))
import           Data.Text       (Text)
import           Ledger
import           Plutus.Contract as Contract
import           Text.Printf     (printf)

monitor :: Address -> Contract (Last Value) Empty Text a
monitor addr = do
    Contract.logInfo @String $ printf "started monitoring address %s" $ show addr
    go
  where
    go = do
        utxos <- utxosAt addr
        let v = Map.foldl' (\w o -> w <> _ciTxOutValue o) mempty utxos
        tell $ Last $ Just v
        void $ waitNSlots 1
        go
