import "package:flutter/material.dart";

import "../components/custom_button.dart";

import "../../controller/controller.dart";
import "../../model/global.dart";

class TakeTurnPopup extends StatefulWidget {

  final Controller _controller;
  final int _playerIndex;

  const TakeTurnPopup(this._controller, this._playerIndex, {super.key});

  @override
  State<StatefulWidget> createState() => _TakeTurnPopupState();
}

class _TakeTurnPopupState extends State<TakeTurnPopup> {

  int _detectiveIndex = 0;
  int _actionIndex = 0;
  int _witnessIndex = 0;
  final List<int> _cardIndexes = [for (final _ in gCategories) 0];
  bool _success = false;
  int _shownIndex = 0;

  @override
  void initState() {
    super.initState();
    _detectiveIndex = widget._playerIndex;
    _witnessIndex = (_detectiveIndex == 0 ? 1 : 0);
    _shownIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Take Turn"),
      content: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Player:"),
                DropdownButton(
                  value: _detectiveIndex,
                  items: [
                    for (final (i, player) in gPlayersLeft.indexed)
                      DropdownMenuItem(value: i, child: Text(player.name))
                  ],
                  onChanged: (int? newIndex) {
                    setState(() {
                      _detectiveIndex = newIndex!;
                    });
                  }
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Action:"),
                DropdownButton(
                    value: _actionIndex,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("Missed")),
                      DropdownMenuItem(value: 1, child: Text("Asked")),
                      DropdownMenuItem(value: 2, child: Text("Guessed"))
                    ],
                    onChanged: (int? newIndex) {
                      setState(() { _actionIndex = newIndex!; });
                    }
                )
              ]
            ),
            if (_actionIndex == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Player:"),
                  DropdownButton(
                      value: _witnessIndex,
                      items: [
                        for (final (i, player) in gPlayersLeft.indexed)
                          DropdownMenuItem(value: i, child: Text(player.name))
                      ],
                      onChanged: (int? newIndex) {
                        setState(() { _witnessIndex = newIndex!; });
                      }
                  )
                ]
              ),
            if (_actionIndex != 0)
              Column(
              children: [
                const Text(""),
                for (final (i, category) in gCategories.indexed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("${category.name}:"),
                      DropdownButton(
                        value: _cardIndexes[i],
                        items: [
                          for (final (j, card) in category.cards.indexed)
                            DropdownMenuItem(value: j, child: Text(card.name))
                        ],
                        onChanged: (int? newIndex) {
                          setState(() { _cardIndexes[i] = newIndex!; });
                        }
                      )
                    ]
                  ),
                const Text(""),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(_actionIndex == 1 ? "Shown:" : "Correct:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Yes"),
                        Radio(
                          value: true,
                          groupValue: _success,
                          onChanged: (Object? _) {
                            setState(() { _success = true; });
                          }
                        )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No"),
                        Radio(
                          value: false,
                          groupValue: _success,
                          onChanged: (Object? _) {
                          setState(() { _success = false; });
                          }
                        )
                      ]
                    )
                  ]
                ),
                if (_actionIndex == 1 && _success)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("Which:"),
                      DropdownButton(
                          value: _shownIndex,
                          items: [
                            const DropdownMenuItem(value: -1, child: Text("Unknown")),
                            for (final (i, category) in gCategories.indexed)
                              DropdownMenuItem(value: i, child: Text(category.cards[_cardIndexes[i]].name))
                          ],
                          onChanged: (int? newIndex) {
                            setState(() { _shownIndex = newIndex!; });
                          }
                      )
                    ]
                  )
              ]
            ),
            const Text(""),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton("Cancel", (() { Navigator.pop(context); })),
                CustomButton("Submit", (() {
                  widget._controller.createTurn(
                      _detectiveIndex,
                      _actionIndex,
                      _witnessIndex,
                      _cardIndexes,
                      _success,
                      _shownIndex);

                  Navigator.pop(context); }))
              ]
            )
          ],
        )
      )
    );
  }
}
