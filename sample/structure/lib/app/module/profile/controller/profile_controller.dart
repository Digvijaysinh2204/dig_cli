import 'dart:io';

import '../../../utils/import.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    // Pre-fill some dummy data for the example
    nameController.text = 'Digvijaysinh';
    emailController.text = 'digvijay@example.com';
    phoneController.text = '1234567890';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void onSave() {
    final loc = AppLocalizations.of(Get.context!)!;
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      showToast(
        message: '${loc.validationError}: ${loc.nameAndEmailRequired}',
        type: ToastType.error,
      );
      return;
    }
    showToast(message: loc.profileSavedSuccessfully, type: ToastType.success);
  }

  Future<void> pickImage(ImageSource source) async {
    final loc = AppLocalizations.of(Get.context!)!;
    try {
      final ImagePicker picker = ImagePicker();
      // image_picker natively requests permission on iOS and Android when accessing camera/gallery
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        await cropImage(image.path);
      }
    } catch (e) {
      showToast(
        message: loc.failedToPickImage(e.toString()),
        type: ToastType.error,
      );
    }
  }

  Future<void> cropImage(String path) async {
    final loc = AppLocalizations.of(Get.context!)!;
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: loc.cropImageTitle,
            toolbarColor: AppColor.kPrimary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: loc.cropImageTitle,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImage.value = File(croppedFile.path);
      }
    } catch (e) {
      showToast(
        message: loc.failedToCropImage(e.toString()),
        type: ToastType.error,
      );
    }
  }

  void showImagePickerOptions(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showAdaptiveActionSheet(
      context: context,
      title: loc.selectImageSource,
      actions: <AdaptiveAction>[
        AdaptiveAction(
          label: loc.camera,
          onPressed: () {
            pickImage(ImageSource.camera);
          },
        ),
        AdaptiveAction(
          label: loc.gallery,
          onPressed: () {
            pickImage(ImageSource.gallery);
          },
        ),
      ],
    );
  }
}
