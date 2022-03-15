import 'dart:core';

import 'card.dart';
import 'player.dart';
import 'turn.dart';


class Contradiction implements Exception {
  final String message;
  Contradiction(this.message);

  @override
  String toString() { return "Contradiction: $message"; }
}

int gNumStages = 1;
String gProgressReport = "";
List<Player> gPlayers = [];
List<Category> gCategories = [];
List<Player> gPlayersOut = [];
List<Player> gPlayersLeft = [];
List<List<Card>> gWrongGuesses = [];
List<Turn> gTurns = [];