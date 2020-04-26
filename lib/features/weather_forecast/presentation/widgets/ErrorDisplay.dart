import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  const ErrorDisplay({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 18),
    );
  }
}