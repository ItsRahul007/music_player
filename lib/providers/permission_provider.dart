import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  final bool isLoading;
  final bool havePermission;

  PermissionState({
    required this.isLoading,
    required this.havePermission,
  });

  PermissionState copyWith({
    bool? isLoading,
    bool? havePermission,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      havePermission: havePermission ?? this.havePermission,
    );
  }
}

class PermissionProvider extends StateNotifier<PermissionState> {
  PermissionProvider()
      : super(PermissionState(
          isLoading: false,
          havePermission: false,
        ));

  Future<bool> requestAudioPermissions() async {
    state = state.copyWith(isLoading: true);

    final isPermissionAlreadyGranted = await checkAudioPermissions();
    if (isPermissionAlreadyGranted) {
      state = state.copyWith(havePermission: true, isLoading: false);
      return true;
    } else {
      final status = await Permission.audio.request();
      if (status.isGranted) {
        state = state.copyWith(havePermission: true, isLoading: false);
        return true;
      }
    }

    state = state.copyWith(isLoading: false, havePermission: false);
    return false;
  }

  Future<void> manualRequestPermission() async {
    state = state.copyWith(isLoading: true);

    PermissionStatus status = await Permission.audio.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      await Future.delayed(Duration(milliseconds: 500));
      status = await Permission.audio.status;
      if (status.isGranted) {
        state = state.copyWith(havePermission: true);
      }
    } else {
      status = await Permission.audio.request();
      if (status.isGranted) {
        state = state.copyWith(havePermission: true);
      } else {
        state = state.copyWith(havePermission: false);
      }
    }

    state = state.copyWith(isLoading: false);
  }

  Future<bool> checkAudioPermissions() async {
    bool permission = await Permission.audio.isGranted;
    state = state.copyWith(havePermission: permission);
    return permission;
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final isPermissionAlreadyGranted = await checkAudioPermissions();
    state = state.copyWith(
        havePermission: isPermissionAlreadyGranted, isLoading: false);
  }
}

// Update the provider definition
final permissionProvider =
    StateNotifierProvider<PermissionProvider, PermissionState>((ref) {
  final controller = PermissionProvider();
  controller.init();
  return controller;
});
