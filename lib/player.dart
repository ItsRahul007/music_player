import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

final _player = AudioPlayer();

bool isPlaying = false;
String prevPath = '';

Future<void> playLocalAudio(String filePath) async {
  try {
    await _player.stop();
    await _player.setUrl('file:$filePath');
    isPlaying && prevPath == filePath
        ? await _player.pause()
        : await _player.play();

    isPlaying = !isPlaying;
    prevPath = filePath;
  } on PlayerException catch (e) {
    debugPrint('Error playing audio: $e');
  }
}

bool checkIsPlaying() {
  return isPlaying;
}
