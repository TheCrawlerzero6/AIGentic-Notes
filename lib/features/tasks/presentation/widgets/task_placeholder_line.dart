import 'package:flutter/material.dart';

class TaskPlaceholderLine extends StatelessWidget {
  const TaskPlaceholderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BoxBorder.fromLTRB(
              bottom: BorderSide(color: Colors.grey.withAlpha(20), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
