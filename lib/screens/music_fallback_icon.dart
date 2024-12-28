import 'package:flutter/material.dart';

class MusicFallbackIcon extends StatelessWidget {
  final double? iconSize;
  const MusicFallbackIcon({super.key, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: iconSize ?? 45,
        height: iconSize ?? 45,
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
