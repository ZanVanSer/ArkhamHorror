module Arkham.Types.Asset.Cards.Pickpocketing where

import Arkham.Prelude

import Arkham.Types.Ability
import Arkham.Types.AssetId
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Message
import Arkham.Types.Window
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Helpers
import Arkham.Types.Asset.Runner

newtype Pickpocketing = Pickpocketing AssetAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

pickpoketing :: AssetId -> Pickpocketing
pickpoketing uuid = Pickpocketing $ baseAttrs uuid "01046"

instance HasModifiersFor env Pickpocketing where
  getModifiersFor = noModifiersFor

instance HasActions env Pickpocketing where
  getActions iid (WhenEnemyEvaded You) (Pickpocketing a) =
    withBaseActions iid (WhenEnemyEvaded You) a $ do
      let
        ability =
          mkAbility (toSource a) 1 (ReactionAbility $ ExhaustCost (toTarget a))
      pure [ ActivateCardAbilityAction iid ability | ownedBy a iid ]
  getActions i window (Pickpocketing a) = getActions i window a

instance AssetRunner env => RunMessage env Pickpocketing where
  runMessage msg a@(Pickpocketing attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ unshiftMessage (DrawCards iid 1 False)
    _ -> Pickpocketing <$> runMessage msg attrs
