import "package:flutter/material.dart";

import "../components/custom_text.dart";

class ErrorPopup extends StatelessWidget {
  final String _title;
  final String _message;

  const ErrorPopup(this._title, this._message, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomText(_title),
      content: CustomText(_message));
  }
}
