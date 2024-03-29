import "package:flutter/material.dart";

import "../components/custom_list_view.dart";
import "../components/custom_button.dart";

import "../popups/player_info_popup.dart";
import "../popups/take_turn_popup.dart";

import "../../controller/controller.dart";

class MainInfoTab extends StatefulWidget {
  final Controller _controller;

  const MainInfoTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _MainInfoTabState();
}

class _MainInfoTabState extends State<MainInfoTab> {
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
              height: 338,
              width: 220,
              child: CustomListView(
                widget._controller.currentPlayerNames,
                getPlayerIndex(),
                ((int newIndex) {
                  setState(() {
                    if (widget._controller.selectedPlayerIndex == newIndex) {
                      widget._controller.selectedPlayerIndex = -1;  // deselect
                    }
                    else {
                      widget._controller.selectedPlayerIndex = newIndex;
                    }
                  });
                })
              )
            ),
            SizedBox(
              height: 338,
              width: 80,
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
      floatingActionButton: CustomButton("Take Turn", !widget._controller.enableTakeTurn ? null : takeTurnAction)
    );
  }
}
