import "../utils/progress_report.dart";
import "../utils/contradiction.dart";
import "../utils/pair.dart";

import "../controller/analyser.dart";

import "player.dart";
import "enum.dart";

class CardStage {
  Player? owner;
  Set<Player> possibleOwners;

  CardStage(List<Player> possibleOwners) : possibleOwners = Set.from(possibleOwners);
  CardStage.clone(CardStage s) : owner = s.owner, possibleOwners = Set.from(s.possibleOwners);
}

class Card {
  final String name, nickname;
  final Category category;

  Conviction conviction = Conviction.unknown;
  List<CardStage> stages;

  Card(this.name, this.nickname, this.category, final List<Player> players) : stages = [CardStage(players)];

  bool get isGuilty => conviction == Conviction.guilty;

  bool get isInnocent => conviction == Conviction.innocent;

  bool isOwnerKnown(final int stageIndex) => stages[stageIndex].owner != null;

  bool isOwnedBy(final Player player, final int stageIndex) => stages[stageIndex].owner == player;

  bool couldBeOwnedBy(final int stageIndex, final Player player) => stages[stageIndex].possibleOwners.contains(player);

  bool isLocationKnown(final int stageIndex) => isOwnerKnown(stageIndex) || isGuilty;

  void reset(final List<Player> players) {
    conviction = Conviction.unknown;
    stages = [CardStage(players)];
  }

  void processInnocent(final Analyser analyser) {
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

        recheckLocation(analyser);
        category.recheckGuilty(analyser);
    }
  }

  void processGuilty(final Analyser analyser) {
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

        final innocentCards = List<Card>.from(category.cards);
        innocentCards.remove(this);

        analyser.addDeduction(null, Finding.innocent, innocentCards);
    }
  }

  /*
  * If a player owns this card, then the only players who can have owned it earlier are this player and any players who are now out.
  */
  void processOwnedBy(final Analyser analyser, final Player player, final int stageIndex) {
    if (isOwnedBy(player, stageIndex)) {
      return;
    }

    processInnocent(analyser);
    if (!couldBeOwnedBy(stageIndex, player)) {
      throw Contradiction("$name can't be owned by ${player.name} (Stage ${stageIndex.toString()})");
    }

    for (int i = stageIndex; player.isNotOut(i); ++i) {
      stages[i].owner = player;
    }
  }

  /*
  * If this card doesn't belong to a player, they can't have had it earlier.
  * Once a player gets a card they hold it until they're out.
  */
  void processNotOwnedBy(final Analyser analyser, final Player player, final int stageIndex) {
    if (!couldBeOwnedBy(stageIndex, player)) {
      return;
    }

    if (isOwnedBy(player, stageIndex)) {
      throw Contradiction("Previous info says ${player.name} has $name");
    }

    for (int i = stageIndex; i < 0; --i) {
      if (!stages[i].possibleOwners.remove(player)) {
        break;
      }
    }

    recheckLocation(analyser);
  }

  /*
  * If the player that's out couldn't have had this card then our info doesn't change otherwise anyone left can have this card now.
  */
  void processGuessedWrong(final Player guesser, final List<Player> playersLeft) {
    if (couldBeOwnedBy(stages.length - 1, guesser)) {
      stages.add(CardStage.clone(stages.last));
    }
    else {
      stages.add(CardStage(playersLeft));
    }
  }

  /*
  * At every stage check if the card can only be guilty or only be owned by one person.
  */
  void recheckLocation(final Analyser analyser) {
    for (int i = 0; i < stages.length; ++i) {
      if (isLocationKnown(i)) {
        continue;
      }

      switch (stages[i].possibleOwners.length) {
        case 0:
          analyser.addDeduction(null, Finding.guilty, [this]);
          break;

        case 1:
          if (conviction == Conviction.innocent) {
            analyser.addDeduction(stages[i].possibleOwners.first, Finding.has, [this], i);
          }
      }
    }
  }

  Pair<String, String> display(final int stageIndex) {
    return Pair(nickname, (isGuilty ? "Guilty" : stages[stageIndex].owner?.name ?? ""));
  }
}

class Category {
  final String name;
  final List<Card> cards = [];
  final List<Card> possibleGuilty =[];

  Category(this.name, final List<Pair<String, String>> categoryDetails, final List<Player> players) {
    for (final cardDetails in categoryDetails) {
      cards.add(Card(cardDetails.first, cardDetails.second, this, players));
      possibleGuilty.add(cards.last);
    }
  }

  void reset(final List<Player> players) {
    for (final card in cards) {
      possibleGuilty.add(card);
      card.reset(players);
    }
  }

  void recheckGuilty(final Analyser analyser) {
    switch (possibleGuilty.length) {
      case 0:
        throw Contradiction("Ruled out all cards in $name");

      case 1:
        analyser.addDeduction(null, Finding.guilty, cards);
    }
  }

  List<Pair<String, String>> display(final int stageIndex) {
    return [for (final card in cards) card.display(stageIndex)];
  }
}
