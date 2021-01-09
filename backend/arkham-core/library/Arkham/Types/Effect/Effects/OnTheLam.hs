module Arkham.Types.Effect.Effects.OnTheLam
  ( onTheLam
  , OnTheLam(..)
  ) where

import Arkham.Import

import Arkham.Types.Effect.Attrs
import Arkham.Types.Effect.Helpers

newtype OnTheLam = OnTheLam Attrs
  deriving newtype (Show, ToJSON, FromJSON)

onTheLam :: EffectArgs -> OnTheLam
onTheLam = OnTheLam . uncurry4 (baseAttrs "01010")

instance HasModifiersFor env OnTheLam where
  getModifiersFor _ target (OnTheLam a@Attrs {..}) =
    pure $ toModifiers a [ CannotBeAttackedByNonElite | target == effectTarget ]

instance HasQueue env => RunMessage env OnTheLam where
  runMessage msg e@(OnTheLam attrs) = case msg of
    EndRound -> e <$ unshiftMessage (DisableEffect $ toId attrs)
    _ -> OnTheLam <$> runMessage msg attrs
