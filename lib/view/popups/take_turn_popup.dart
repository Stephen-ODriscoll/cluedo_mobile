import "package:flutter/material.dart";

import "../components/custom_button.dart";
import "../components/custom_text.dart";

import "../../controller/controller.dart";

class TakeTurnPopup extends StatefulWidget {
  final Controller _controller;

  const TakeTurnPopup(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _TakeTurnPopupState();
}

class _TakeTurnPopupState extends State<TakeTurnPopup> {
  late int _detectiveIndex;
  late int _actionIndex;
  late int _witnessIndex;
  late List<int> _cardIndexes;
  late bool _success;
  late int _shownIndex;

  @override
  void initState() {
    super.initState();
    _detectiveIndex = widget._controller.selectedPlayerIndex;
    _actionIndex = 0;
    _witnessIndex = (_detectiveIndex == 0 ? 1 : 0);
    _cardIndexes = [for (int i = 0; i < widget._controller.numCategories; ++i) 0];
    _success = false;
    _shownIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomBoldText("Take Turn"),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CustomText("Detective:"),
              DropdownButton(
                value: _detectiveIndex,
                items: [
                  for (final (i, playerName) in widget._controller.currentPlayerNames.indexed)
                    DropdownMenuItem(value: i, child: CustomText(playerName))
                ],
                onChanged: (int? newIndex) {
                  setState(() {
                    final previous = _detectiveIndex;
                    _detectiveIndex = newIndex!;
                    _witnessIndex = (_witnessIndex == _detectiveIndex) ? previous : _witnessIndex;
                  });
                }
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CustomText("Action:"),
              DropdownButton(
                value: _actionIndex,
                items: const [
                  DropdownMenuItem(value: 0, child: CustomText("Missed")),
                  DropdownMenuItem(value: 1, child: CustomText("Asked")),
                  DropdownMenuItem(value: 2, child: CustomText("Guessed"))
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
                const CustomText("Witness:"),
                DropdownButton(
                  value: _witnessIndex,
                  items: [
                    for (final (i, playerName) in widget._controller.currentPlayerNames.indexed)
                      if (i != _detectiveIndex)
                        DropdownMenuItem(value: i, child: CustomText(playerName))
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
              const CustomText(""),
              for (final (i, categoryInfo) in widget._controller.categoriesInfo.indexed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomText("${categoryInfo.name}:"),
                    DropdownButton(
                      value: _cardIndexes[i],
                      items: [
                        for (final (j, cardInfo) in categoryInfo.cardsInfo.indexed)
                          DropdownMenuItem(value: j, child: CustomText(cardInfo.first))
                      ],
                      onChanged: (int? newIndex) {
                        setState(() { _cardIndexes[i] = newIndex!; });
                      }
                    )
                  ]
                ),
              const CustomText(""),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(_actionIndex == 1 ? "Shown:" : "Correct:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText("Yes"),
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
                      const CustomText("No"),
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
                    const CustomText("Which:"),
                    DropdownButton(
                      value: _shownIndex,
                      items: [
                        const DropdownMenuItem(value: -1, child: CustomText("Unknown")),
                        for (final (i, categoryInfo) in widget._controller.categoriesInfo.indexed)
                          DropdownMenuItem(value: i, child: CustomText(categoryInfo.cardsInfo[_cardIndexes[i]].first))
                      ],
                      onChanged: (int? newIndex) {
                        setState(() { _shownIndex = newIndex!; });
                      }
                    )
                  ]
                )
            ]
          ),
          const CustomText(""),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton("Cancel", (() { Navigator.pop(context); })),
              CustomButton("Submit", (() {
                Navigator.pop(context);
                widget._controller.createTurn(
                  _detectiveIndex,
                  _actionIndex,
                  _witnessIndex,
                  _cardIndexes,
                  _success,
                  _shownIndex);
              }))
            ]
          )
        ]
      )
    );
  }
}
