module Arkham.Agenda.Cards.TheFirstNight (TheFirstNight (..), theFirstNight) where

import Arkham.Agenda.Cards qualified as Cards
import Arkham.Agenda.Helpers
import Arkham.Agenda.Runner
import Arkham.Classes
import Arkham.GameValue
import Arkham.Prelude
import Arkham.Scenarios.APhantomOfTruth.Helpers

newtype TheFirstNight = TheFirstNight AgendaAttrs
  deriving anyclass (IsAgenda, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theFirstNight :: AgendaCard TheFirstNight
theFirstNight = agenda (1, A) TheFirstNight Cards.theFirstNight (Static 6)

instance HasModifiersFor TheFirstNight where
  getModifiersFor target (TheFirstNight a) | not (isTarget a target) = do
    moreConvictionThanDoubt <- getMoreConvictionThanDoubt
    toModifiers a $ [DoomSubtracts | moreConvictionThanDoubt]
  getModifiersFor _ _ = pure []

instance RunMessage TheFirstNight where
  runMessage msg a@(TheFirstNight attrs) = case msg of
    AdvanceAgenda (isSide B attrs -> True) -> do
      msgs <- disengageEachEnemyAndMoveToConnectingLocation attrs
      pushAll $ msgs <> [NextAdvanceAgendaStep (toId attrs) 2]
      pure a
    NextAdvanceAgendaStep (isSide B attrs -> True) 2 -> do
      organistMsg <- moveOrganistAwayFromNearestInvestigator
      pushAll $ organistMsg : [advanceAgendaDeck attrs]
      pure a
    _ -> TheFirstNight <$> runMessage msg attrs
