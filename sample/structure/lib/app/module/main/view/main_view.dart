import '../../../utils/import.dart';
import '../controller/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isAppBar: true,
      title: CustomTextView(
        text: 'Dashboard',
        style: AppTextStyle.appBarTitle(),
      ),
      backgroundColor: AppColor.kEEEAEC,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextView(
              text: 'System Status',
              style: AppTextStyle.bold(size: 18),
            ),
            const Gap(16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _statusRow(
                    icon: Icons.cloud_done_rounded,
                    label: 'Firebase',
                    value: controller.firebaseStatus,
                    color: AppColor.k9A80AF,
                  ),
                  const Divider(height: 32),
                  _statusRow(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Device',
                    value:
                        (controller.deviceInfo.deviceData['model'] ?? 'Unknown')
                            .toString()
                            .obs,
                    color: AppColor.k9A80AF,
                  ),
                  const Divider(height: 32),
                  _statusRow(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
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
              text: 'Project Information',
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
                        'Bundle ID: ${controller.deviceInfo.packageInfo?.packageName ?? 'N/A'}',
                    style: AppTextStyle.regular(
                      size: 12,
                      color: AppColor.k161A25.withValues(alpha: 0.6),
                    ),
                  ),
                ],
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
