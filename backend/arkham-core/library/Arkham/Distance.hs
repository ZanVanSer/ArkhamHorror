module Arkham.Distance where

import Arkham.Prelude

newtype Distance = Distance { unDistance :: Int }
  deriving newtype (Ord, Show, Eq, Bounded, ToJSON, FromJSON)
