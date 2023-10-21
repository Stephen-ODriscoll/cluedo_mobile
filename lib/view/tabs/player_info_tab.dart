import "package:flutter/material.dart";

import "../components/custom_text.dart";

import "../../controller/controller.dart";

class PlayerInfoTab extends StatelessWidget {
  final Controller _controller;

  const PlayerInfoTab(this._controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: CustomText(_controller.currentPlayersInfo)
      )
    );
  }
}
