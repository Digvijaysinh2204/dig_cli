import '../utils/import.dart';

class BackgroundWrapper extends StatelessWidget {
  final String imagePath;

  const BackgroundWrapper({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return imagePath.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(imagePath, fit: BoxFit.cover, width: Get.width)
        : Image.asset(imagePath, fit: BoxFit.cover, width: Get.width);
  }
}
