{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE NumericUnderscores    #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}

module Token.OnChain
    (
      tokenPolicy
    , tokenCurSymbol
    ,  MintParams (..)
    ) where

import           Ledger                                                hiding
                                                                       (mint,
                                                                        ownCurrencySymbol,
                                                                        singleton)
-- import qualified Ledger.Typed.Scripts                 as Scripts
import qualified Ledger.Value                                          as Value
import qualified Plutus.Script.Utils.V2.Scripts                        as PS.V2
import qualified Plutus.Script.Utils.V2.Typed.Scripts.MonetaryPolicies as PS.V2
import qualified Plutus.V2.Ledger.Api                                  as PlutusV2
import           Plutus.V2.Ledger.Contexts                             (ownCurrencySymbol)
import qualified PlutusTx
import           PlutusTx.Prelude                                      hiding
                                                                       (Semigroup (..),
                                                                        unless)
import qualified Prelude                                               (Show (..))

data MintParams = MintParams
                { mpRef       :: !PlutusV2.TxOutRef
                , mpTokenName :: !TokenName
                }
                deriving (Prelude.Show)

instance Eq MintParams where
    (MintParams oref tn) == (MintParams oref' tn') = oref == oref' && tn == tn'

PlutusTx.unstableMakeIsData ''MintParams
PlutusTx.makeLift ''MintParams

{-# INLINABLE mkTokenPolicy #-}
mkTokenPolicy :: PlutusV2.TxOutRef -> PlutusV2.ScriptContext -> Bool
mkTokenPolicy oref ctx =  traceIfFalse "UTxO not consumed"   hasUTxO
                                       && traceIfFalse "wrong amount minted" checkMintedAmount
  where
    info :: PlutusV2.TxInfo
    info = PlutusV2.scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> PlutusV2.txInInfoOutRef i == oref) . PlutusV2.txInfoInputs $ info

    checkMintedAmount :: Bool
    checkMintedAmount =
      case Value.flattenValue . PlutusV2.txInfoMint $ info of
        [(cs, _, amt)] -> cs == ownCurrencySymbol ctx && amt == 1
        _              -> False

tokenPolicy :: PlutusV2.MintingPolicy
tokenPolicy = PlutusV2.mkMintingPolicyScript $$(PlutusTx.compile [|| wrap ||])
  where wrap =  PS.V2.mkUntypedMintingPolicy mkTokenPolicy

tokenCurSymbol :: CurrencySymbol
tokenCurSymbol = PS.V2.scriptCurrencySymbol tokenPolicy
