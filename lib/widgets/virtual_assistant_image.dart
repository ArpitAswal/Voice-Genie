import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class VirtualAssistantImage extends StatelessWidget {
  const VirtualAssistantImage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ZoomIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: width * 0.35,
              width: width * 0.35,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade300,
                    Colors.lightGreenAccent.shade100
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: width * 0.35,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/virtualAssistant.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
