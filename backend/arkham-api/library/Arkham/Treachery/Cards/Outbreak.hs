module Arkham.Treachery.Cards.Outbreak (outbreak, Outbreak (..)) where

import Arkham.Classes
import Arkham.Helpers.Modifiers
import Arkham.Message
import Arkham.Scenarios.WakingNightmare.Helpers
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Treachery.Import.Lifted

newtype Outbreak = Outbreak TreacheryAttrs
  deriving anyclass (IsTreachery, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

outbreak :: TreacheryCard Outbreak
outbreak = treachery Outbreak Cards.outbreak

instance HasModifiersFor Outbreak where
  getModifiersFor (StoryTarget _) (Outbreak attrs) = do
    toModifiers attrs [MetaModifier $ object ["treatTabletAsSkill" .= True]]
  getModifiersFor _ _ = pure []

instance RunMessage Outbreak where
  runMessage msg t@(Outbreak attrs) = runQueueT $ case msg of
    Revelation _iid (isSource attrs -> True) -> do
      makeInfestationTest
      pure t
    _ -> Outbreak <$> liftRunMessage msg attrs
