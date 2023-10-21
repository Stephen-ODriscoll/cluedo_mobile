import "package:flutter/material.dart";

import "../components/custom_list_view.dart";

import "../../controller/controller.dart";

class TurnInfoTab extends StatefulWidget {
  final Controller _controller;

  const TurnInfoTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _TurnInfoTabState();
}

class _TurnInfoTabState extends State<TurnInfoTab> {
  int? _turnIndex;

  @override
  Widget build(BuildContext context) {
    return CustomListView(
      widget._controller.turnsInfo,
      _turnIndex,
      ((int newIndex) {
        setState(() { _turnIndex = (_turnIndex == newIndex ? null : newIndex); });
      })
    );
  }
}
