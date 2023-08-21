import "package:flutter/material.dart";

import "../../controller/controller.dart";
import "../../model/global.dart";

class CardInfoTab extends StatefulWidget {
  final Controller _controller;
  const CardInfoTab(this._controller, {super.key});

  @override
  State<StatefulWidget> createState() => _CardInfoTabState();
}

class _CardInfoTabState extends State<CardInfoTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final category in gCategories)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(""),
                    Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        for (final cardPair in category.display(0))
                          TableRow(children: [ Text(cardPair.first), Text(cardPair.second) ])
                      ]
                    )
                  ]
                )
            ]
          )
        )
      )
    );
  }
}
