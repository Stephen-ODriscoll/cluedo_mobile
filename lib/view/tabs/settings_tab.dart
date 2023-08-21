import "package:flutter/material.dart";

import "../../controller/controller.dart";
import "../../model/global.dart";
import "../../model/player.dart";

class SettingsTab extends StatefulWidget {
  final Controller _controller;
  const SettingsTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
