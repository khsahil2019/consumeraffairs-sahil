import 'package:flutter/material.dart';

class HelpListItem extends StatelessWidget {
  final String question;
  const HelpListItem({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
        padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(30.0),
    ),
    child: Text(
    question,
      style: TextStyle(fontSize: 16.0),
    ),
        ),
    );
  }
}