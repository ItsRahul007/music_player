import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/constants/common.dart';
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
    super.initState();
    Future(() async {
      await ref.read(permissionProvider.notifier).requestAudioPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);

    if (permissionState.isLoading) return const Loading();

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
                  value: permissionState.dropdownValue,
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
                      ref
                          .read(permissionProvider.notifier)
                          .changeAudioFilesArrayOrder(value);
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
        body: !permissionState.havePermission
            ? Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Permission is required to access audio files.',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(permissionProvider.notifier)
                          .manualRequestPermission();
                    },
                    child: const Text("Request Permission"),
                  )
                ],
              ))
            : ListView.builder(
                itemBuilder: (context, index) => SingleMusicWidget(
                  file: permissionState.audioFiles[index],
                  index: index,
                ),
                itemCount: permissionState.audioFiles.length,
              ));
  }
}
