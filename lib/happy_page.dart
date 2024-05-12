import 'package:flutter/material.dart';

class HappyPage extends StatelessWidget {
  const HappyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade100,
                  Color(0xF5CC8ED7),
                  Color(0xFF8F3D7E),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}