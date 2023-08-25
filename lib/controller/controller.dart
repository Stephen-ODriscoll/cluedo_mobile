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

    StorageManager storageManager = StorageManager();
    if (!storageManager.versions.containsKey(version)) {
      throw Exception("Couldn't find config for version $version");
    }

    final versionSetup = storageManager.versions[version];

    for (final categoryEntry in versionSetup.entries) {
      _categories.add(Category(categoryEntry.key,
          [for (final cardDetails in categoryEntry.value) Pair(cardDetails[0], cardDetails[1])]
          , _players));
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

  List<String> get playerNames =>
      [for (final player in _playersLeft) player.name] +
          [ for (int i = stageNumber - 1; i < _playersOut.length; ++i) _playersOut[i].name];

  int get numCategories => _categories.length;

  List<CategoryInfo> get categoriesInfo =>
      List.from(_categories.map(
              (category) => CategoryInfo(category.name, List.from(category.cards.map(
                      (card) => card.display(stageNumber - 1))))));

  bool get enableMovePlayerUp => (0 < selectedPlayerIndex && selectedPlayerIndex < _playersLeft.length);

  bool get enableMovePlayerDown => (0 <= selectedPlayerIndex && selectedPlayerIndex < _playersLeft.length - 1);

  bool get enableEditPlayer => (0 <= selectedPlayerIndex);

  void _reAnalyseAll() {
    _analyser.reset();
    for (Turn turn in _turns) {
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

    _updateGUI();
  }

  void rename(final Player player, final String newName) {
    if (player.name == newName) {
      return;
    }

    if (_players.indexWhere((p) => p.name == newName) != -1) {
      throw Exception("Player with that name already exists");
    }

    player.name = newName;
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

  void _moveToBack(final Player player) {
    int index = _playersLeft.indexOf(player);
    if (index == -1) {
      throw Exception("Failed to find ${player.name} in players left");
    }

    _playersLeft.add(_playersLeft.removeAt(index));
  }

  void createTurn(
    int detectiveIndex,
    int actionIndex,
    int witnessIndex,
    List<int> cardIndexes,
    bool success,
    int shownIndex) {
    switch (Action.values[actionIndex]) {
      case Action.missed:
        processTurn(Missed(_players[detectiveIndex]));
        break;

      case Action.asked:
        List<Card> cards = [ for (final (i, cardIndex) in cardIndexes.indexed) _categories[i].cards[cardIndex]];
        processTurn(Asked(_players[detectiveIndex], _players[witnessIndex], cards, success, shownIndex));
        break;

      case Action.guessed:
        List<Card> cards = [ for (final (i, cardIndex) in cardIndexes.indexed) _categories[i].cards[cardIndex]];
        processTurn(Guessed(_players[detectiveIndex], cards, success, []));
        break;
    }
  }
}
