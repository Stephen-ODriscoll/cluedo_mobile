import "../utils/progress_report.dart";
import "../utils/contradiction.dart";
import "../utils/pair.dart";

import "global.dart";
import "player.dart";

enum Conviction {
  unknown,
  innocent,
  guilty
}

class CardStage {
  Player? owner;
  Set<Player> possibleOwners;

  CardStage(List<Player> possibleOwners) : possibleOwners = possibleOwners.toSet();
  CardStage.clone(CardStage s) : owner = s.owner, possibleOwners = Set.from(s.possibleOwners);
}

class Card {
  final String name, nickname;
  final Category category;

  Conviction conviction = Conviction.unknown;
  List<CardStage> stages = [CardStage(gPlayers)];

  Card(this.name, this.nickname, this.category);

  bool isGuilty() => conviction == Conviction.guilty;

  bool isOwnerKnown(final int stageIndex) => stages[stageIndex].owner == null;

  bool isOwnedBy(final Player player, final int stageIndex) => stages[stageIndex].owner == player;

  bool isLocationKnown(final int stageIndex) => isOwnerKnown(stageIndex) || isGuilty();

  bool couldBeOwnedBy(final Player player, final int stageIndex) => stages[stageIndex].possibleOwners.contains(player);

  void reset() {
    stages = [ CardStage(gPlayers)];
    conviction = Conviction.unknown;
  }

  void processInnocent() {
    switch (conviction) {
      case Conviction.guilty:
        throw Contradiction("Deduced that $name is innocent but this card is already guilty");

      case Conviction.innocent:
        break;

      case Conviction.unknown:
        if (!category.possibleGuilty.remove(this)) {
          throw Exception("Innocent card $name not found in list of possible guilty cards");
        }

        conviction = Conviction.innocent;
        reportProgress("$name has been marked innocent");

        recheckLocation();
        category.recheckGuilty();
    }
  }

  void processGuilty() {
    switch (conviction) {
      case Conviction.guilty:
        break;

      case Conviction.innocent:
        throw Contradiction("Deduced that $name is guilty but this card is already innocent");

      case Conviction.unknown:
        if (category.possibleGuilty.contains(this)) {
          throw Exception("Guilty card $name not found in list of possible guilty cards");
        }

        conviction = Conviction.guilty;
        reportProgress("$name has been marked guilty");

        for (Card card in category.cards) {
          if (card != this) {
            card.processInnocent();
          }
        }

        for (Player player in gPlayers) {
          player.processDoesNotHave([this], player.stages.length - 1);
        }
    }
  }

  /*
  * Always call processHas, this call will be handled
  *
  * If a player owns this card, then the only players who can have owned it earlier are this player and any players who are now out.
  */
  void processOwnedBy(Player player, final int stageIndex) {
    if (isOwnedBy(player, stageIndex)) {
      return;
    }

    processInnocent();
    if (!couldBeOwnedBy(player, stageIndex)) {
      throw Contradiction("$name can't be owned by ${player.name} (Stage ${stageIndex.toString()})");
    }

    for (int i = stageIndex; player.isIn(i); ++i) {
      stages[i].owner = player;

      for (Player playerLeft in gPlayersLeft) {
        if (playerLeft != player) {
          playerLeft.processDoesNotHave([ this], i);
        }
      }
    }
  }

  /*
  * Always call processDoesNotBelongTo, this call will be handled
  *
  * If this card doesn't belong to a player, they can't have had it earlier.
  * Once a player gets a card they hold it until they're out.
  */
  void processNotOwnedBy(final Player player, final int stageIndex) {
    if (!couldBeOwnedBy(player, stageIndex)) {
      return;
    }

    if (isOwnedBy(player, stageIndex)) {
      throw Contradiction("Previous info says ${player.name} has $name");
    }

    for (int i = stageIndex + 1; i != 0;) {
      if (!stages[--i].possibleOwners.remove(player)) {
        break;
      }
    }

    recheckLocation();
  }

  /*
  * If the player that's out couldn't have had this card then our info doesn't change otherwise anyone left can have this card now.
  */
  void processGuessedWrong(final Player guesser) {
    if (couldBeOwnedBy(guesser, stages.length - 1)) {
      stages.add(CardStage.clone(stages.last));
    }
    else {
      stages.add(CardStage(gPlayersLeft));
    }
  }

  /*
  * At every stage check if the card can only be guilty or only be owned by one person.
  */
  void recheckLocation() {
    for (int i = 0; i != stages.length; ++i) {
      if (isLocationKnown(i)) {
        continue;
      }

      switch (stages[i].possibleOwners.length) {
        case 0:
          processGuilty();
          break;

        case 1:
          if (conviction == Conviction.innocent) {
            stages[i].possibleOwners.first.processHas(this, i);
          }
      }
    }
  }

  Pair<String, String> display(final int stageIndex) {
    return Pair(nickname, stages[stageIndex].owner?.name ?? (isGuilty() ? "Guilty" : ""));
  }
}

class Category {
  String name;
  List<Card> cards = [];
  List<Card> possibleGuilty =[];

  Category(this.name);

  void reset() {
    for (Card card in cards) {
      card.reset();
      possibleGuilty.add(card);
    }
  }

  void recheckGuilty() {
    switch (possibleGuilty.length) {
      case 0:
        throw Contradiction("Ruled out all cards in $name");

      case 1:
        possibleGuilty.first.processGuilty();
    }
  }

  List<Pair<String, String>> display(final int stageIndex) {
    return [ for (Card card in cards) card.display(stageIndex)];
  }
}
