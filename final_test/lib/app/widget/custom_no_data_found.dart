import '../utils/import.dart';

class CustomNoDataFound extends StatelessWidget {
  const CustomNoDataFound({super.key, this.noDataFound});

  final String? noDataFound;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: CustomTextView(
        text: loc.noDataFound,
        capitalizeFirst: true,
        style: AppTextStyle.bold(
          size: 16,
          color: AppColor.k030303,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
