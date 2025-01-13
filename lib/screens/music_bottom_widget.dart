// Update music_bottom_widget.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:music_player/providers/music_player_provider.dart';
import 'package:music_player/screens/music_fallback_icon.dart';

class SlidingBottomSheet extends StatelessWidget {
  const SlidingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Song Info Row
          Consumer(builder: (context, ref, child) {
            final currentMusic = ref.watch(currentMusicProvider).currentMusic;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (currentMusic != null && currentMusic.base64Str != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(base64Decode(currentMusic.base64Str!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              MusicFallbackIcon(
                                iconSize: 60,
                              )),
                    )
                  else
                    MusicFallbackIcon(
                      iconSize: 60,
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMusic?.name ?? 'No song selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // Progress Bar
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer(builder: (context, ref, child) {
                final playerState = ref.watch(musicPlayerProvider);

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: playerState.position.inSeconds.toDouble(),
                        max: playerState.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          ref.read(musicPlayerProvider.notifier).seekTo(
                                Duration(seconds: value.toInt()),
                              );
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey.shade800,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(playerState.position),
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            formatDuration(playerState.duration),
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })),

          // Control Buttons
          Consumer(builder: (context, ref, child) {
            final playerState = ref.watch(musicPlayerProvider);
            final setPlayState = ref.read(musicPlayerProvider.notifier);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.skip_previous, color: Colors.white, size: 32),
                  onPressed: () async {
                    await setPlayState.playPrevious();
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    playerState.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: () async => await setPlayState.togglePlay(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 32),
                  onPressed: () async {
                    await setPlayState.playNext();
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
