import 'package:flutter/material.dart';

class MusicFallbackIcon extends StatelessWidget {
  const MusicFallbackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Color.fromARGB(255, 75, 53, 74),
              width: 1,
            )),
        child: Center(
            child: Icon(
          Icons.audiotrack,
          color: Colors.purpleAccent,
        )));
  }
}
