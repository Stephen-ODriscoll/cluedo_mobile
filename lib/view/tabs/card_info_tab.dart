import "package:flutter/material.dart";

import "../components/custom_text.dart";

import "../../controller/controller.dart";

class CardInfoTab extends StatelessWidget {
  final Controller _controller;

  const CardInfoTab(this._controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final categoryInfo in _controller.categoriesInfo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(""),
                  CustomBoldText(categoryInfo.name),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      for (final cardInfo in categoryInfo.cardsInfo)
                        TableRow(children: [CustomText(cardInfo.first), CustomText(cardInfo.second)])
                    ]
                  )
                ]
              )
          ]
        )
      )
    );
  }
}
