import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/constants/common.dart';

class MusicNameAndImageType {
  final String? image;
  final String? title;

  MusicNameAndImageType({this.image, required this.title});
}

class MusicPlayerState {
  final ConcatenatingAudioSource playlist;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final int currentIndex;

  MusicPlayerState({
    required this.playlist,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = -1,
  });

  MusicPlayerState copyWith({
    ConcatenatingAudioSource? playlist,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    int? currentIndex,
  }) {
    return MusicPlayerState(
      playlist: playlist ?? this.playlist,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class MusicPlayerController extends StateNotifier<MusicPlayerState> {
  MusicPlayerController()
      : super(
            MusicPlayerState(playlist: ConcatenatingAudioSource(children: [])));

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> initPlayer() async {
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading,
      );
    });

    _audioPlayer.setLoopMode(LoopMode.all);
  }

  Future<void> setPlaylist(ConcatenatingAudioSource songs,
      [int initialIndex = 0]) async {
    state = state.copyWith(
      playlist: songs,
      currentIndex: initialIndex,
    );
    await _audioPlayer.setAudioSource(songs);
    await playAudio(songs.children[initialIndex]);
  }

  resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<void> playAudio(AudioSource file) async {
    state = state.copyWith(isLoading: true);
    try {
      await _audioPlayer.play();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePlay() {
    if (state.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (state.currentIndex < state.playlist.length - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(currentIndex: nextIndex);
      await playAudio(state.playlist[nextIndex]);
    }
  }

  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      final previousIndex = state.currentIndex - 1;
      state = state.copyWith(currentIndex: previousIndex);
      await playAudio(state.playlist[previousIndex]);
    }
  }
}

class CurrentMusic extends StateNotifier<AudioFile?> {
  CurrentMusic() : super(null);

  init() {
    state = null;
  }

  get value => state;

  setCurrentMusic(AudioFile file) {
    state = file;
  }
}

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerController, MusicPlayerState>((ref) {
  final controller = MusicPlayerController();
  controller.initPlayer();
  return controller;
});

// create a provider who will just return the image and title of the audio
final currentMusicProvider =
    StateNotifierProvider<CurrentMusic, AudioFile?>((ref) {
  final controller = CurrentMusic();
  controller.init();
  return controller;
});
