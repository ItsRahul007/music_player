import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class GetAudioPlayer extends StateNotifier<AudioPlayer?> {
  GetAudioPlayer() : super(null);
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  void init() {
    _player.setLoopMode(LoopMode.all);
    state = _player;
    _init();
  }

  AudioPlayer? get value => state;
}

final getAudioPlayerProvider =
    StateNotifierProvider<GetAudioPlayer, AudioPlayer?>((ref) {
  final controller = GetAudioPlayer();
  controller.init();
  return controller;
});
