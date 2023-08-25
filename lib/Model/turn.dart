import "player.dart";
import "card.dart";
import "enum.dart";

abstract class Turn {
  final Player detective;
  final Action action;

  Turn(this.detective, this.action);

  bool redistribute() => false;
  String witnessName() => "";
  @override String toString();
}

class Missed extends Turn {
  Missed(final Player detective) :
        super(detective, Action.missed);

  @override String toString() => "${detective.name} missed a turn";
}


class Asked extends Turn {
  final Player witness;
  final List<Card> cards;
  final bool shown;
  final int shownIndex;

  Asked(final Player detective, this.witness, this.cards, this.shown, [this.shownIndex = -1]) :
        super(detective, Action.asked);

  @override
  String witnessName() => witness.name;

  @override
  String toString() => "${witness.name} ${shown ? "has either" : "doesn't have"} ${cards.map((a) => a.nickname).join(", ")}";
}


class Guessed extends Turn {
  final bool correct;
  final List<Card> cards;
  final List<int?> redistribution;

  Guessed(final Player detective, this.cards, this.correct, this.redistribution) :
      super(detective, Action.guessed);

  @override
  bool redistribute() => !correct;

  @override
  String toString() => "${detective.name} guessed ${(correct ? "correctly" : "incorrectly")} ${cards.map((a) => a.nickname).join(", ")}";
}
