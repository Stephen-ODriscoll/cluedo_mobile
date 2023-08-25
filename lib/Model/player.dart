import "../utils/progress_report.dart";
import "../utils/contradiction.dart";

import "../controller/analyser.dart";

import "card.dart";
import "enum.dart";

class StagePreset {
  int numCards;
  Set<Card> ownedCards;

  StagePreset([this.numCards = 0, this.ownedCards = const {}]);
  StagePreset.clone(final StagePreset preset) : numCards = preset.numCards, ownedCards = preset.ownedCards;

  bool allCardsKnown(int numCardsKnown) => numCards != 0 && numCardsKnown == numCards;
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

  int get lastStageIndex => stages.length - 1;
  bool isNotOut([final int? stageIndex]) => (stageIndex == null ? stages.length == presets.length : stageIndex < stages.length);
  bool doesHave(final Card card, final int stageIndex) => stages[stageIndex].has.contains(card);
  bool allCardsKnown(final int stageIndex) => presets[stageIndex].allCardsKnown(stages[stageIndex].has.length);

  void reset(final Analyser analyser) {
    stages = [ PlayerStage() ];

    for (Card card in presets.first.ownedCards) {
      analyser.addDeduction(this, Finding.has, [card], 0);
    }
  }

  /*
  * If a player gets a card, they always hold it until they're out.
  */
  void processHas(final Analyser analyser, final Card card, final int stageIndex) {
    for (int i = stageIndex; isNotOut(i); ++i) {
      if (!stages[i].has.add(card)) {
        return;
      }

      reportProgress("$name owns ${card.name} (Stage ${(stageIndex + 1).toString()})");

      if (allCardsKnown(i)) {
        analyser.addDeduction(this, Finding.allCardsKnown, [], stageIndex);
      }
    }
  }

  /*
  * Process of elimination until we find the card that was shown by this player.
  */
  void processHasEither(final Analyser analyser, final List<Card> cards, final int stageIndex) {
    List<Card> possibleCards = [];
    for (Card card in cards) {
      if (card.couldBeOwnedBy(stageIndex, this)) {
        possibleCards.add(card);
      }
    }

    switch (possibleCards.length) {
      case 0:
        throw Contradiction("$name can't have any of those cards");

      case 1:
        analyser.addDeduction(this, Finding.has, [possibleCards.first], stageIndex);
        break;

      default:
        stages[stageIndex].hasEither.add(possibleCards);
    }
  }

  /*
  * Once a player gets a card they hold it until they're out.
  * If a Player doesn't have a card, they can't have had it earlier.
  */
  void processDoesNotHave(final Analyser analyser, final Card card, final int stageIndex) {
    bool loop = true;
    for (int i = stageIndex; 0 < i && loop; --i) {
      if (card.isLocationKnown(i) || allCardsKnown(i)) {
        loop = stages[i].doesNotHave.remove(card);
      }
      else {
        loop = stages[i].doesNotHave.add(card);

        for (int j = 0; j != stages[i].hasEither.length;) {
          stages[i].hasEither[j].remove(card);

          switch (stages[i].hasEither[j].length) {
            case 0:
              throw Contradiction("$name can't have any of the 3 cards they're supposed to");

            case 1:
              analyser.addDeduction(this, Finding.has, stages[i].hasEither.removeAt(j), stageIndex);
              break;

            default:
              ++j;
          }
        }
      }
    }
  }

  void addPreset([final int? cardsReceived, final List<Card> cards = const []]) {
    final preset = StagePreset.clone(presets.last);
    if (cardsReceived == null) {
      presets.add(StagePreset(0, preset.ownedCards));
    }
    else {
      presets.add(StagePreset(preset.numCards + cardsReceived, preset.ownedCards));
    }
  }

  /*
  * If a player receives cards from the guesser they still can't have any cards that both them and the guesser couldn't have had earlier.
  */
  void processGuessedWrong(final Analyser analyser, final Player guesser) {
    stages.add(PlayerStage.clone(stages.last));

    if (presets[stages.length].numCards != 0) {
      stages.last.doesNotHave = stages.last.doesNotHave.intersection(guesser.stages.last.doesNotHave);
    }

    final int stageIndex = stages.length - 1;
    analyser.addDeduction(this, Finding.has, presets[stageIndex].ownedCards.toList(), stageIndex);
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
