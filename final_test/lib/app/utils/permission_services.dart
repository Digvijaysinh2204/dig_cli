import 'dart:io';
import 'import.dart';

class PermissionService {
  PermissionService._privateConstructor();
  static final PermissionService instance =
      PermissionService._privateConstructor();

  /// Requests permission for the camera.
  Future<bool> requestCameraPermission() async {
    if (Platform.isIOS) {
      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited) {
        return true;
      } else if (result.isPermanentlyDenied) {
        await _showOpenSettingsDialog(
          AppLocalizations.of(Get.context!)!.camera,
        );
        return false;
      }
      return false;
    } else if (Platform.isAndroid) {
      return true;
    } else {
      return false;
    }
  }

  /// Requests permission for the photo gallery.
  Future<bool> requestGalleryPermission() async {
    if (Platform.isIOS) {
      final result = await Permission.photos.request();
      if (result.isGranted || result.isLimited) {
        return true;
      } else if (result.isPermanentlyDenied) {
        await _showOpenSettingsDialog(
          AppLocalizations.of(Get.context!)!.photos,
        );
        return false;
      }
      return false;
    } else if (Platform.isAndroid) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _showOpenSettingsDialog(String permissionName) async {
    final context = Get.context!;
    final loc = AppLocalizations.of(context)!;

    await Get.dialog<void>(
      ConfirmationDialog(
        title: loc.permissionRequiredTitle(permissionName),
        message: loc.permissionRequiredMessage(permissionName),
        cancelButtonText: loc.cancel,
        confirmButtonText: loc.openSettings,
        onCancel: () => Get.back(),
        onConfirm: () async {
          await openAppSettings();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}
