import "package:flutter/material.dart";

import "custom_text.dart";

class CustomListView extends StatelessWidget {
  final List<String> _items;
  final int? _selectedIndex;
  final void Function(int) _indexChangedAction;

  const CustomListView(this._items, this._selectedIndex, this._indexChangedAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)
      ),
      child: ListView(
        children: [
          for (final (index, item) in _items.indexed) ListTile(
            title: CustomText(item),
            selected: (index == _selectedIndex),
            selectedColor: Colors.black,
            selectedTileColor: Colors.blueAccent,
            onTap: () { _indexChangedAction(index); }
          )
        ]
      )
    );
  }
}
