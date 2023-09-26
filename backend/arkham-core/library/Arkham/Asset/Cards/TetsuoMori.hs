module Arkham.Asset.Cards.TetsuoMori (
  tetsuoMori,
  TetsuoMori (..),
)
where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Investigator.Types (Field (..))
import Arkham.Matcher
import Arkham.Matcher qualified as Matcher
import Arkham.Projection
import Arkham.Trait (Trait (Item))

newtype TetsuoMori = TetsuoMori AssetAttrs
  deriving anyclass (IsAsset)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

tetsuoMori :: AssetCard TetsuoMori
tetsuoMori = ally TetsuoMori Cards.tetsuoMori (2, 2)

instance HasModifiersFor TetsuoMori where
  getModifiersFor (InvestigatorTarget iid) (TetsuoMori a) | not (controlledBy a iid) = do
    locationId <- field InvestigatorLocation iid
    assetLocationId <- field AssetLocation (toId a)
    pure
      $ toModifiers a
      $ if (locationId == assetLocationId) && isJust locationId
        then [CanAssignDamageToAsset (toId a), CanAssignHorrorToAsset (toId a)]
        else []
  getModifiersFor _ _ = pure []

instance HasAbilities TetsuoMori where
  getAbilities (TetsuoMori a) =
    [ controlledAbility
        a
        1
        ( exists
            $ InvestigatorAt YourLocation
            <> AnyInvestigator
              [ InvestigatorWithoutModifier CardsCannotLeaveYourDiscardPile
                  <> DiscardWith (HasCard $ CardWithTrait Item)
              , InvestigatorWithoutModifier CannotManipulateDeck
              ]
        )
        $ freeReaction (Matcher.AssetDefeated #when ByAny $ AssetWithId $ toId a)
    ]

instance RunMessage TetsuoMori where
  runMessage msg a@(TetsuoMori attrs) = case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      iids <-
        selectList
          $ colocatedWith iid
          <> AnyInvestigator
            [ InvestigatorWithoutModifier CardsCannotLeaveYourDiscardPile
                <> DiscardWith (HasCard $ CardWithTrait Item)
            , InvestigatorWithoutModifier CannotManipulateDeck
            ]
      push
        $ chooseOrRunOne iid
        $ targetLabels iids
        $ only
        . HandleTargetChoice iid (toAbilitySource attrs 1)
        . toTarget
      pure a
    HandleTargetChoice _ source@(isAbilitySource attrs 1 -> True) (InvestigatorTarget iid') -> do
      discardWithItem <- fieldP InvestigatorDiscard (any (`cardMatch` CardWithTrait Item)) iid'
      push
        $ chooseOrRunOne iid'
        $ [ Label
            "Search Discard"
            [search iid' source iid' [fromDiscard] (CardWithTrait Item) (DrawFound iid' 1)]
          | discardWithItem
          ]
        <> [ Label
              "Search Deck"
              [search iid' source iid' [fromTopOfDeck 9] (CardWithTrait Item) (DrawFound iid' 1)]
           ]
      pure a
    _ -> TetsuoMori <$> runMessage msg attrs