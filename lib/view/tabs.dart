import "package:flutter/material.dart";

import "tabs/main_info_tab.dart";
import "tabs/player_info_tab.dart";
import "tabs/card_info_tab.dart";
import "tabs/turn_info_tab.dart";
import "tabs/settings_tab.dart";

import "popups/error_popup.dart";

import "../controller/controller.dart";

class Tabs extends StatefulWidget {
  final int _numPlayers;
  final String _version;

  const Tabs(this._numPlayers, this._version, {super.key});

  @override
  State<StatefulWidget> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late Controller _controller;

  void updateAll() {
    setState(() {});
  }
  void showErrorPopup(final String title, final String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ErrorPopup(title, message)
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = Controller(widget._numPlayers, widget._version, updateAll, showErrorPopup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.grid_on)),
                Tab(icon: Icon(Icons.format_align_left)),
                Tab(icon: Icon(Icons.format_list_numbered)),
                Tab(icon: Icon(Icons.settings))
              ]
            )
          ),
          body: TabBarView(
            children: [
              MainInfoTab(_controller),
              CardInfoTab(_controller),
              PlayerInfoTab(_controller),
              TurnInfoTab(_controller),
              SettingsTab(_controller)
            ]
          )
        )
      )
    );
  }
}
