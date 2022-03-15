
import "globals.dart";
import "player.dart";


enum Conviction
{
  unknown,
  innocent,
  guilty
}


class _Stage
{
  Player? owner;
  Set<Player> possibleOwners = { };

  _Stage(this.possibleOwners);
}


class Card {
  final String name, nickname;
  final Category category;

  List<_Stage> stages = [];
  Conviction conviction = Conviction.unknown;

  Card(this.name, this.nickname, this.category);

  bool ownerKnown(final int stageIndex) { return stages[stageIndex].owner == null; }
  bool locationKnown(final int stageIndex) { return ownerKnown(stageIndex) || conviction == Conviction.guilty; }
  bool couldBelongTo(final Player player, final int stageIndex) { return stages[stageIndex].possibleOwners.contains(player); }
  bool ownedBy(final Player player, final int stageIndex) { return stages[stageIndex].owner == player; }

  void processInnocent() {
    switch (conviction) {
      case Conviction.guilty:
        throw Contradiction("Deduced that " + name + " is innocent but this card is already guilty");

      case Conviction.unknown:
        if (!category.possibleGuilty.remove(this)) {
          throw Exception("Innocent card " + name + " not found in list of possible guilty cards");
        }

        conviction = Conviction.innocent;
        gProgressReport += name + " has been marked innocent\n";

        recheckLocation();
        category.recheckGuilty();
        break;

      default:
    }
  }

  void processGuilty() {
    switch (conviction) {
      case Conviction.innocent:
        throw Contradiction("Deduced that " + name + " is guilty but this card is already innocent");

      case Conviction.unknown:
        if (category.possibleGuilty.contains(this)) {
          throw Exception("Guilty card " + name + " not found in list of possible guilty cards");
        }

        conviction = Conviction.guilty;
        gProgressReport += name + " has been marked guilty\n";

        for (Card card in category.cards) {
          if (card != this) {
            card.processInnocent();
          }
        }

        for (Player player in gPlayers) {
          player.processDoesntHave([ this ], player.stages.length - 1);
        }
        break;

      default:
    }
  }

  /*
  * Always call processHas, this call will be handled
  *
  * If a player owns this card, then the only players who can have owned it earlier are this player and any players who are now out.
  */
  void processBelongsTo(Player player, final int stageIndex)
  {
    if (ownedBy(player, stageIndex)) {
      return;
    }

    processInnocent();
    if (!couldBelongTo(player, stageIndex)) {
      throw Contradiction(name + " can't be owned by " + player.name + " (Stage " + stageIndex.toString() + ")");
    }

    for (int i = stageIndex; player.isIn(i); ++i) {
      stages[i].owner = player;

      for (Player playerLeft in gPlayersLeft) {
        if (playerLeft != player) {
          playerLeft.processDoesntHave([ this ], i);
        }
      }
    }
  }

  /*
  * Always call processDoesntHave, this call will be handled
  *
  * If this card doesn't belong to a player, they can't have had it earlier.
  * Once a player gets a card they hold it until they're out.
  */
  void processDoesntBelongTo(final Player player, final int stageIndex) {
    if (!couldBelongTo(player, stageIndex)) {
      return;
    }

    if (ownedBy(player, stageIndex)) {
      throw Contradiction("Previous info says " + player.name + " has " + name);
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
    if (couldBelongTo(guesser, stages.length - 1)) {
      stages.add(stages.last);
    }
    else {
      stages.add(_Stage(gPlayersLeft.toSet()));
    }
  }

  /*
  * At every stage check if the card can only be guilty or only be owned by one person.
  */
  void recheckLocation() {
    for (int i = 0; i != stages.length; ++i) {
      if (locationKnown(i)) {
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
}


class Category {
  List<Card> cards = [];
  List<Card> possibleGuilty =[];

  void reset() {
    possibleGuilty = cards;
  }

  void recheckGuilty() {
    switch (possibleGuilty.length) {
      case 0:
        throw Contradiction("Ruled out all cards in category starting with " + cards.first.name);

      case 1:
        possibleGuilty.first.processGuilty();
    }
  }
}