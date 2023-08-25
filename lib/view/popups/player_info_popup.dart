import "package:flutter/material.dart";

import "../../controller/controller.dart";

class PlayerInfoPopup extends StatefulWidget {
  final Controller _controller;

  const PlayerInfoPopup(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _PlayerInfoPopupState();
}

class _PlayerInfoPopupState extends State<PlayerInfoPopup> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }
}
