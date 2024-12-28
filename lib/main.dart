import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/screens/audio_files.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A music player app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          canvasColor: Colors.grey.shade900,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.black87,
            textStyle: TextStyle(color: Colors.white),
          )),
      home: const AudioFileScanner(),
    );
  }
}
