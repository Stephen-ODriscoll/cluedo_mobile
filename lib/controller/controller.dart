import "../utils/contradiction.dart";
import "../utils/pair.dart";

import "../model/player.dart";
import "../model/turn.dart";
import "../model/card.dart";
import "../model/enum.dart";

import "analyser.dart";
import "storage.dart";

class CategoryInfo {
  final String name;
  final List<Pair<String, String>> cardsInfo;

  CategoryInfo(this.name, this.cardsInfo);
}

class Controller {
  final List<Turn> _turns = [];
  final List<Player> _players = [];
  final List<Player> _playersOut = [];
  final List<Player> _playersLeft = [];
  final List<Category> _categories = [];
  late final Analyser _analyser;

  final void Function() _updateGUI;
  final void Function(String, String) _errorPopup;

  Controller(final int numPlayers, final String version, this._updateGUI, this._errorPopup) {
    for (int i = 0; i < numPlayers; ++i) {
      _players.add(Player());
    }

    final storageManager = StorageManager();
    if (!storageManager.versions.containsKey(version)) {
      throw Exception("Couldn't find config for version $version");
    }

    final versionSetup = storageManager.versions[version];
    for (final categoryEntry in versionSetup.entries) {
      _categories.add(
        Category(
          categoryEntry.key,
          [for (final cardDetails in categoryEntry.value) Pair(cardDetails[0], cardDetails[1])],
          _players
        )
      );
    }

    _analyser = Analyser(_players, _playersOut, _playersLeft, _categories);
  }

  int stageNumber = 1;
  int selectedPlayerIndex = -1;
  Status _status = Status.okay;

  String get getStatus {
    switch (_status) {
      case Status.okay:           return "Okay";
      case Status.infoNeeded:     return "Info Needed";
      case Status.contradiction:  return "Contradiction";
      case Status.exception:      return "Exception";
    }
  }

  List<Pair<int, String>> get actionStrings => [
    Pair(Action.missed.index,  "Missed"),
    Pair(Action.asked.index,   "Asked"),
    Pair(Action.guessed.index, "Guessed")
  ];

  bool get enableMovePlayerUp => (0 < selectedPlayerIndex && selectedPlayerIndex < _playersLeft.length);

  bool get enableMovePlayerDown => (0 <= selectedPlayerIndex && selectedPlayerIndex < _playersLeft.length - 1);

  bool get enableTakeTurn => (0 <= selectedPlayerIndex && selectedPlayerIndex < _playersLeft.length);

  bool get enableEditPlayer => (0 <= selectedPlayerIndex);

  List<Player> get _currentPlayers =>
    _playersLeft.toList() + [for (int i = _playersOut.length - 1; stageNumber < i; --i) _playersOut[i]];

  String get selectedPlayerName => _currentPlayers[selectedPlayerIndex].name;

  List<String> get currentPlayerNames => [for (final player in _currentPlayers) player.name];

  String get currentPlayersInfo => [for (final player in _currentPlayers) player.display(stageNumber - 1)].join("\n");

  int get numCategories => _categories.length;

  List<CategoryInfo> get categoriesInfo =>
    [for (final category in _categories) CategoryInfo(
      category.name, [for (final card in category.cards) card.display(stageNumber - 1)])];

  int get numTurns => _turns.length;

  List<String> get turnsInfo => [for (final turn in _turns) turn.display()];

  void _reAnalyseAll() {
    _analyser.reset();
    for (final turn in _turns) {
      _analyser.analyseTurn(turn);
    }
  }

  void processTurn(final Turn newTurn, [final Turn? oldTurn]) {
    try {
      if (oldTurn != null) {
        int index = _turns.indexOf(oldTurn);
        if (index == -1) {
          throw Exception("Failed to find turn in turns list");
        }

        _turns[index] = newTurn;
        _reAnalyseAll();
      }
      else {
        _turns.add(newTurn);
        _analyser.analyseTurn(newTurn);
      }
    }
    on Contradiction catch(contradiction) {
      _status = Status.contradiction;
      _errorPopup("Contradiction Occurred", contradiction.toString());
    }
    on Exception catch(exception) {
      _status = Status.exception;
      _errorPopup("Exception Occurred", exception.toString());
    }

    _moveToBack();
    _updateGUI();
  }

  void rename(final String newName) {
    final player = _currentPlayers[selectedPlayerIndex];

    if (player.name == newName) {
      return;
    }

    if (_players.indexWhere((player) => player.name == newName) != -1) {
      _errorPopup("Error", "Player with the name $newName already exists");
    }
    else {
      player.name = newName;
      _updateGUI();
    }
  }

  void updatePresets(final Player player, List<StagePreset> newPresets) {
    try {
      if (newPresets == player.presets) {
        return;
      }

      player.presets = newPresets;
      _reAnalyseAll();
    }
    on Contradiction catch(contradiction) {
      _status = Status.contradiction;
      _errorPopup("Contradiction Occurred", contradiction.toString());
    }
    on Exception catch(exception) {
      _status = Status.exception;
      _errorPopup("Exception Occurred", exception.toString());
    }
  }

  void movePlayerUp() {
    final player = _playersLeft.removeAt(selectedPlayerIndex);
    _playersLeft.insert(--selectedPlayerIndex, player);
  }

  void movePlayerDown() {
    final player = _playersLeft.removeAt(selectedPlayerIndex);
    _playersLeft.insert(++selectedPlayerIndex, player);
  }

  void _moveToBack() {
    _playersLeft.add(_playersLeft.removeAt(selectedPlayerIndex));
    selectedPlayerIndex = -1;
  }

  void createTurn(
    final int detectiveIndex,
    final int actionIndex,
    final int witnessIndex,
    final List<int> cardIndexes,
    final bool success,
    final int shownIndex) {
    switch (Action.values[actionIndex]) {
      case Action.missed:
        processTurn(Missed(_players[detectiveIndex]));
        break;

      case Action.asked:
        List<Card> cards = [for (final (i, cardIndex) in cardIndexes.indexed) _categories[i].cards[cardIndex]];
        processTurn(Asked(_players[detectiveIndex], _players[witnessIndex], cards, success, shownIndex));
        break;

      case Action.guessed:
        List<Card> cards = [for (final (i, cardIndex) in cardIndexes.indexed) _categories[i].cards[cardIndex]];
        processTurn(Guessed(_players[detectiveIndex], cards, success, []));
        break;
    }
  }
}
