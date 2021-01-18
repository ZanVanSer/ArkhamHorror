module Arkham.Types.Agenda.Cards.ReturnToPredatorOrPrey
  ( ReturnToPredatorOrPrey(..)
  , returnToPredatorOrPrey
  )
where

import Arkham.Import

import qualified Arkham.Types.Action as Action
import Arkham.Types.Agenda.Attrs
import Arkham.Types.Agenda.Runner

newtype ReturnToPredatorOrPrey = ReturnToPredatorOrPrey Attrs
  deriving newtype (Show, ToJSON, FromJSON)

returnToPredatorOrPrey :: ReturnToPredatorOrPrey
returnToPredatorOrPrey = ReturnToPredatorOrPrey
  $ baseAttrs "50026" "Predator or Prey?" (Agenda 1 A) (Static 6)

instance HasModifiersFor env ReturnToPredatorOrPrey where
  getModifiersFor = noModifiersFor

instance HasActions env ReturnToPredatorOrPrey where
  getActions iid NonFast (ReturnToPredatorOrPrey attrs) = pure
    [ ActivateCardAbilityAction
        iid
        (mkAbility
          (toSource attrs)
          1
          (ActionAbility (Just Action.Resign) (ActionCost 1))
        )
    ]
  getActions _ _ _ = pure []

instance AgendaRunner env => RunMessage env ReturnToPredatorOrPrey where
  runMessage msg a@(ReturnToPredatorOrPrey attrs@Attrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == Agenda 1 B ->
      a <$ unshiftMessages
        [CreateEnemyEngagedWithPrey "50026b", NextAgenda aid "01122"]
    UseCardAbility iid (AgendaSource aid) _ 1 _ | aid == agendaId -> do
      unshiftMessage (Resign iid)
      ReturnToPredatorOrPrey <$> runMessage msg attrs
    _ -> ReturnToPredatorOrPrey <$> runMessage msg attrs
