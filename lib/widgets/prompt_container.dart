import 'package:flutter/material.dart';

class PromptContainer extends StatelessWidget {
  const PromptContainer({super.key, required this.child});

  final dynamic child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade600, width: 1.25),
        borderRadius: BorderRadius.circular(24)
            .copyWith(topLeft: Radius.zero, bottomRight: Radius.zero),
      ),
      child: child,
    );
  }
}
