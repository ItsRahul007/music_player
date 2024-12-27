import 'dart:io';

import 'package:flutter/material.dart';
import 'package:id3/id3.dart';

class AudioFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final String? artist;
  final String? base64Str; //! it will be the thumbnail image

  AudioFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    this.artist,
    this.base64Str,
  });
}

Future<List<FileSystemEntity>> scanDirectory(Directory directory) async {
  List<FileSystemEntity> audioFiles = [];
  try {
    List<FileSystemEntity> entities = directory.listSync();
    for (var entity in entities) {
      if (entity is Directory) {
        if (!entity.path.contains('/Android/') &&
            !entity.path.split('/').last.startsWith('.')) {
          audioFiles.addAll(await scanDirectory(entity));
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
    print('Skipping directory: ${directory.path}');
  }
  return audioFiles;
}

Future<AudioFile> processAudioFile(File file) async {
  String? artist;
  String? base64Str;

  if (file.path.toLowerCase().endsWith('.mp3')) {
    Map<String, dynamic>? data = await iD3ProcessAudioFile(file);
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

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

Future<Map<String, dynamic>?> iD3ProcessAudioFile(File file) async {
  try {
    List<int> mp3Bytes = File(file.path).readAsBytesSync();
    MP3Instance mp3instance = new MP3Instance(mp3Bytes);

// !{
// !  "Title": "SongName",
// !  "Artist": "ArtistName",
// !  "Album": "AlbumName",
// !  "APIC": {
// !    "mime": "image/jpeg",
// !    "textEncoding": "0",
// !    "picType": "0",
// !    "description": "description",
// !    "base64": "AP/Y/+AAEEpGSUYAAQEBAE..."
// !  }
// !}

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
