import "../utils/progress_report.dart";

import "../model/constant.dart";
import "../model/player.dart";
import "../model/card.dart";
import "../model/turn.dart";
import "../model/enum.dart";

class _Deduction {
  final Player? player;
  final Finding finding;
  final List<Card> cards;
  final int stageIndex;

  _Deduction(this.player, this.finding, this.cards, this.stageIndex);
}

class Analyser {
  bool _gameOver = false;
  final List<Player> _players;
  final List<Player> _playersOut;
  final List<Player> _playersLeft;
  final List<Category> _categories;
  final List<List<Card>> _wrongGuesses = [];

  final List<_Deduction> _deductions = [];

  Analyser(this._players, this._playersOut, this._playersLeft, this._categories) {
    _playersLeft.clear();
    for (final player in _players) {
      _playersLeft.add(player);
    }

    resetProgressReport(START_MESSAGE);
  }

  void reset() {
    _gameOver = false;
    _playersOut.clear();
    _playersLeft.clear();
    _wrongGuesses.clear();

    for (final player in _players) {
      _playersLeft.add(player);
      player.reset(this);
    }

    for (final category in _categories) {
      category.reset(_playersLeft);
    }

    resetProgressReport(START_MESSAGE);
  }

  void addDeduction(
      final Player? player,
      final Finding finding,
      final List<Card> cards,
      [final int stageIndex = -1]) {
    _deductions.add(_Deduction(player, finding, cards, stageIndex));
  }

  void _startAnalysis() {
    while (_deductions.isNotEmpty) {
      final deduction   = _deductions.removeLast();

      final thisPlayer    = deduction.player;
      final theseCards    = deduction.cards;
      final stageIndex    = deduction.stageIndex;

      switch (deduction.finding) {
        case Finding.has:
          thisPlayer!;
          for (final card in theseCards) {
            card.processOwnedBy(this, thisPlayer, stageIndex);
            thisPlayer.processHas(this, card, stageIndex);

            for (final player in _players) {
              if (player != thisPlayer && player.isNotOut(stageIndex)) {
                player.processDoesNotHave(this, card, stageIndex);
              }
            }
          }
          break;

        case Finding.hasEither:
          thisPlayer!.processHasEither(this, theseCards, stageIndex);
          break;

        case Finding.doesNotHave:
          thisPlayer!;
          for (final card in theseCards) {
            card.processNotOwnedBy(this, thisPlayer, stageIndex);
            thisPlayer.processDoesNotHave(this, card, stageIndex);
          }
          break;

        case Finding.guessedWrong:
          thisPlayer!;
          for (final category in _categories) {
            for (final card in category.cards) {
              card.processGuessedWrong(thisPlayer, _playersLeft);
            }
          }

          for (final player in _playersLeft) {
            player.processGuessedWrong(this, thisPlayer);
          }
          break;

        case Finding.allCardsKnown:
          thisPlayer!;
          final List<Card> unownedCards = [];
          for (final category in _categories) {
            for (final card in category.cards) {
              if (!thisPlayer.doesHave(card, stageIndex)) {
                unownedCards.add(card);
              }
            }
          }

          addDeduction(thisPlayer, Finding.doesNotHave, unownedCards, stageIndex);
          break;

        case Finding.guilty:
          for (final card in theseCards) {
            card.processGuilty(this);
          }

          for (final player in _players) {
            addDeduction(player, Finding.doesNotHave, theseCards, player.lastStageIndex);
          }
          break;

        case Finding.innocent:
          for (final card in theseCards) {
            card.processInnocent(this);
          }
          break;
      }
    }
  }

  void analyseTurn(final Turn turn) {
    switch (turn.action) {
      case Action.missed:
        break;

      case Action.asked:
        _analyseAsked(turn as Asked);
        break;

      case Action.guessed:
        _analyseGuessed(turn as Guessed);
        break;
    }
  }

  void _analyseAsked(final Asked asked) {
    final witness = asked.witness;

    if (asked.shown) {
      if (asked.shownIndex != -1) {
        if (asked.cards.length <= asked.shownIndex) {
          throw Exception("Failed to find card shown");
        }

        addDeduction(witness, Finding.has, [asked.cards[asked.shownIndex]], witness.lastStageIndex);
      }
      else {
        addDeduction(witness, Finding.hasEither, asked.cards, witness.lastStageIndex);
      }
    }
    else {
      addDeduction(witness, Finding.doesNotHave, asked.cards, witness.lastStageIndex);
    }

    _startAnalysis();
  }

  void _analyseGuessed(final Guessed guessed) {
    if (guessed.correct) {
      _gameOver = true;
    }
    else {
      final detective = guessed.detective;

      _playersOut.add(detective);
      _playersLeft.remove(detective);
      _wrongGuesses.add(guessed.cards);

      for (final (i, player) in _playersLeft.indexed) {
        player.addPreset(guessed.redistribution[i]);
      }

      addDeduction(detective, Finding.guessedWrong, guessed.cards);
    }
  }
}
