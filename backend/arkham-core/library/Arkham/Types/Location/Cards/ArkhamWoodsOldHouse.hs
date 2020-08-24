{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.ArkhamWoodsOldHouse where

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.LocationSymbol
import Arkham.Types.Trait
import ClassyPrelude
import qualified Data.HashSet as HashSet

newtype ArkhamWoodsOldHouse = ArkhamWoodsOldHouse Attrs
  deriving newtype (Show, ToJSON, FromJSON)

arkhamWoodsOldHouse :: ArkhamWoodsOldHouse
arkhamWoodsOldHouse =
  ArkhamWoodsOldHouse
    $ (baseAttrs
        "01152"
        "Arkham Woods: Old House"
        2
        (PerPlayer 1)
        Square
        [Squiggle]
      )
        { locationTraits = HashSet.fromList [Woods]
        , locationRevealedConnectedSymbols = HashSet.fromList
          [Squiggle, Triangle, T]
        , locationRevealedSymbol = Diamond
        }

instance (IsInvestigator investigator) => HasActions env investigator ArkhamWoodsOldHouse where
  getActions i window (ArkhamWoodsOldHouse attrs) = getActions i window attrs

instance (LocationRunner env) => RunMessage env ArkhamWoodsOldHouse where
  runMessage msg (ArkhamWoodsOldHouse attrs) =
    ArkhamWoodsOldHouse <$> runMessage msg attrs
