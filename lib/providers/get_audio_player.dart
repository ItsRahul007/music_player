import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class GetAudioPlayer extends StateNotifier<AudioPlayer?> {
  GetAudioPlayer() : super(null);

  final AudioPlayer _audioPlayer = AudioPlayer();

  void init() {
    _audioPlayer.setLoopMode(LoopMode.all);
    state = _audioPlayer;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  AudioPlayer? get value => state;
}

final getAudioPlayerProvider =
    StateNotifierProvider<GetAudioPlayer, AudioPlayer?>((ref) {
  final controller = GetAudioPlayer();
  controller.init();
  return controller;
});
