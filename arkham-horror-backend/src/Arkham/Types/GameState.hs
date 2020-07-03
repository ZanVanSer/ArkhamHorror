module Arkham.Types.GameState
  ( ArkhamGameState(..)
  , ArkhamGameStateLock(..)
  , ArkhamGameStateStep(..)
  , ArkhamStack(..)
  , ArkhamPhase(..)
  , ArkhamAct(..)
  , ArkhamAgenda(..)
  , ArkhamSkillCheckStep(..)
  , ArkhamRevealTokenStep(..)
  , ArkhamTarget(..)
  , stackAgenda
  , stackAct
  , _ActStack
  , _AgendaStack
  , _TopOfStack
  )
where

import Arkham.Types.Act
import Arkham.Types.Action
import Arkham.Types.Agenda
import Arkham.Types.Card
import Arkham.Types.ChaosToken
import Arkham.Types.Enemy
import Arkham.Types.Location
import Arkham.Types.Player
import Arkham.Types.Skill
import Base.Lock
import ClassyPrelude
import Data.Aeson
import Data.Aeson.Casing
import Data.List.NonEmpty (NonEmpty(..))
import qualified Data.List.NonEmpty as NE
import Data.UUID
import Entity.User
import Lens.Micro
import Orphans ()

data ArkhamPhase = Mythos | Investigation | Enemy | Upkeep
  deriving stock (Generic, Show, Eq)
  deriving anyclass (ToJSON, FromJSON)

data ArkhamGameStateStep
  = ArkhamGameStateStepInvestigatorActionStep
  | ArkhamGameStateStepSkillCheckStep ArkhamSkillCheckStep
  | ArkhamGameStateStepRevealTokenStep ArkhamRevealTokenStep
  deriving stock (Generic, Show)
  deriving anyclass (ToJSON, FromJSON)

instance Eq ArkhamGameStateStep where
  ArkhamGameStateStepInvestigatorActionStep == ArkhamGameStateStepInvestigatorActionStep
    = True
  ArkhamGameStateStepSkillCheckStep _ == ArkhamGameStateStepSkillCheckStep _
    = True
  ArkhamGameStateStepRevealTokenStep _ == ArkhamGameStateStepRevealTokenStep _
    = True
  _ == _ = False

data ArkhamTarget = LocationTarget ArkhamLocation | OtherTarget ArkhamLocation
  deriving stock (Generic, Show)
  deriving anyclass (ToJSON, FromJSON)

data ArkhamSkillCheckStep = ArkhamSkillCheckStep
  { ascsType :: ArkhamSkillType
  , ascsAction :: Maybe ArkhamAction
  , ascsTarget :: Maybe ArkhamTarget
  }
  deriving stock (Generic, Show)

instance ToJSON ArkhamSkillCheckStep where
  toJSON =
    genericToJSON $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }
  toEncoding = genericToEncoding
    $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }

instance FromJSON ArkhamSkillCheckStep where
  parseJSON = genericParseJSON
    $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }

data ArkhamRevealTokenStep = ArkhamRevealTokenStep
  { artsType :: ArkhamSkillType
  , artsAction :: Maybe ArkhamAction
  , artsTarget :: Maybe ArkhamTarget
  , artsToken :: ArkhamChaosToken
  , artsDifficulty :: Int
  , artsModifiedSkillValue :: Int
  , artsCards :: [ArkhamCard]
  }
  deriving stock (Generic, Show)

instance ToJSON ArkhamRevealTokenStep where
  toJSON =
    genericToJSON $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }
  toEncoding = genericToEncoding
    $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }

instance FromJSON ArkhamRevealTokenStep where
  parseJSON = genericParseJSON
    $ defaultOptions { fieldLabelModifier = camelCase . drop 4 }

data ArkhamGameStateLock = AddDoom | InvestigationTakeActions | UpkeepResetActions | DrawAndGainResources
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

data ArkhamGameState = ArkhamGameState
  { agsPlayers :: HashMap UserId ArkhamPlayer
  , agsPhase :: ArkhamPhase
  , agsChaosBag :: NonEmpty ArkhamChaosToken
  , agsLocations :: HashMap ArkhamCardCode ArkhamLocation
  , agsEnemies :: HashMap UUID ArkhamEnemy
  , agsStacks :: HashMap Text ArkhamStack
  , agsEncounterDeck :: [ArkhamEncounterCard]
  , agsStep :: ArkhamGameStateStep
  , agsLock :: Maybe (NonEmpty ArkhamGameStateLock)
  }
  deriving stock (Generic, Show)

instance HasLock ArkhamGameState where
  type Lock ArkhamGameState = NonEmpty ArkhamGameStateLock
  lock = lens agsLock $ \m x -> m { agsLock = x }

instance Unlock (NonEmpty ArkhamGameStateLock) where
  type Key (NonEmpty ArkhamGameStateLock) = ArkhamGameStateLock
  unlocks = (==) . NE.head

data ArkhamStack = ActStack (NonEmpty ArkhamAct) | AgendaStack (NonEmpty ArkhamAgenda)
  deriving stock (Generic, Show)
  deriving anyclass (ToJSON, FromJSON)

stackAct :: ArkhamStack -> Maybe ArkhamAct
stackAct (ActStack acts) = Just $ NE.head acts
stackAct _ = Nothing

stackAgenda :: ArkhamStack -> Maybe ArkhamAgenda
stackAgenda (AgendaStack agendas) = Just $ NE.head agendas
stackAgenda _ = Nothing

_ActStack :: Traversal' ArkhamStack (NonEmpty ArkhamAct)
_ActStack f (ActStack a) = ActStack <$> f a
_ActStack _ (AgendaStack a) = pure $ AgendaStack a

_AgendaStack :: Traversal' ArkhamStack (NonEmpty ArkhamAgenda)
_AgendaStack f (AgendaStack a) = AgendaStack <$> f a
_AgendaStack _ (ActStack a) = pure $ ActStack a

_TopOfStack :: Lens' (NonEmpty a) a
_TopOfStack = lens NE.head $ \(_ :| as) x -> x :| as

instance ToJSON ArkhamGameState where
  toJSON =
    genericToJSON $ defaultOptions { fieldLabelModifier = camelCase . drop 3 }
  toEncoding = genericToEncoding
    $ defaultOptions { fieldLabelModifier = camelCase . drop 3 }

instance FromJSON ArkhamGameState where
  parseJSON = genericParseJSON
    $ defaultOptions { fieldLabelModifier = camelCase . drop 3 }
