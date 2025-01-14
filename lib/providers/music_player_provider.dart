import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/constants/common.dart';
import 'package:music_player/providers/get_audio_player.dart';

class MusicNameAndImageType {
  final String? image;
  final String? title;

  MusicNameAndImageType({this.image, required this.title});
}

class CurrentMusicState {
  final AudioFile? currentMusic;
  final List<AudioFile> audioFiles;

  CurrentMusicState({this.currentMusic, required this.audioFiles});

  CurrentMusicState copyWith(
      {AudioFile? currentMusic, List<AudioFile>? audioFiles}) {
    return CurrentMusicState(
        currentMusic: currentMusic ?? this.currentMusic,
        audioFiles: audioFiles ?? this.audioFiles);
  }
}

class MusicPlayerState {
  final ConcatenatingAudioSource playlist;
  final List<AudioFile> audioFiles;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final int currentIndex;

  MusicPlayerState({
    required this.playlist,
    required this.audioFiles,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = -1,
  });

  MusicPlayerState copyWith({
    ConcatenatingAudioSource? playlist,
    List<AudioFile>? audioFiles,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    int? currentIndex,
  }) {
    return MusicPlayerState(
      playlist: playlist ?? this.playlist,
      audioFiles: audioFiles ?? this.audioFiles,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class MusicPlayerController extends StateNotifier<MusicPlayerState> {
  final AudioPlayer audioPlayer;

  MusicPlayerController(this.audioPlayer)
      : super(MusicPlayerState(
            playlist: ConcatenatingAudioSource(children: []), audioFiles: []));

  Future<void> initPlayer() async {
    audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading,
      );
    });

    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        state = state.copyWith(currentIndex: index);
      }
    });
  }

  Future<void> setPlaylist(
      ConcatenatingAudioSource songs, List<AudioFile> audioFiles,
      [int initialIndex = 0]) async {
    state = state.copyWith(
      playlist: songs,
      audioFiles: audioFiles,
    );

    await audioPlayer.setAudioSource(songs, initialIndex: initialIndex);
    await audioPlayer.stop();
  }

  Future setPlaylistAndPlay(
      ConcatenatingAudioSource songs, List<AudioFile> audioFiles,
      [int initialIndex = 0]) async {
    await setPlaylist(songs, audioFiles, initialIndex);
    await playAudio();
  }

  resumeAudio() async {
    await audioPlayer.play();
  }

  Future<void> playAudio() async {
    state = state.copyWith(isLoading: true);
    try {
      await audioPlayer.stop();
      await audioPlayer.play();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> togglePlay() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (state.currentIndex < state.playlist.length - 1) {
      await audioPlayer.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      await audioPlayer.seekToPrevious();
    }
  }
}

class CurrentMusic extends StateNotifier<CurrentMusicState> {
  final AudioPlayer audioPlayer;
  CurrentMusic(this.audioPlayer)
      : super(CurrentMusicState(currentMusic: null, audioFiles: []));

  init() {
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        state = state.copyWith(currentMusic: state.audioFiles[index]);
      }
    });
  }

  get value => state;

  setAudioFiles(List<AudioFile> files) {
    state = state.copyWith(audioFiles: files);
  }
}

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerController, MusicPlayerState>((ref) {
  final audioPlayer = ref.watch(getAudioPlayerProvider);
  final controller = MusicPlayerController(audioPlayer!);
  controller.initPlayer();
  return controller;
});

// create a provider who will just return the image and title of the audio
final currentMusicProvider =
    StateNotifierProvider<CurrentMusic, CurrentMusicState>((ref) {
  final audioPlayer = ref.watch(getAudioPlayerProvider);
  final controller = CurrentMusic(audioPlayer!);
  controller.init();
  return controller;
});
