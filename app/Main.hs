{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE NumericUnderscores  #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TypeApplications    #-}

module Main
    ( main
    ) where

import qualified Cardano.Api                            as CAPI
import           Cardano.Node.Types                     (PABServerConfig (..))
-- import           DemoContract                        (DemoContract)
import           Data.Yaml                              (decodeFileThrow)
import           GHC.Generics                           (Generic)
import           Options.Applicative                    (Parser, ParserInfo,
                                                         auto, execParser,
                                                         fullDesc, help, helper,
                                                         info, long, metavar,
                                                         option, progDesc,
                                                         short, showDefault,
                                                         strOption, value,
                                                         (<**>))
import qualified Plutus.PAB.Effects.Contract.Builtin    as Builtin
import           Plutus.PAB.Run                         (runWithOpts)
import           Plutus.PAB.Run.CommandParser           (AppOpts (..))
import qualified Plutus.PAB.Types                       as PAB.Config
import           Text.Pretty.Simple                     (pPrint)

import           Cardano.Node.Types                     (PABServerConfig (..))
import           Cardano.Protocol.Socket.Mock.Client    (TxSendHandle (..),
                                                         queueTx, runTxSender)
import           Control.Concurrent                     (threadDelay)
import           Control.Concurrent.Async               (async)
import           Control.Monad                          (void)
import           Control.Monad.Freer.Extras.Beam.Sqlite (DbConfig (..))
import           Control.Monad.IO.Class                 (MonadIO, liftIO)
import           Data.Either                            (fromRight)
import           GHC.Generics                           (Generic)
import           Ledger                                 (testnet)
import qualified Ledger.Ada                             as Ada
import           Ledger.Blockchain                      (OnChainTx (..))
import           Ledger.Index                           (UtxoIndex (..),
                                                         insertBlock)
import           Ledger.Slot                            (Slot (..))
import           Ledger.Tx                              (CardanoTx (EmulatorTx),
                                                         Tx (..))
import           PAB
import           Plutus.ChainIndex.Types                (Point (..))
import qualified Plutus.PAB.App                         as PAB.App
import           Plutus.PAB.Effects.Contract.Builtin    (handleBuiltin)
import           Plutus.PAB.Run.Command                 (ConfigCommand (..))

-- | Command line options
newtype CliOptions = MkCliOptions { unServerConfig :: String }
  deriving (Show, Generic)

-- | Command line parser
cmdOptions :: Parser CliOptions
cmdOptions = MkCliOptions
  <$> strOption
    (  long "config"
    <> short 'c'
    <> metavar "CONFIG"
    <> help "Read configuration from the CONFIG file"
    )

prgHelp :: ParserInfo CliOptions
prgHelp = info (cmdOptions <**> helper)
        ( fullDesc
       <> progDesc "PAB Server for the CardeAvato smartcontracts." )

getCliOptions :: IO CliOptions
getCliOptions = do
   opts <- execParser prgHelp
   pPrint opts
   return opts

decodeConfig :: IO PAB.Config.Config
decodeConfig = getCliOptions >>= liftIO . decodeFileThrow . unServerConfig

main :: IO ()
main = do
    -- Keep this here for now. Eventually, This function will call the `migrate`
    -- command before running the webserver.
    config <- decodeConfig
    pPrint config
    let appOpts = AppOpts
                { minLogLevel = Nothing
                , logConfigPath = Nothing
                , configPath = Nothing
                , runEkgServer = False
                , storageBackend = PAB.App.BeamBackend
                , cmd = PABWebserver
                , passphrase = Nothing
                , rollbackHistory = Nothing
                , resumeFrom = PointAtGenesis
                }
--        networkID = NetworkIdWrapper $ CAPI.Testnet $ CAPI.NetworkMagic 1097911063
--        config = PAB.Config.defaultConfig
--             { PAB.Config.nodeServerConfig = def{pscNodeMode=AlonzoNode,pscNetworkId=networkID} -- def{mscSocketPath=nodeSocketFile socketPath,mscNodeMode=AlonzoNode,mscNetworkId=networkID}
--             , PAB.Config.dbConfig = def -- {dbConfigFile = "plutus-pab.db"} -- def{dbConfigFile = T.pack (dir </> "plutus-pab.db")}
--             , PAB.Config.chainQueryConfig = def -- def{PAB.CI.ciBaseUrl = PAB.CI.ChainIndexUrl $ BaseUrl Http "localhost" chainIndexPort ""}
--             , PAB.Config.walletServerConfig = def -- def{Wallet.Config.baseUrl=WalletUrl walletUrl}
--             }

--    void . async
    void $ runWithOpts @TokenContracts handleBuiltin (Just config) appOpts{cmd=Migrate}
    sleep 2
    pPrint "PAB Server started"
--    void . async $
    void $ runWithOpts @TokenContracts handleBuiltin (Just config) appOpts{cmd=PABWebserver}
    -- -- Pressing enter stops the server
    void getLine

sleep :: Int -> IO ()
sleep n = threadDelay $ n * 1_000_000
