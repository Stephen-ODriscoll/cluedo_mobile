import "../utils/progress_report.dart";
import "../utils/pair.dart";
import "../model/constant.dart";
import "../model/global.dart";
import "../model/player.dart";
import "../model/turn.dart";
import "../model/card.dart";
import "storage.dart";

class Controller {
  bool _gameOver = false;
  final void Function() _updateAllAction;
  
  Controller(final int numPlayers, final String version, this._updateAllAction) {
    gNumStages = 1;
    for (int i = 0; i != numPlayers; ++i) {
      gPlayers.add(Player());
      gPlayersLeft.add(gPlayers.last);
    }

    StorageManager storageManager = StorageManager();
    if (!storageManager.versions.containsKey(version)) {
      throw Exception("Couldn't find setup for version $version");
    }

    gCategories.clear();
    final versionSetup = storageManager.versions[version];
    for (final categoryEntry in versionSetup.entries) {
      gCategories.add(Category(categoryEntry.key));
      for (final cardDetails in categoryEntry.value) {
        Card card = Card(cardDetails[0], cardDetails[1], gCategories.last);
        gCategories.last.cards.add(card);
        gCategories.last.possibleGuilty.add(card);
      }
    }

    resetProgressReport(START_MESSAGE);
  }

  void reAnalyseAll() {
    gNumStages = 1;
    _gameOver = false;
    gPlayersOut.clear();
    gPlayersLeft.clear();
    gWrongGuesses.clear();

    for (Category category in gCategories) {
      category.reset();
    }

    for (Player player in gPlayers) {
      player.reset();
      gPlayersLeft.add(player);
    }

    resetProgressReport(START_MESSAGE);

    // Start analysis again
    for (Turn turn in gTurns) {
      analyseTurn(turn);
    }

    _updateAllAction();
  }

  void processTurn(final Turn newTurn, {final Turn? oldTurn}) {
    if (oldTurn != null) {
      int index = gTurns.indexOf(oldTurn);
      if (index == -1) {
        throw Exception("Failed to find turn in turns list");
      }

      gTurns[index] = newTurn;
      reAnalyseAll();
    }
    else {
      analyseTurn(newTurn);
      gTurns.add(newTurn);
    }

    _updateAllAction();
  }

  void analyseTurn(final Turn turn) {
    reportProgress(turn.toString());

    switch (turn.action) {
      case Action.missed:
        moveToBack(turn.detective);
        break;

      case Action.asked:
        analyseAsked(turn as Asked);
        moveToBack(turn.detective);
        break;

      case Action.guessed:
        analyseGuessed(turn as Guessed);
        break;
    }
  }

  void analyseAsked(final Asked asked) {
    Player witness = asked.witness;

    if (asked.shown) {
      if (asked.shownIndex != -1) {
        if (asked.cards.length <= asked.shownIndex) {
          throw Exception("Failed to find card shown");
        }

        witness.analyseHas(asked.cards[asked.shownIndex], gNumStages - 1);
      }
      else {
        witness.analyseHasEither(asked.cards, gNumStages - 1);
      }
    }
    else {
      witness.analyseDoesNotHave(asked.cards, gNumStages - 1);
    }
  }

  void analyseGuessed(final Guessed guessed) {
    if (guessed.correct) {
      _gameOver = true;
    }
    else {
      Player detective = guessed.detective;

      int index = gPlayersLeft.indexOf(detective);
      if (index == -1) {
        throw Exception("Failed to find ${detective.name} in players left");
      }

      gPlayersLeft.removeAt(index);
      gPlayersOut.add(detective);

      // Create new player analyses
      if (guessed.redistribution.isEmpty) {
        for (Player playerLeft in gPlayersLeft) {
          playerLeft.processGuessedWrong(detective);
        }
      }
      else {
        for (int i = 0; i != gPlayersLeft.length; ++i) {
          gPlayersLeft[i].processGuessedWrong(detective, guessed.redistribution[i]);
        }
      }

      for (Category category in gCategories) {
        for (Card card in category.cards) {
          card.analyseGuessedWrong(detective);
        }
      }

      gWrongGuesses.add(guessed.cards);
      ++gNumStages;
    }
  }

  void rename(final Player player, final String newName) {
    if (player.name == newName) {
      return;
    }

    if (gPlayers.indexWhere((p) => p.name == newName) != -1) {
      throw Exception("Player with that name already exists");
    }

    player.name = newName;
  }

  void updatePresets(final Player player, List<StagePreset> newPresets) {
    if (newPresets == player.presets) {
      return;
    }

    player.presets = newPresets;
    reAnalyseAll();
  }

  void moveToBack(final Player player) {
    int index = gPlayersLeft.indexOf(player);
    if (index == -1) {
      throw Exception("Failed to find ${player.name} in players left");
    }

    gPlayersLeft.removeAt(index);
    gPlayersLeft.add(player);
  }

  void createTurn(
    int detectiveIndex,
    int actionIndex,
    int witnessIndex,
    List<int> cardIndexes,
    bool success,
    int shownIndex) {
    for (final text in gCategories) {
      text.name = "";
    }

    switch (actionIndex) {
      case 0:
        processTurn(Missed(gPlayers[detectiveIndex]));
        break;

      case 1:
        List<Card> cards = [ for (final (i, cardIndex) in cardIndexes.indexed) gCategories[i].cards[cardIndex]];
        processTurn(Asked(gPlayers[detectiveIndex], gPlayers[witnessIndex], cards, success, shownIndex));
      break;

      case 2:
        List<Card> cards = [ for (final (i, cardIndex) in cardIndexes.indexed) gCategories[i].cards[cardIndex]];
        processTurn(Asked(gPlayers[detectiveIndex], gPlayers[witnessIndex], cards, success, shownIndex));
    }
  }
}
