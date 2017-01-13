{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Network.PinPon.WireTypes.SNS
  ( -- * Amazon Simple Notification Service on-the-wire types
    Message(..)
  , defaultMsg
  , apnsPayload
  , apnsSandboxPayload
  ) where

import Control.Lens (makeLenses)
import Data.Aeson.Types
       ((.=), Pair, Series, ToJSON(..), object, pairs)
import Data.Monoid ((<>))
import Data.Text (Text)
import GHC.Generics

import qualified Network.PinPon.WireTypes.APNS as APNS (Payload(..))

-- $setup
-- >>> :set -XOverloadedStrings

-- | A multi-platform SNS message.
data Message = Message
  { _defaultMsg         :: !Text               -- ^ The default message (required by SNS)
  , _apnsPayload        :: Maybe APNS.Payload -- ^ Optional production APNS payload
  , _apnsSandboxPayload :: Maybe APNS.Payload -- ^ Optional sandbox APNS payload
  } deriving (Show, Generic)

makeLenses ''Message

instance ToJSON Message where
  toJSON (Message d p s) = object $! ["default" .= d] <> apns p <> apnsSandbox s
    where
      apns :: Maybe APNS.Payload -> [Pair]
      apns Nothing = mempty
      apns v = ["APNS" .= v]
      apnsSandbox :: Maybe APNS.Payload -> [Pair]
      apnsSandbox Nothing = mempty
      apnsSandbox v = ["APNS_SANDBOX" .= v]
  toEncoding (Message d p s) = pairs $! "default" .= d <> apns p <> apnsSandbox s
    where
      apns :: Maybe APNS.Payload -> Series
      apns Nothing = mempty
      apns v = "APNS" .= v
      apnsSandbox :: Maybe APNS.Payload -> Series
      apnsSandbox Nothing = mempty
      apnsSandbox v = "APNS_SANDBOX" .= v

-- $
-- >>> import Network.PinPon.WireTypes.APNS (Alert(..), Aps(..), Payload(..))
-- >>> let alert1 = Alert "This is a production alert title" "This is a production alert body"
-- >>> let aps1 = Aps alert1 "production default"
-- >>> let payload1 = Payload aps1
-- >>> let msg1 = Message "This is the default message" (Just payload1) Nothing
-- >>> toJSON msg1
-- Object (fromList [("default",String "This is the default message"),("APNS",Object (fromList [("aps",Object (fromList [("sound",String "production default"),("alert",Object (fromList [("body",String "This is a production alert body"),("title",String "This is a production alert title")]))]))]))])
-- >>> toEncoding msg1
-- "{\"default\":\"This is the default message\",\"APNS\":{\"aps\":{\"alert\":{\"title\":\"This is a production alert title\",\"body\":\"This is a production alert body\"},\"sound\":\"production default\"}}}"
-- >>> let alert2 = Alert "This is a sandbox alert title" "This is a sandbox alert body"
-- >>> let aps2 = Aps alert2 "sandbox default"
-- >>> let payload2 = Payload aps2
-- >>> let msg2 = Message "This is the default message" Nothing (Just payload2)
-- >>> toJSON msg2
-- Object (fromList [("default",String "This is the default message"),("APNS_SANDBOX",Object (fromList [("aps",Object (fromList [("sound",String "sandbox default"),("alert",Object (fromList [("body",String "This is a sandbox alert body"),("title",String "This is a sandbox alert title")]))]))]))])
-- >>> toEncoding msg2
-- "{\"default\":\"This is the default message\",\"APNS_SANDBOX\":{\"aps\":{\"alert\":{\"title\":\"This is a sandbox alert title\",\"body\":\"This is a sandbox alert body\"},\"sound\":\"sandbox default\"}}}"
-- >>> let msg3 = Message "This is the default message" (Just payload1) (Just payload2)
-- >>> toJSON msg3
-- Object (fromList [("default",String "This is the default message"),("APNS_SANDBOX",Object (fromList [("aps",Object (fromList [("sound",String "sandbox default"),("alert",Object (fromList [("body",String "This is a sandbox alert body"),("title",String "This is a sandbox alert title")]))]))])),("APNS",Object (fromList [("aps",Object (fromList [("sound",String "production default"),("alert",Object (fromList [("body",String "This is a production alert body"),("title",String "This is a production alert title")]))]))]))])
-- >>> toEncoding msg3
-- "{\"default\":\"This is the default message\",\"APNS\":{\"aps\":{\"alert\":{\"title\":\"This is a production alert title\",\"body\":\"This is a production alert body\"},\"sound\":\"production default\"}},\"APNS_SANDBOX\":{\"aps\":{\"alert\":{\"title\":\"This is a sandbox alert title\",\"body\":\"This is a sandbox alert body\"},\"sound\":\"sandbox default\"}}}"
