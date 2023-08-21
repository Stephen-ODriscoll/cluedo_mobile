import "package:flutter/material.dart";

import "../components/custom_list_view.dart";
import "../components/custom_button.dart";
import "../popups/player_info_popup.dart";
import "../popups/take_turn_popup.dart";

import "../../controller/controller.dart";
import "../../model/global.dart";

class PlayerInfoTab extends StatefulWidget {
  final Controller _controller;

  const PlayerInfoTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _PlayerInfoTabState();
}

class _PlayerInfoTabState extends State<PlayerInfoTab> {
  int _playerIndex = -1;

  void movePlayerUpAction() {
    setState(() {
      if (0 < _playerIndex) {
        final selected = gPlayersLeft.removeAt(_playerIndex);
        _playerIndex = _playerIndex - 1;
        gPlayersLeft.insert(_playerIndex, selected);
      }
    });
  }

  void movePlayerDownAction() {
    setState(() {
      if (0 <= _playerIndex && _playerIndex < gPlayersLeft.length -1) {
        final selected = gPlayersLeft.removeAt(_playerIndex);
        _playerIndex = _playerIndex + 1;
        gPlayersLeft.insert(_playerIndex, selected);
      }
    });
  }

  void editPlayerAction() {
    showDialog(
        context: context,
        builder: (BuildContext context) => PlayerInfoPopup(_playerIndex)
    );
  }

  void indexChangedAction(int index) {
    setState(() {
      _playerIndex = index;
    });
  }

  void takeTurnAction() {
    showDialog(
        context: context,
        builder: (BuildContext context) => TakeTurnPopup(widget._controller, _playerIndex)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                width: 200,
                child: CustomListView(
                  gPlayersLeft.map((player) => player.name).toList(),
                    _playerIndex,
                    indexChangedAction
                )
              ),
              SizedBox(
                height: 300,
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: (_playerIndex == -1 ? null : movePlayerUpAction),
                      icon: const Icon(Icons.arrow_upward),
                      alignment: Alignment.center,
                    ),
                    IconButton(
                      onPressed: (_playerIndex == -1 ? null : movePlayerDownAction),
                      icon: const Icon(Icons.arrow_downward),
                      alignment: Alignment.center
                    ),
                    IconButton(
                      onPressed: (_playerIndex == -1 ? null : editPlayerAction),
                      icon: const Icon(Icons.edit),
                      alignment: Alignment.center
                    )
                  ]
                )
              )
            ]
          )
        ),
        floatingActionButton: CustomButton("Take Turn", _playerIndex == -1 ? null : takeTurnAction)
    );
  }
}
