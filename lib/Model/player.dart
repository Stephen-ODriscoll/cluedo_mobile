import "../utils/progress_report.dart";
import "../utils/contradiction.dart";

import "global.dart";
import "card.dart";

class StagePreset {
  int numCards;
  Set<Card> ownedCards;

  StagePreset([this.numCards = 0, this.ownedCards = const {}]);

  bool isNumCardsKnown() => numCards != 0;
}

// A stage refers to the time between guesses.
// E.g. game starts and we enter stage 1, a player
// guesses wrong thus the cards get passed around
// and we enter stage 2.
class PlayerStage {
  Set<Card> has = {};
  Set<Card> doesNotHave = {};
  List<List<Card>> hasEither = [];

  PlayerStage();
  PlayerStage.clone(PlayerStage s) :
        has = Set.from(s.has),
        doesNotHave = Set.from(s.doesNotHave),
        hasEither = [for (final item in s.hasEither) List.from(item)];
}

class Player {
  static int _playerCount = 0;

  String name = "Player ${(++_playerCount).toString()}";
  List<StagePreset> presets = [ StagePreset() ];
  List<PlayerStage> stages = [ PlayerStage() ];

  Player();

  bool isIn(final int stageIndex) => stageIndex < stages.length;
  bool allCardsKnown(final int stageIndex) => presets[stageIndex].isNumCardsKnown() && stages[stageIndex].has.length == presets[stageIndex].numCards;

  void reset() {
    stages = [ PlayerStage() ];

    for (Card card in presets.first.ownedCards) {
      analyseHas(card, 0);
    }
  }

  /*
  * If a player gets a card, they always hold it until they're out.
  */
  void analyseHas(Card card, final int stageIndex) {
    card.analyseOwnedBy(this, stageIndex);

    for (int i = stageIndex; isIn(i); ++i) {
      if (!stages[i].has.add(card)) {
        return;
      }

      if (allCardsKnown(i)) {
        for (Category category in gCategories) {
          for (Card card in category.cards) {
            if (!card.isOwnedBy(this, i)) {
              analyseDoesNotHave([ card ], i);
            }
          }
        }
      }

      reportProgress("$name owns ${card.name} (Stage ${(stageIndex + 1).toString()})");
    }
  }

  /*
  * Once a player gets a card they hold it until they're out.
  * If a Player doesn't have a card, they can't have had it earlier.
  */
  void analyseDoesNotHave(final List<Card> cards, final int stageIndex) {
    for (Card card in cards) {
      card.analyseNotOwnedBy(this, stageIndex);

      bool loop = true;
      for (int i = stageIndex + 1; i != 0 && loop;) {
        if (card.isLocationKnown(--i) || allCardsKnown(i)) {
          loop = stages[i].doesNotHave.remove(card);
        }
        else {
          loop = stages[i].doesNotHave.add(card);
        }
      }
    }

    recheckHasEither();
  }

  /*
  * Process of elimination until we find the card that was shown by this player.
  */
  void analyseHasEither(final List<Card> cards, final int stageIndex) {
    List<Card> possibleCards = [];
    for (Card card in cards) {
      if (card.couldBeOwnedBy(this, stageIndex)) {
        possibleCards.add(card);
      }
    }

    switch (possibleCards.length) {
      case 0:
        throw Contradiction("$name can't have any of those cards");

      case 1:
        analyseHas(possibleCards.first, stageIndex);
        break;

      default:
        stages[stageIndex].hasEither.add(possibleCards);
    }
  }

  /*
  * If a player receives cards from the guesser they still can't have any cards that both them and the guesser couldn't have had earlier.
  */
  void processGuessedWrong(final Player guesser, [final int cardsReceived = -1]) {
    if (presets.length <= stages.length) {
      StagePreset preset = presets.last;
      if (cardsReceived == -1) {
        presets.add(StagePreset(0, preset.ownedCards));
      }
      else {
        presets.add(StagePreset(preset.numCards + cardsReceived, preset.ownedCards));
      }
    }
    else {
      for (Card card in presets[stages.length - 1].ownedCards) {
        analyseHas(card, stages.length - 1);
      }
    }

    stages.add(PlayerStage.clone(stages.last));

    if (presets[stages.length].numCards != 0) {
      stages.last.doesNotHave = stages.last.doesNotHave.intersection(guesser.stages.last.doesNotHave);
    }
  }

  /*
  * Process of elimination until we find a card that was shown by this player.
  */
  void recheckHasEither() {
    for (int i = 0; i != stages.length; ++i) {
      for (int a = 0; a != stages[i].hasEither.length;) {
        for (int b = 0; b != stages[i].hasEither[a].length;) {
          if (stages[i].hasEither[a][b].couldBeOwnedBy(this, i)) {
            ++b;
          }
          else {
            stages[i].hasEither[a].removeAt(b);
          }
        }

        switch (stages[i].hasEither[a].length) {
          case 0:
            throw Contradiction("$name can't have any of the 3 cards they're supposed to");

          case 1:
            analyseHas(stages[i].hasEither[a].first, i);
            stages[i].hasEither.removeAt(a);
            break;

          default:
            ++a;
        }
      }
    }
  }

  String display(final int stageIndex) {
    if (stages.length <= stageIndex) {
      return "";
    }

    final PlayerStage stage = stages[stageIndex];

    return "$name"
      "\n\thas: ${stage.has.map((card) => card.nickname).join(", ")} ${allCardsKnown(stageIndex) ? " (All Cards)" : ""}"
      "\n\thas either: ${stage.hasEither.map((cards) => cards.map((card) => card.nickname).join("/")).join(", ")}"
      "\n\tdoesn't have: ${stage.doesNotHave.map((card) => card.nickname).join(", ")}\n\n";
  }
}
