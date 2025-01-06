import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/permission_provider.dart';

class EmptyMusics extends ConsumerWidget {
  const EmptyMusics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(musicProvider);
    final changeMusic = ref.read(musicProvider.notifier);
    final permission = ref.watch(permissionProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Didn't got any music files",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          ElevatedButton(
              onPressed: () {
                if (music.audioFiles.isEmpty && permission.havePermission) {
                  changeMusic.scanForAudioFiles();
                }
              },
              child: const Text("Scan for audio"))
        ],
      ),
    );
  }
}
