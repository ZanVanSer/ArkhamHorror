module Arkham.Types.Treachery.Cards.CurseOfTheRougarou
  ( CurseOfTheRougarou(..)
  , curseOfTheRougarou
  ) where

import Arkham.Prelude

import qualified Arkham.Treachery.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Criteria
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Source
import Arkham.Types.Target
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner

newtype CurseOfTheRougarou = CurseOfTheRougarou TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

curseOfTheRougarou :: TreacheryCard CurseOfTheRougarou
curseOfTheRougarou = treachery CurseOfTheRougarou Cards.curseOfTheRougarou

instance HasAbilities env CurseOfTheRougarou where
  getAbilities _ _ (CurseOfTheRougarou x) = pure
    [ restrictedAbility
        x
        1
        (InThreatAreaOf You <> InvestigatorExists (You <> NoDamageDealtThisTurn)
        )
      $ ForcedAbility
      $ TurnEnds Timing.When You
    ]

instance TreacheryRunner env => RunMessage env CurseOfTheRougarou where
  runMessage msg t@(CurseOfTheRougarou attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      t <$ push (AttachTreachery (toId attrs) $ InvestigatorTarget iid)
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      t <$ push (InvestigatorAssignDamage iid source DamageAny 0 1)
    _ -> CurseOfTheRougarou <$> runMessage msg attrs
