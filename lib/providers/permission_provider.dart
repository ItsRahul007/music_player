import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/constants/common.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  final List<AudioFile> audioFiles;
  final String dropdownValue;
  final bool isLoading;
  final bool havePermission;

  PermissionState({
    required this.audioFiles,
    required this.dropdownValue,
    required this.isLoading,
    required this.havePermission,
  });

  PermissionState copyWith({
    List<AudioFile>? audioFiles,
    String? dropdownValue,
    bool? isLoading,
    bool? havePermission,
  }) {
    return PermissionState(
      audioFiles: audioFiles ?? this.audioFiles,
      dropdownValue: dropdownValue ?? this.dropdownValue,
      isLoading: isLoading ?? this.isLoading,
      havePermission: havePermission ?? this.havePermission,
    );
  }
}

class PermissionProvider extends StateNotifier<PermissionState> {
  PermissionProvider()
      : super(PermissionState(
          audioFiles: [],
          dropdownValue: orderByOptions.first,
          isLoading: false,
          havePermission: false,
        ));

  Future<void> requestAudioPermissions() async {
    state = state.copyWith(isLoading: true);

    final isPermissionAlreadyGranted = await checkAudioPermissions();
    if (isPermissionAlreadyGranted) {
      await scanForAudioFiles();
    } else {
      final status = await Permission.audio.request();
      if (status.isGranted) {
        state = state.copyWith(havePermission: true);
        await scanForAudioFiles();
      }
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> manualRequestPermission() async {
    state = state.copyWith(isLoading: true);

    PermissionStatus status = await Permission.audio.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      await Future.delayed(Duration(milliseconds: 500));
      status = await Permission.audio.status;
      if (status.isGranted) {
        state = state.copyWith(havePermission: true);
        await scanForAudioFiles();
      }
    } else {
      status = await Permission.audio.request();
      if (status.isGranted) {
        state = state.copyWith(havePermission: true);
        await scanForAudioFiles();
      }
    }

    state = state.copyWith(isLoading: false);
  }

  Future<bool> checkAudioPermissions() async {
    bool permission = await Permission.audio.isGranted;
    state = state.copyWith(havePermission: permission);
    return permission;
  }

  Future<void> scanForAudioFiles() async {
    try {
      Directory rootDir = Directory('/storage/emulated/0');
      List<FileSystemEntity> files = await scanDirectory(rootDir);
      List<AudioFile> newAudioFiles = await Future.wait(
          files.map((file) => processAudioFile(file as File)));

      state = state.copyWith(audioFiles: newAudioFiles);
      changeAudioFilesArrayOrder(state.dropdownValue);
    } catch (e) {
      throw FileSystemException('Error scanning files: $e');
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

// Update the provider definition
final permissionProvider =
    StateNotifierProvider<PermissionProvider, PermissionState>((ref) {
  return PermissionProvider();
});
