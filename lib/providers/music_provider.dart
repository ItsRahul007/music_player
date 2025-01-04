import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:id3/id3.dart';
import 'package:music_player/constants/common.dart';

class MusicProviderState {
  final List<AudioFile> audioFiles;
  final String dropdownValue;
  final bool isLoading;

  MusicProviderState(
      {required this.audioFiles,
      required this.dropdownValue,
      this.isLoading = false});

  MusicProviderState copyWith({
    List<AudioFile>? audioFiles,
    String? dropdownValue,
    bool? isLoading,
  }) {
    return MusicProviderState(
      audioFiles: audioFiles ?? this.audioFiles,
      dropdownValue: dropdownValue ?? this.dropdownValue,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MusicProvider extends StateNotifier<MusicProviderState> {
  MusicProvider()
      : super(MusicProviderState(
            audioFiles: [], dropdownValue: orderByOptions.first));

  get value => state.audioFiles;

  Future<void> scanForAudioFiles() async {
    state = state.copyWith(isLoading: true);
    try {
      Directory rootDir = Directory('/storage/emulated/0');
      List<FileSystemEntity> files = await _scanDirectory(rootDir);
      List<AudioFile> newAudioFiles = await Future.wait(
          files.map((file) => _processAudioFile(file as File)));

      state = state.copyWith(audioFiles: newAudioFiles);
      changeAudioFilesArrayOrder(state.dropdownValue);
    } catch (e) {
      throw FileSystemException('Error scanning files: $e');
    }
    state = state.copyWith(isLoading: false);
  }

  Future<AudioFile> _processAudioFile(File file) async {
    String? artist;
    String? base64Str;

    if (file.path.toLowerCase().endsWith('.mp3')) {
      Map<String, dynamic>? data = await _iD3ProcessAudioFile(file);
      if (data != null && data.containsKey("APIC")) {
        // Check if "APIC" exists
        final apicData = data["APIC"];
        artist = data["Artist"];
        if (apicData is Map && apicData.containsKey("base64")) {
          // Check "base64"
          base64Str = apicData["base64"];
        }
      }
    }

    return AudioFile(
      path: file.path,
      name: file.path.split('/').last,
      size: file.lengthSync(),
      modified: file.lastModifiedSync(),
      artist: artist,
      base64Str: base64Str,
    );
  }

  Future<List<FileSystemEntity>> _scanDirectory(Directory directory) async {
    List<FileSystemEntity> audioFiles = [];
    try {
      List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        if (entity is Directory) {
          if (!entity.path.contains('/Android/') &&
              !entity.path.split('/').last.startsWith('.')) {
            audioFiles.addAll(await _scanDirectory(entity));
          }
        } else if (entity is File) {
          String path = entity.path.toLowerCase();
          if (path.endsWith('.mp3') ||
              path.endsWith('.wav') ||
              path.endsWith('.m4a') ||
              path.endsWith('.aac')) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      debugPrint('Skipping directory: ${directory.path}');
    }
    return audioFiles;
  }

  Future<Map<String, dynamic>?> _iD3ProcessAudioFile(File file) async {
    try {
      List<int> mp3Bytes = File(file.path).readAsBytesSync();
      MP3Instance mp3instance = MP3Instance(mp3Bytes);

      if (mp3instance.parseTagsSync()) {
        // print(mp3instance.getMetaTags());
        return mp3instance.getMetaTags()!;
      } else {
        debugPrint('Error processing file metadata: ${file.path}');
        return null;
      }
    } on (Error,) {
      debugPrint("something went wrong");
      return null;
    }
  }

  void changeAudioFilesArrayOrder(String type) {
    if (state.audioFiles.isEmpty) return;

    List<AudioFile> sortedFiles = [...state.audioFiles];

    if (type.toLowerCase() == "size") {
      sortedFiles.sort((a, b) => b.size.compareTo(a.size));
    } else if (type.toLowerCase() == "name") {
      sortedFiles.sort((a, b) => a.name.compareTo(b.name));
    } else if (type.toLowerCase() == "latest first") {
      sortedFiles.sort((a, b) => b.modified.compareTo(a.modified));
    } else if (type.toLowerCase() == "oldest first") {
      sortedFiles.sort((a, b) => a.modified.compareTo(b.modified));
    }

    state = state.copyWith(
      audioFiles: sortedFiles,
      dropdownValue: type,
    );
  }
}

final musicProvider =
    StateNotifierProvider<MusicProvider, MusicProviderState>((ref) {
  final controller = MusicProvider();
  return controller;
});
