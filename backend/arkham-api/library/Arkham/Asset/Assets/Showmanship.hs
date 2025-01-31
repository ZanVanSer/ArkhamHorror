module Arkham.Asset.Assets.Showmanship (showmanship, showmanshipEffect, Showmanship (..)) where

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Import.Lifted
import Arkham.Effect.Import
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Helpers.Modifiers (ModifierType (..), maybeModified)
import Arkham.Helpers.Ref (sourceToTarget)
import Arkham.Matcher
import Arkham.SkillType
import Arkham.Window (Window (..), WindowType (EnterPlay))

newtype Showmanship = Showmanship AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

showmanship :: AssetCard Showmanship
showmanship = asset Showmanship Cards.showmanship

instance HasAbilities Showmanship where
  getAbilities (Showmanship a) =
    [ restrictedAbility a 1 ControlsThis $ freeReaction (AssetEntersPlay #after $ AssetControlledBy You)
    ]

toAsset :: [Window] -> AssetId
toAsset [] = error "missing asset"
toAsset ((windowType -> EnterPlay (AssetTarget aid)) : _) = aid
toAsset (_ : xs) = toAsset xs

instance RunMessage Showmanship where
  runMessage msg a@(Showmanship attrs) = runQueueT $ case msg of
    UseCardAbility iid (isSource attrs -> True) 1 (toAsset -> aid) _ -> do
      createCardEffect Cards.showmanship (effectMetaTarget aid) attrs iid
      pure a
    _ -> Showmanship <$> liftRunMessage msg attrs

newtype ShowmanshipEffect = ShowmanshipEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

showmanshipEffect :: EffectArgs -> ShowmanshipEffect
showmanshipEffect = cardEffect ShowmanshipEffect Cards.showmanship

instance HasModifiersFor ShowmanshipEffect where
  getModifiersFor target (ShowmanshipEffect attrs) = maybeModified attrs do
    guard $ attrs.target == target
    EffectMetaTarget t <- hoistMaybe attrs.metadata
    abilities <- lift getActiveAbilities
    guard $ any (\ability -> sourceToTarget ability.source == t) abilities
    pure [SkillModifier sType 2 | sType <- allSkills]

instance RunMessage ShowmanshipEffect where
  runMessage msg e@(ShowmanshipEffect attrs) = case msg of
    EndRound -> e <$ push (DisableEffect $ toId attrs)
    _ -> ShowmanshipEffect <$> runMessage msg attrs
