import 'package:flutter/material.dart';

class HomeOptionWidget extends StatelessWidget {
  final String title;
  final String middleSymbol;
  final String valueText;

  const HomeOptionWidget({
    super.key,
    required this.title,
    required this.middleSymbol,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Text(
            middleSymbol,
            style: const TextStyle(fontSize: 20.0),
          ),
          Text(
            valueText,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
