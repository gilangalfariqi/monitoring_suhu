import 'package:flutter/material.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    Color color = condition == "Panas"
        ? Colors.redAccent
        : condition == "Dingin"
        ? Colors.blueAccent
        : Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Condition: $condition",
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
