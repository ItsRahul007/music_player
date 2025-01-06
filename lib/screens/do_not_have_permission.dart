import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/permission_provider.dart';

class DoNotHavePermission extends ConsumerWidget {
  const DoNotHavePermission({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(musicProvider);
    final changeMusic = ref.read(musicProvider.notifier);
    final permission = ref.watch(permissionProvider);

    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Permission is required to access audio files.',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 10),
        ElevatedButton(
            onPressed: () async {
              if (music.audioFiles.isEmpty && permission.havePermission) {
                changeMusic.scanForAudioFiles();
              } else {
                await ref
                    .read(permissionProvider.notifier)
                    .manualRequestPermission();
              }
            },
            child: permission.havePermission
                ? const Text("Scan for audio")
                : const Text("Give Permission"))
      ],
    ));
  }
}
