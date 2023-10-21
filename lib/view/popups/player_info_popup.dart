import "package:flutter/material.dart";

import "../components/custom_text.dart";
import "../components/custom_button.dart";

import "../../controller/controller.dart";

class PlayerInfoPopup extends StatefulWidget {
  final Controller _controller;

  const PlayerInfoPopup(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _PlayerInfoPopupState();
}

class _PlayerInfoPopupState extends State<PlayerInfoPopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget._controller.selectedPlayerName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomBoldText("Player Info"),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CustomText("Name:"),
              Expanded(
                child: TextField(controller: _textController)
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton("Cancel", (() { Navigator.pop(context); })),
              CustomButton("Submit", (() {
                Navigator.pop(context);
                widget._controller.rename(_textController.text);
              }))
            ]
          )
        ]
      )
    );
  }
}
