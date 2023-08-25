import "package:flutter/material.dart";

import "tabs/progress_report_tab.dart";
import "tabs/player_info_tab.dart";
import "tabs/card_info_tab.dart";
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
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.portrait)),
                Tab(icon: Icon(Icons.grid_on_sharp)),
                Tab(icon: Icon(Icons.output)),
                Tab(icon: Icon(Icons.settings))
              ]
            )
          ),
          body: TabBarView(
            children: [
              PlayerInfoTab(_controller),
              CardInfoTab(_controller),
              const ProgressReportTab(),
              SettingsTab(_controller)
            ]
          )
        )
      )
    );
  }
}
