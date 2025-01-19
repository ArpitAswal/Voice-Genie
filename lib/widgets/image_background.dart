import 'package:flutter/material.dart';

class ImageBackground extends StatelessWidget {
  const ImageBackground(
      {super.key,
      required this.childWidget,
      required this.maxWidth,
      required this.minWidth});

  final dynamic childWidget;
  final double maxWidth;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minWidth: minWidth,
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1.0,
                blurRadius: 6.0,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade300,
                Colors.lightGreenAccent.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(24).copyWith(
              topLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: childWidget),
    );
  }
}
