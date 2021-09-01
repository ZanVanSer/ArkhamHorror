module Arkham.Types.Enemy.Cards.BillyCooper
  ( billyCooper
  , BillyCooper(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Helpers
import Arkham.Types.Enemy.Runner
import Arkham.Types.Matcher
import Arkham.Types.Message hiding (EnemyDefeated)
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Trait

newtype BillyCooper = BillyCooper EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

billyCooper :: EnemyCard BillyCooper
billyCooper = enemyWith
  BillyCooper
  Cards.billyCooper
  (5, Static 4, 2)
  (2, 0)
  (spawnAtL ?~ LocationWithTitle "Easttown")

instance HasAbilities env BillyCooper where
  getAbilities iid window (BillyCooper attrs) =
    withBaseAbilities iid window attrs $ pure
      [ mkAbility attrs 1
        $ ForcedAbility
        $ EnemyDefeated Timing.After Anyone
        $ EnemyAt (LocationWithId $ enemyLocation attrs)
        <> EnemyWithTrait Monster
      ]

instance EnemyRunner env => RunMessage env BillyCooper where
  runMessage msg e@(BillyCooper attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      e <$ push (AddToVictory $ toTarget attrs)
    _ -> BillyCooper <$> runMessage msg attrs
