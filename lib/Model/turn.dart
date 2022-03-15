import "player.dart";
import "card.dart";

enum Action
{
  missed,
  asked,
  guessed
}


abstract class Turn {
  final Action action;
  final Player detective;

  Turn(this.detective, this.action);

  bool redistribute() { return false; }
  String witnessName() { return ""; }
  @override String toString();
}


class Missed extends Turn {
  Missed(final Player detective) :
        super(detective, Action.missed);

  @override String toString() {
    return detective.name + " missed a turn";
  }
}


class Asked extends Turn {
  final Player witness;
  final List<Card> cards;
  final bool shown;
  final int? shownIndex;

  Asked(final Player detective, this.witness, this.cards, this.shown, [this.shownIndex]) :
        super(detective, Action.asked);

  @override
  String witnessName() { return witness.name; }

  @override
  String toString() {
    return witness.name + (shown ? " has either " : " doesn't have ") + cards.map((a) => a.nickname).join(", ");
  }
}


class Guessed extends Turn {
  final bool correct;
  final List<Card> cards;
  final List<int> redistribution;

  Guessed(final Player detective, this.cards, this.correct, this.redistribution) :
      super(detective, Action.guessed);

  @override
  bool redistribute() { return !correct; }

  @override
  String toString() {
    return detective.name + " guessed " + (correct ? "correctly " : "incorrectly ") + cards.map((a) => a.nickname).join(", ");
  }
}