import "package:flutter/material.dart";

import "../../model/global.dart";

class PlayerInfoPopup extends StatefulWidget {

  final int _playerIndex;

  const PlayerInfoPopup(this._playerIndex, {super.key});

  @override
  State<StatefulWidget> createState() => _PlayerInfoPopupState();
}

class _PlayerInfoPopupState extends State<PlayerInfoPopup> {

  int selectedPlayerIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedPlayerIndex = widget._playerIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }
}
