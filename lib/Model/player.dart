import 'dart:core';

import "globals.dart";
import "card.dart";

class _StagePreset {
  int numCards;
  Set<Card> cardsOwned;

  _StagePreset([this.numCards = 0, this.cardsOwned = const { }]);

  bool isNumCardsKnown() {
    return (numCards != 0);
  }
}

// A stage refers to the time between guesses.
// E.g. game starts and we enter stage 1, a player
// guesses wrong thus the cards get passed around
// and we enter stage 2.
class _Stage {
  Set<Card> has;
  Set<Card> doesntHave;
  List<List<Card>> hasEither;

  _Stage([this.has = const { }, this.doesntHave = const { }, this.hasEither = const []]);
}

class Player {
  static int playerCount = 0;

  String name = "Player " + (++playerCount).toString();
  List<_StagePreset> presets = [ _StagePreset()];
  List<_Stage> stages = [ _Stage()];

  Player();

  bool isIn(final int stageIndex) { return (stageIndex < stages.length); }
  bool allCardsKnown(final int stageIndex) { return (presets[stageIndex].isNumCardsKnown() && stages[stageIndex].has.length == presets[stageIndex].numCards); }

  void reset() {
    stages = [ _Stage()];

    for (Card card in presets.first.cardsOwned) {
      processHas(card, 0);
    }
  }

  /*
  * If a player gets a card, they always hold it until they're out.
  */
  void processHas(Card card, final int stageIndex) {
    card.processBelongsTo(this, stageIndex);

    for (int i = stageIndex; isIn(i); ++i)
    {
      if (!stages[i].has.add(card)) {
        return;
      }

      if (allCardsKnown(i)) {
        for (Category category in gCategories) {
          for (Card card in category.cards) {
            if (!card.ownedBy(this, i)) {
              processDoesntHave([ card ], i);
            }
          }
        }
      }

      gProgressReport += name + " owns " + card.name + " (Stage " + (stageIndex + 1).toString() + ")\n";
    }
  }

  /*
  * Once a player gets a card they hold it until they're out.
  * If a Player doesn't have a card, they can't have had it earlier.
  */
  void processDoesntHave(final List<Card> cards, final int stageIndex) {
    for (Card card in cards) {
      card.processDoesntBelongTo(this, stageIndex);

      bool loop = true;
      for (int i = stageIndex + 1; i != 0 && loop;) {
        if (card.locationKnown(--i) || allCardsKnown(i)) {
          loop = stages[i].doesntHave.remove(card);
        }
        else {
          loop = stages[i].doesntHave.add(card);
        }
      }
    }

    recheckHasEither();
  }

  /*
  * Process of elimination until we find the card that was shown by this player.
  */
  void processHasEither(final List<Card> cards, final int stageIndex) {
    List<Card> possibleCards = [];
    for (Card card in cards) {
      if (card.couldBelongTo(this, stageIndex)) {
        possibleCards.add(card);
      }
    }

    switch (possibleCards.length) {
      case 0:
        throw Contradiction(name + " can't have any of those cards");

      case 1:
        processHas(possibleCards.first, stageIndex);
        break;

      default:
        stages[stageIndex].hasEither.add(possibleCards);
    }
  }

  /*
  * If a player receives cards from the guesser they still can't have any cards that both them and the guesser couldn't have had earlier.
  */
  void processGuessedWrong(Player guesser, final int cardsReceived) {
    if (presets.length <= stages.length) {
      _StagePreset preset = presets.last;
      if (cardsReceived == -1) {
        presets.add(_StagePreset(0, preset.cardsOwned));
      }
      else {
        presets.add(_StagePreset(preset.numCards + cardsReceived, preset.cardsOwned));
      }
    }
    else {
      for (Card card in presets[stages.length - 1].cardsOwned) {
        processHas(card, stages.length - 1);
      }
    }

    if (presets[stages.length].numCards != 0) {
      Set<Card> newDoesntHave = stages.last.doesntHave;
      newDoesntHave.intersection(guesser.stages.last.doesntHave);

      stages.add(_Stage(stages.last.has, newDoesntHave, stages.last.hasEither));
    }
    else {
      stages.add(stages.last);
    }
  }

  /*
  * Process of elimination until we find a card that was shown by this player.
  */
  void recheckHasEither() {
    for (int i = 0; i != stages.length; ++i) {
      for (int a = 0; a != stages[i].hasEither.length;) {
        for (int b = 0; b != stages[i].hasEither[a].length;)
        {
          if (stages[i].hasEither[a][b].couldBelongTo(this, i)) {
            ++b;
          }
          else {
            stages[i].hasEither[a].removeAt(b);
          }
        }

        switch (stages[i].hasEither[a].length)
        {
          case 0:
            throw Contradiction(name + " can't have any of the 3 cards they're supposed to");

          case 1:
            processHas(stages[i].hasEither[a].first, i);
            stages[i].hasEither.removeAt(a);
            break;

          default:
            ++a;
        }
      }
    }
  }

  String display(final int stageIndex)
  {
    if (stages.length <= stageIndex) {
      return "";
    }

    final _Stage stage = stages[stageIndex];

    return name +
      "\n\thas: " + stage.has.map((a) => a.nickname).join(", ") + (allCardsKnown(stageIndex) ? " (All Cards)" : "") +
      "\n\thas either: " + stage.hasEither.map((a) => a.map((b) => b.nickname).join("/")).join(", ") +
      "\n\tdoesn't have: " + stage.doesntHave.map((a) => a.nickname).join(", ") + "\n\n";
  }
}