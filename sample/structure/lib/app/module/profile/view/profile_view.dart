import '../../../utils/import.dart';
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return CustomScaffold(
      isAppBar: true,
      title: CustomTextView(
        text: loc.profile,
        style: AppTextStyle.appBarTitle(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(context),
            const Gap(32),
            CustomTextField(
              controller: controller.nameController,
              hintText: loc.fullName,
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColor.kPrimary,
              ),
            ),
            const Gap(16),
            CustomTextField(
              controller: controller.emailController,
              hintText: loc.emailAddress,
              textInputType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColor.kPrimary,
              ),
            ),
            const Gap(16),
            CustomTextField(
              controller: controller.phoneController,
              hintText: loc.phoneNumber,
              textInputType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColor.kPrimary,
              ),
            ),
            const Gap(48),
            CustomButton(
              clickName: 'Save Profile',
              onTap: controller.onSave,
              text: loc.saveProfile,
              bgColor: AppColor.kPrimary,
              height: 50,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.showImagePickerOptions(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Obx(() {
            final image = controller.selectedImage.value;
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColor.kEEF0F5,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.kPrimary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: image != null
                    ? Image.file(image, fit: BoxFit.cover)
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColor.k9FA4AF,
                      ),
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColor.kPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: AppColor.kWhite,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
