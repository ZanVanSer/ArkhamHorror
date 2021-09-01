module Arkham.Types.Asset.Cards.BearTrap
  ( BearTrap(..)
  , bearTrap
  ) where

import Arkham.Prelude

import qualified Arkham.Asset.Cards as Cards
import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Helpers
import Arkham.Types.Asset.Runner
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.LocationId
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Target
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Window (Window(..))
import qualified Arkham.Types.Window as Window

newtype BearTrap = BearTrap AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, Generic, ToJSON, FromJSON, Entity)

bearTrap :: AssetCard BearTrap
bearTrap = assetWith BearTrap Cards.bearTrap (isStoryL .~ True)

instance HasModifiersFor env BearTrap where
  getModifiersFor _ (EnemyTarget eid) (BearTrap attrs@AssetAttrs {..})
    | Just eid == assetEnemy = pure
    $ toModifiers attrs [EnemyFight (-1), EnemyEvade (-1)]
  getModifiersFor _ _ _ = pure []

instance HasAbilities env BearTrap where
  getAbilities _ _ (BearTrap x) =
    pure
      $ [restrictedAbility x 1 restriction $ FastAbility Free]
      <> [ mkAbility x 2 $ ForcedAbility $ EnemyEnters
             Timing.After
             (LocationWithId attachedLocationId)
             (enemyIs Cards.theRougarou)
         | attachedLocationId <- maybeToList (assetLocation x)
         ]
    where restriction = maybe OwnsThis (const Never) (assetEnemy x)

instance AssetRunner env => RunMessage env BearTrap where
  runMessage msg a@(BearTrap attrs@AssetAttrs {..}) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      locationId <- getId @LocationId iid
      a <$ push (AttachAsset assetId (LocationTarget locationId))
    UseCardAbility _ source [Window _ (Window.EnemyEnters eid _)] 2 _
      | isSource attrs source -> do
        a <$ push (AttachAsset assetId (EnemyTarget eid))
    _ -> BearTrap <$> runMessage msg attrs
