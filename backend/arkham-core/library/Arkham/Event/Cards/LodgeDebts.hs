module Arkham.Event.Cards.LodgeDebts
  ( lodgeDebts
  , LodgeDebts(..)
  )
where

import Arkham.Prelude

import qualified Arkham.Event.Cards as Cards
import Arkham.Ability
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Classes
import Arkham.Event.Runner
import Arkham.Message hiding (InvestigatorEliminated)
import Arkham.Timing qualified as Timing

newtype LodgeDebts = LodgeDebts EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

lodgeDebts :: EventCard LodgeDebts
lodgeDebts =
  event LodgeDebts Cards.lodgeDebts

instance HasAbilities LodgeDebts where
  getAbilities (LodgeDebts a) =
    [ restrictedAbility a 1 InYourHand
      $ ForcedAbility
      $ OrWindowMatcher
          [ GameEnds Timing.When
          , InvestigatorEliminated Timing.When (InvestigatorWithId $ eventOwner a)
          ]
    ]

instance RunMessage LodgeDebts where
  runMessage msg e@(LodgeDebts attrs) = case msg of
    InvestigatorPlayEvent _ eid _ _ _ | eid == toId attrs -> do
      e <$ pushAll [RemoveFromGame (toTarget attrs)]
    InHand iid' (UseCardAbility iid (isSource attrs -> True) 1 _ _)
      | iid == iid' -> do
      push $ SufferTrauma iid 0 1
      pure e
    _ -> LodgeDebts <$> runMessage msg attrs
