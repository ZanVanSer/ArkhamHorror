module Arkham.Types.Location.Cards.ForgottenMarsh where

import Arkham.Prelude

import qualified Arkham.Location.Cards as Cards (forgottenMarsh)
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Helpers
import Arkham.Types.Matcher
import Arkham.Types.Message
import qualified Arkham.Types.Timing as Timing

newtype ForgottenMarsh = ForgottenMarsh LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

forgottenMarsh :: LocationCard ForgottenMarsh
forgottenMarsh = location
  ForgottenMarsh
  Cards.forgottenMarsh
  2
  (Static 0)
  Diamond
  [Moon, Square, Triangle, Hourglass]

instance HasAbilities env ForgottenMarsh where
  getAbilities i window (ForgottenMarsh attrs) =
    withBaseAbilities i window attrs $ pure
      [ mkAbility attrs 1
        $ ForcedAbility
        $ Leaves Timing.When You
        $ LocationWithId
        $ toId attrs
      | locationRevealed attrs
      ]

instance LocationRunner env => RunMessage env ForgottenMarsh where
  runMessage msg l@(ForgottenMarsh attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ push (SpendResources iid 2)
    _ -> ForgottenMarsh <$> runMessage msg attrs
