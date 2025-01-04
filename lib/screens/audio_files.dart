import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/constants/common.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/permission_provider.dart';
import 'package:music_player/screens/loading.dart';
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

    debugPrint("havePermission: ${permission.havePermission}");

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
        body: !permission.havePermission
            ? Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Permission is required to access audio files.',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () async {
                        if (music.audioFiles.isEmpty &&
                            permission.havePermission) {
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
              ))
            : music.audioFiles.isNotEmpty
                ? ListView.builder(
                    itemBuilder: (context, index) => SingleMusicWidget(
                      file: music.audioFiles[index],
                      index: index,
                    ),
                    itemCount: music.audioFiles.length,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Didn't got any music files",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        ElevatedButton(
                            onPressed: () {
                              if (music.audioFiles.isEmpty &&
                                  permission.havePermission) {
                                changeMusic.scanForAudioFiles();
                              }
                            },
                            child: const Text("Scan for audio"))
                      ],
                    ),
                  ));
  }
}
