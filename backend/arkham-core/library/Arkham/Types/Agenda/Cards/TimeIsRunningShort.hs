module Arkham.Types.Agenda.Cards.TimeIsRunningShort
  ( TimeIsRunningShort(..)
  , timeIsRunningShort
  )
where

import Arkham.Import

import qualified Arkham.Types.Action as Action
import Arkham.Types.Agenda.Attrs
import Arkham.Types.Agenda.Runner

newtype TimeIsRunningShort = TimeIsRunningShort Attrs
  deriving newtype (Show, ToJSON, FromJSON)

timeIsRunningShort :: TimeIsRunningShort
timeIsRunningShort = TimeIsRunningShort
  $ baseAttrs "01122" "Time Is Running Short" (Agenda 2 A) (Static 8)

instance HasModifiersFor env TimeIsRunningShort where
  getModifiersFor = noModifiersFor

instance HasActions env TimeIsRunningShort where
  getActions iid NonFast (TimeIsRunningShort _) = pure
    [ ActivateCardAbilityAction
        iid
        (mkAbility
          (AgendaSource "01122")
          1
          (ActionAbility (Just Action.Resign) (ActionCost 1))
        )
    ]
  getActions _ _ _ = pure []

instance (AgendaRunner env) => RunMessage env TimeIsRunningShort where
  runMessage msg a@(TimeIsRunningShort attrs@Attrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == Agenda 2 B ->
      a <$ unshiftMessage (Resolution 2)
    UseCardAbility iid (AgendaSource aid) _ 1 _ | aid == agendaId -> do
      unshiftMessage (Resign iid)
      TimeIsRunningShort <$> runMessage msg attrs
    _ -> TimeIsRunningShort <$> runMessage msg attrs
