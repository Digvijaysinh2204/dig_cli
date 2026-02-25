import '../../../utils/import.dart';
import '../controller/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return CustomScaffold(
      isAppBar: true,
      title: CustomTextView(
        text: loc.dashboard,
        style: AppTextStyle.appBarTitle(),
      ),
      backgroundColor: AppColor.kEEEAEC,
      floatingActionButton: FloatingActionButton(
        onPressed: controller.incrementCounter,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextView(
              text: loc.systemStatus,
              style: AppTextStyle.bold(size: 18),
            ),
            const Gap(16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _statusRow(
                    icon: Icons.cloud_done_rounded,
                    label: loc.firebase,
                    value: controller.firebaseStatus,
                    color: AppColor.k9A80AF,
                  ),
                  const Divider(height: 32),
                  _statusRow(
                    icon: Icons.phone_iphone_rounded,
                    label: loc.device,
                    value:
                        (controller.deviceInfo.deviceData['model'] ?? 'Unknown')
                            .toString()
                            .obs,
                    color: AppColor.k9A80AF,
                  ),
                  const Divider(height: 32),
                  _statusRow(
                    icon: Icons.info_outline_rounded,
                    label: loc.appVersion,
                    value:
                        (controller.deviceInfo.packageInfo?.version ?? '1.0.0')
                            .toString()
                            .obs,
                    color: AppColor.k9A80AF,
                  ),
                ],
              ),
            ),
            const Gap(24),
            CustomTextView(
              text: loc.projectInformation,
              style: AppTextStyle.bold(size: 18),
            ),
            const Gap(16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextView(
                    text: 'This is a DIG CLI generated project template.',
                    style: AppTextStyle.regular(
                      size: 14,
                      color: AppColor.k161A25,
                    ),
                  ),
                  const Gap(8),
                  CustomTextView(
                    text:
                        '${loc.bundleId}: ${controller.deviceInfo.packageInfo?.packageName ?? 'N/A'}',
                    style: AppTextStyle.regular(
                      size: 12,
                      color: AppColor.k161A25.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            CustomCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  CustomTextView(
                    text: loc.pushedButtonManyTimes,
                    style: AppTextStyle.regular(size: 14),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Obx(
                    () => CustomTextView(
                      text: '${controller.counter.value}',
                      style: AppTextStyle.bold(
                        size: 32,
                        color: AppColor.kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoute.profileView),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CustomTextView(
                  text: loc.profile,
                  style: AppTextStyle.bold(size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String label,
    required RxString value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextView(
                text: label,
                style: AppTextStyle.regular(
                  size: 12,
                  color: AppColor.k161A25.withValues(alpha: 0.6),
                ),
              ),
              Obx(
                () => CustomTextView(
                  text: value.value,
                  style: AppTextStyle.semiBold(
                    size: 15,
                    color: AppColor.k161A25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
