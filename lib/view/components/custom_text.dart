import "package:flutter/material.dart";

class CustomText extends StatelessWidget {
  final String _text;

  const CustomText(this._text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(_text);
  }
}

class CustomBoldText extends StatelessWidget {
  final String _text;

  const CustomBoldText(this._text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(_text, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}
