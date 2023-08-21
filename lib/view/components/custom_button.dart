import "package:flutter/material.dart";

class CustomButton extends StatelessWidget {

  final String _text;
  final void Function()? _action;

  const CustomButton(this._text, this._action, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: _action, child: Text(_text));
  }
}
