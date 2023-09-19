module Arkham.Asset.Cards.GravediggersShovel2 (
  gravediggersShovel2,
  GravediggersShovel2 (..),
) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Discover
import Arkham.Matcher

newtype GravediggersShovel2 = GravediggersShovel2 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

gravediggersShovel2 :: AssetCard GravediggersShovel2
gravediggersShovel2 = asset GravediggersShovel2 Cards.gravediggersShovel2

instance HasAbilities GravediggersShovel2 where
  getAbilities (GravediggersShovel2 x) =
    [ fightAbility x 1 (ActionCost 1) ControlsThis
    , restrictedAbility
        x
        2
        (ControlsThis <> InvestigatorExists (You <> InvestigatorCanDiscoverCluesAt YourLocation))
        $ actionAbilityWithCost (OrCost [discardCost x, removeCost x])
    ]

instance RunMessage GravediggersShovel2 where
  runMessage msg a@(GravediggersShovel2 attrs) = case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      pushAll
        [ skillTestModifier attrs iid (SkillModifier #combat 2)
        , chooseFightEnemy iid (toAbilitySource attrs 1) #combat
        ]
      pure a
    InDiscard _ (UseThisAbility iid (isSource attrs -> True) 2) -> do
      pushMessage $ discoverAtYourLocation iid (toAbilitySource attrs 2) 1
      pure a
    InOutOfPlay (UseThisAbility iid (isSource attrs -> True) 2) -> do
      pushMessage $ discoverAtYourLocation iid (toAbilitySource attrs 2) 2
      pure a
    _ -> GravediggersShovel2 <$> runMessage msg attrs