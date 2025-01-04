// Create a new file: lib/providers/music_player_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:path_provider/path_provider.dart';

class MusicNameAndImageType {
  final String? image;
  final String? title;

  MusicNameAndImageType({this.image, required this.title});
}

class MusicPlayerState {
  final AudioFile? currentSong;
  final List<AudioFile> playlist;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final int currentIndex;

  MusicPlayerState({
    this.currentSong,
    required this.playlist,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = -1,
  });

  MusicPlayerState copyWith({
    AudioFile? currentSong,
    List<AudioFile>? playlist,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    int? currentIndex,
  }) {
    return MusicPlayerState(
      currentSong: currentSong ?? this.currentSong,
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
  MusicPlayerController() : super(MusicPlayerState(playlist: []));

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

  Future<void> setPlaylist(List<AudioFile> songs,
      [int initialIndex = 0]) async {
    state = state.copyWith(
      playlist: songs,
      currentIndex: initialIndex,
      currentSong: songs[initialIndex],
    );
    await playAudio(songs[initialIndex]);
  }

  resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<Uri> _base64ToNotificationImage(
      String? base64String, String name) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/${name.split(" ").join("_")}.jpg';
    final file = File(imagePath);

    if (base64String != null && base64String.isNotEmpty) {
      // Use base64 if available
      final bytes = base64.decode(base64String);
      await file.writeAsBytes(bytes);
    } else {
      // Fall back to asset image
      final bytes = await rootBundle.load('assets/images/icon.jpg');
      await file.writeAsBytes(bytes.buffer.asUint8List());
    }

    return Uri.file(imagePath);
  }

  Future<void> playAudio(AudioFile file) async {
    state = state.copyWith(isLoading: true, currentSong: file);
    try {
      Uri filePath =
          await _base64ToNotificationImage(file.base64Str, file.name);
      final audioSource = AudioSource.uri(Uri.file(file.path),
          tag: MediaItem(
            id: file.path,
            title: file.name,
            album: file.artist ?? 'Unknown',
            artUri: filePath,
          ));

      await _audioPlayer.setAudioSource(audioSource);
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
