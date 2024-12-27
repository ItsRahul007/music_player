import 'package:permission_handler/permission_handler.dart';

// Request audio permissions
Future requestAudioPermissions(
    Future<void>? Function() scanForAudioFiles) async {
  final isPermissionAlreadyGranted = await checkAudioPermissions();
  if (isPermissionAlreadyGranted) {
    await scanForAudioFiles();
  } else {
    if (await Permission.audio.request().isGranted) {
      scanForAudioFiles();
    }
  }
}

// Check if permissions are granted
Future<bool> checkAudioPermissions() async {
  bool permission = await Permission.audio.isGranted;
  return permission;
}
