import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:music_player/screens/music_bottom_widget.dart';
import 'package:music_player/screens/music_fallback_icon.dart';

class SingleMusicWidget extends StatelessWidget {
  const SingleMusicWidget({
    super.key,
    required this.file,
    required this.index,
  });

  final AudioFile file;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      onTap: () {
        //! build a bottom sheet and show the audio play pause option
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SlidingBottomSheet();
          },
        );
      },
      // () => playLocalAudio(file.path),
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
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${formatFileSize(file.size)} | ${file.modified.toString().split('.')[0]}',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
