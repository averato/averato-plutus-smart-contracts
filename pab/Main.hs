{-# LANGUAGE TypeApplications #-}

module Main
    ( main
    ) where

import           PAB                                 (TokenContracts)
import qualified Plutus.PAB.Effects.Contract.Builtin as Builtin
import           Plutus.PAB.Run                      (runWith)

main :: IO ()
main = runWith (Builtin.handleBuiltin @TokenContracts)
