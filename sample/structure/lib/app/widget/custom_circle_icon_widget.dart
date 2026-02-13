import '../utils/import.dart';

class CustomCircleIconWidget extends StatelessWidget {
  const CustomCircleIconWidget({
    super.key,
    this.clickName,
    required this.onTap,
    required this.color,
    required this.child,
  });
  final String? clickName;
  final VoidCallback onTap;
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      clickName: clickName ?? 'CustomCircleIconWidget',
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: child,
      ),
    );
  }
}
