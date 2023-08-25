import "package:flutter/material.dart";

import "../components/custom_text.dart";

import "../../controller/controller.dart";

class TurnInfoTab extends StatelessWidget {
  final Controller _controller;

  const TurnInfoTab(this._controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomText(_controller.turnsInfo.join("\n"));
  }
}
