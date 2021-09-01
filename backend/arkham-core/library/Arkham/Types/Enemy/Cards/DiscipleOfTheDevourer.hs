module Arkham.Types.Enemy.Cards.DiscipleOfTheDevourer
  ( discipleOfTheDevourer
  , DiscipleOfTheDevourer(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Helpers
import Arkham.Types.Enemy.Runner
import Arkham.Types.Id
import Arkham.Types.Matcher
import Arkham.Types.Message
import qualified Arkham.Types.Timing as Timing

newtype DiscipleOfTheDevourer = DiscipleOfTheDevourer EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

discipleOfTheDevourer :: EnemyCard DiscipleOfTheDevourer
discipleOfTheDevourer = enemyWith
  DiscipleOfTheDevourer
  Cards.discipleOfTheDevourer
  (3, Static 1, 1)
  (1, 0)
  (spawnAtL ?~ FarthestLocationFromYou EmptyLocation)

instance HasAbilities env DiscipleOfTheDevourer where
  getAbilities i w (DiscipleOfTheDevourer x) = withBaseAbilities i w x $ pure
    [ mkAbility x 1
      $ ForcedAbility
      $ EnemySpawns Timing.After Anywhere
      $ EnemyWithId
      $ toId x
    ]

instance EnemyRunner env => RunMessage env DiscipleOfTheDevourer where
  runMessage msg e@(DiscipleOfTheDevourer attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      let
        messages =
          [PlaceDoom (toTarget attrs) 1, InvestigatorPlaceCluesOnLocation iid 1]
      step <- unAgendaStep <$> getStep ()
      e <$ if step == 1 then push (chooseOne iid messages) else pushAll messages
    _ -> DiscipleOfTheDevourer <$> runMessage msg attrs
