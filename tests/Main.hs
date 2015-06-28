{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DeriveDataTypeable         #-}
------------------------------------------------------------------------------
module Main ( main ) where
------------------------------------------------------------------------------
import           Control.Applicative
import           Control.Exception
import           Control.Monad
import           Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Char8 as B8
import qualified Data.ByteString.Lazy.Char8 as BL8
import           Data.Either
import           Data.Int
import           Data.String
import           Data.Text (Text)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import           Data.Time
import           Data.Typeable
import           Data.Word
import           System.Environment
import           System.Envy
import           Test.Hspec
import           Test.QuickCheck
import           Test.QuickCheck.Instances
------------------------------------------------------------------------------
data ConnectInfo = ConnectInfo {
      pgHost :: String
    , pgPort :: Word16
    , pgUser :: String
    , pgPass :: String
    , pgDB   :: String
  } deriving (Show)

------------------------------------------------------------------------------
-- | Posgtres config
data PGConfig = PGConfig {
    pgConnectInfo :: ConnectInfo -- ^ Connnection Info
  } 

------------------------------------------------------------------------------
-- | Custom show instance
instance Show PGConfig where
  show PGConfig {..} = "<PGConfig>"

------------------------------------------------------------------------------
-- | FromEnv Instances, supports popular aeson combinators *and* IO
-- for dealing with connection pools
instance FromEnv PGConfig where
  fromEnv = PGConfig <$> (ConnectInfo <$> envMaybe "PG_HOST" .!= "localhost"
                                      <*> env "PG_PORT"
                                      <*> env "PG_USER" 
                                      <*> env "PG_PASS" 
                                      <*> env "PG_DB")

------------------------------------------------------------------------------
-- | To Environment Instances
instance ToEnv PGConfig where
  toEnv = makeEnv 
       [ "PG_HOST" .= ("localhost" :: String)
       , "PG_PORT" .= (5432        :: Word16)
       , "PG_USER" .= ("user"      :: String)
       , "PG_PASS" .= ("pass"      :: String)
       , "PG_DB"   .= ("db"        :: String)
       ]

------------------------------------------------------------------------------
-- | Start tests
main :: IO ()
main = hspec $ do 
  describe "Var ismorphisms hold" $ do
    it "Word8 Var isomorphism" $ property $ 
     \(x :: Word8) -> Just x == fromVar (toVar x)
    it "Word16 Var isomorphism" $ property $ 
     \(x :: Word16) -> Just x == fromVar (toVar x)
    it "Word32 Var isomorphism" $ property $ 
     \(x :: Word32) -> Just x == fromVar (toVar x)
    it "Int Var isomorphism" $ property $ 
     \(x :: Int) -> Just x == fromVar (toVar x)
    it "Int8 Var isomorphism" $ property $ 
     \(x :: Int8) -> Just x == fromVar (toVar x)
    it "Int16 Var isomorphism" $ property $ 
     \(x :: Int16) -> Just x == fromVar (toVar x)
    it "Int32 Var isomorphism" $ property $ 
     \(x :: Int32) -> Just x == fromVar (toVar x)
    it "Int64 Var isomorphism" $ property $ 
     \(x :: Int64) -> Just x == fromVar (toVar x)
    it "String Var isomorphism" $ property $ 
     \(x :: String) -> Just x == fromVar (toVar x)
    it "Double Var isomorphism" $ property $ 
     \(x :: Double) -> Just x == fromVar (toVar x)
    it "UTCTime Var isomorphism" $ property $ 
     \(x :: UTCTime) -> Just x == fromVar (toVar x)
    it "ByteString Var isomorphism" $ property $ 
     \(x :: B8.ByteString) -> Just x == fromVar (toVar x)
    it "ByteString Var isomorphism" $ property $ 
     \(x :: BL8.ByteString) -> Just x == fromVar (toVar x)
    it "Lazy Text Var isomorphism" $ property $ 
     \(x :: LT.Text) -> Just x == fromVar (toVar x)
    it "Text Var isomorphism" $ property $ 
     \(x :: T.Text) -> Just x == fromVar (toVar x)
  describe "Can set to and from environment" $ do
    it "Should set environment" $ do
      setEnvironment (toEnv :: EnvList PGConfig)
      result <- decodeEnv :: IO (Either String PGConfig)
      result `shouldSatisfy` isRight
