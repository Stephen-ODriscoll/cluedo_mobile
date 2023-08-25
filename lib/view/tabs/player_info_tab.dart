import "package:flutter/material.dart";

import "../components/custom_list_view.dart";
import "../components/custom_button.dart";

import "../popups/player_info_popup.dart";
import "../popups/take_turn_popup.dart";

import "../../controller/controller.dart";

class PlayerInfoTab extends StatefulWidget {
  final Controller _controller;

  const PlayerInfoTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _PlayerInfoTabState();
}

class _PlayerInfoTabState extends State<PlayerInfoTab> {
  int getPlayerIndex() {
    return widget._controller.selectedPlayerIndex;
  }

  void editPlayerAction() {
    showDialog(
        context: context,
        builder: (BuildContext context) => PlayerInfoPopup(widget._controller)
    );
  }

  void takeTurnAction() {
    showDialog(
        context: context,
        builder: (BuildContext context) => TakeTurnPopup(widget._controller)
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
                  widget._controller.playerNames,
                    getPlayerIndex(),
                    ((int newIndex) {
                      setState(() {
                        widget._controller.selectedPlayerIndex = newIndex;
                      });
                    })
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
                      onPressed: (!widget._controller.enableMovePlayerUp ? null : () {
                        setState(() { widget._controller.movePlayerUp(); });
                      }),
                      icon: const Icon(Icons.arrow_upward),
                      alignment: Alignment.center,
                    ),
                    IconButton(
                      onPressed: (!widget._controller.enableMovePlayerDown ? null : () {
                        setState(() { widget._controller.movePlayerDown(); });
                      }),
                      icon: const Icon(Icons.arrow_downward),
                      alignment: Alignment.center
                    ),
                    IconButton(
                      onPressed: (!widget._controller.enableEditPlayer ? null : editPlayerAction),
                      icon: const Icon(Icons.edit),
                      alignment: Alignment.center
                    )
                  ]
                )
              )
            ]
          )
        ),
        floatingActionButton: CustomButton("Take Turn", getPlayerIndex() == -1 ? null : takeTurnAction)
    );
  }
}
