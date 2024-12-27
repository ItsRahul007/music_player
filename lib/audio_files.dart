import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/fetch_audio_functions.dart';
import 'package:music_player/functions.dart';
import 'package:music_player/player.dart';

class AudioFileScanner extends StatefulWidget {
  const AudioFileScanner({super.key});

  @override
  State<AudioFileScanner> createState() => _AudioFileScannerState();
}

class _AudioFileScannerState extends State<AudioFileScanner> {
  List<AudioFile> audioFiles = [];
  bool isLoading = false;
  String error = '';
  final List<String> orderByOptions = [
    'Name',
    'Size',
    'Latest first',
    'Oldest first'
  ];
  String dropdownValue = "";

  @override
  void initState() {
    super.initState();
    dropdownValue = orderByOptions.first;
    requestAudioPermissions(scanForAudioFiles);
  }

  Future<void> scanForAudioFiles() async {
    setState(() => isLoading = true);
    try {
      Directory rootDir = Directory('/storage/emulated/0');
      List<FileSystemEntity> files = await scanDirectory(rootDir);
      audioFiles = await Future.wait(
          files.map((file) => processAudioFile(file as File)));
      changeAudioFilesArrayOrder(dropdownValue);
    } catch (e) {
      error = 'Error scanning files: $e';
    }
    setState(() => isLoading = false);
  }

  //! changing the array order
  changeAudioFilesArrayOrder(String type) {
    if (type.toLowerCase() == "size") {
      audioFiles.sort((a, b) => b.size.compareTo(a.size));
    } else if (type.toLowerCase() == "name") {
      audioFiles.sort((a, b) => a.name.compareTo(b.name));
    } else if (type.toLowerCase() == "latest first") {
      audioFiles.sort((a, b) => b.modified.compareTo(a.modified));
    } else if (type.toLowerCase() == "oldest first") {
      audioFiles.sort((a, b) => a.modified.compareTo(b.modified));
    }
  }

  onOrderTypeChange(String value) {
    setState(() {
      dropdownValue = value;
      changeAudioFilesArrayOrder(value);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                value: dropdownValue,
                items: orderByOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) => onOrderTypeChange(value!),
                elevation: 16,
                style: TextStyle(color: Colors.white),
              ),
            ],
          )
        ],
        backgroundColor: Colors.grey.shade900,
        elevation: 10,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : SingleChildScrollView(
                  child: Column(
                    children: audioFiles
                        .map((file) => SingleMusicWidget(
                              file: file,
                              index: audioFiles.indexOf(file),
                            ))
                        .toList(),
                  ),
                ),
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        isThreeLine: true,
        onTap: () => playLocalAudio(file.path),
        leading: file.base64Str != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  base64Decode(file.base64Str!),
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color.fromARGB(255, 75, 53, 74),
                            width: 1,
                          )),
                      child: Center(
                          child: Icon(
                        Icons.audiotrack,
                        color: Colors.purpleAccent,
                      ))),
                ),
              )
            : Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color.fromARGB(255, 75, 53, 74),
                      width: 1,
                    )),
                child: Center(
                    child: Icon(
                  Icons.audiotrack,
                  color: Colors.purpleAccent,
                ))),
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
      ),
    );
  }
}
