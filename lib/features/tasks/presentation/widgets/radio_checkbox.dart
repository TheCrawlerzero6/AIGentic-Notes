import 'package:flutter/material.dart';

class RadioCheckbox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color borderColor;

  const RadioCheckbox({
    super.key,
    required this.value,
    required this.onTap,
    this.size = 22,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: value
            ? Center(
                child: Container(
                  width: size * 0.45,
                  height: size * 0.45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
