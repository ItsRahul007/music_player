import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/constants/common.dart';
import 'package:music_player/providers/music_player_provider.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/permission_provider.dart';
import 'package:music_player/screens/do_not_have_permission.dart';
import 'package:music_player/screens/empty_musics.dart';
import 'package:music_player/screens/loading.dart';
import 'package:music_player/screens/music_bottom_widget.dart';
import 'package:music_player/screens/music_fallback_icon.dart';
import 'package:music_player/screens/single_music_widget.dart';

class AudioFileScanner extends ConsumerStatefulWidget {
  const AudioFileScanner({super.key});

  @override
  ConsumerState<AudioFileScanner> createState() => _AudioFileScannerState();
}

class _AudioFileScannerState extends ConsumerState<AudioFileScanner> {
  @override
  void initState() {
    Future(() async {
      final permission = ref.watch(permissionProvider);
      if (permission.havePermission) {
        await ref.read(musicProvider.notifier).scanForAudioFiles();
      } else {
        final state = await ref
            .read(permissionProvider.notifier)
            .requestAudioPermissions();
        if (state) {
          await ref.read(musicProvider.notifier).scanForAudioFiles();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicProvider);
    final changeMusic = ref.read(musicProvider.notifier);
    final permission = ref.watch(permissionProvider);
    final currentPlayingMusic = ref.watch(currentMusicProvider);

    if (music.isLoading || permission.isLoading) {
      return const Loading();
    }

    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: const Text(
            'Musics',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            Row(
              children: [
                Text(
                  "Order by:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
                SizedBox(width: 15),
                DropdownButton<String>(
                  value: music.dropdownValue,
                  items: orderByOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      changeMusic.changeAudioFilesArrayOrder(value);
                    }
                  },
                  elevation: 16,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          ],
          backgroundColor: Colors.grey.shade900,
          elevation: 50,
        ),
        body: SafeArea(
            child: !permission.havePermission
                ? DoNotHavePermission()
                : music.audioFiles.isNotEmpty
                    ? Stack(
                        children: [
                          ListView.builder(
                            itemCount: music.audioFiles.length,
                            itemBuilder: (context, index) => SingleMusicWidget(
                              file: music.audioFiles[index],
                              index: index,
                              isLast: index == music.audioFiles.length - 1 &&
                                  currentPlayingMusic != null,
                            ),
                          ),
                          currentPlayingMusic != null
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _bottomBar())
                              : SizedBox.shrink(),
                        ],
                      )
                    : EmptyMusics()));
  }

  Widget _bottomBar() {
    void onWidgetClick() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (BuildContext context) => const SlidingBottomSheet(),
      );
    }

    return Consumer(builder: (context, ref, child) {
      final currentPlayingMusic = ref.watch(currentMusicProvider);
      return Container(
        height: 70,
        margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade900, blurRadius: 10, spreadRadius: 10)
            ]),
        child: Row(
          children: [
            if (currentPlayingMusic != null &&
                currentPlayingMusic.base64Str != null)
              InkWell(
                onTap: () => onWidgetClick(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(currentPlayingMusic.base64Str!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade800,
                      child: Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
              )
            else
              InkWell(
                onTap: () => onWidgetClick(),
                child: MusicFallbackIcon(
                  iconSize: 50,
                ),
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => onWidgetClick(),
                    child: Text(
                      currentPlayingMusic?.name ?? 'No song selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Consumer(builder: (context, ref, child) {
                    final playerState = ref.watch(musicPlayerProvider);
                    final setPlayState = ref.read(musicPlayerProvider.notifier);
                    final setCurrentMusic =
                        ref.watch(currentMusicProvider.notifier);
                    final musics = ref.watch(musicProvider);

                    return Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              setPlayState.playPrevious();
                              setCurrentMusic.setCurrentMusic(musics
                                  .audioFiles[playerState.currentIndex - 1]);
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              playerState.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => setPlayState.togglePlay(),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.skip_next,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              setPlayState.playNext();
                              setCurrentMusic.setCurrentMusic(musics
                                  .audioFiles[playerState.currentIndex + 1]);
                            },
                          ),
                        ],
                      ),
                    );
                  })
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
