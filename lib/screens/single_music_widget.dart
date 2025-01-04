import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:music_player/providers/permission_provider.dart';
import 'package:music_player/screens/music_bottom_widget.dart';
import 'package:music_player/providers/music_player_provider.dart';
import 'package:music_player/screens/music_fallback_icon.dart';

class SingleMusicWidget extends ConsumerWidget {
  const SingleMusicWidget({
    super.key,
    required this.file,
    required this.index,
  });

  final AudioFile file;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setPlayState = ref.read(musicPlayerProvider.notifier);
    final currentMusic = ref.watch(currentMusicProvider);
    final setCurrentMusic = ref.read(currentMusicProvider.notifier);

    return ListTile(
      isThreeLine: true,
      onTap: () async {
        // Get the current playlist from the permission provider
        final playlist = ref.read(permissionProvider).audioFiles;

        if (currentMusic == null || file.name != currentMusic.name) {
          setCurrentMusic.setCurrentMusic(file);
          setPlayState.setPlaylist(playlist, index);
        } else {
          setPlayState.resumeAudio();
        }

        // Show bottom sheet
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          builder: (BuildContext context) => const SlidingBottomSheet(),
        );
      },
      leading: file.base64Str != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.memory(
                base64Decode(file.base64Str!),
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    MusicFallbackIcon(),
              ),
            )
          : MusicFallbackIcon(),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: file.name != currentMusic?.name
                ? Colors.white
                : Colors.blueAccent),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatFileSize(file.size)} | ${file.modified.toString().split('.')[0]}',
            style: TextStyle(
                color: file.name != currentMusic?.name
                    ? Colors.white70
                    : Colors.blueAccent.shade700),
          ),
        ],
      ),
    );
  }
}
