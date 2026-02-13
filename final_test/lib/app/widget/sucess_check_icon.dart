import '../utils/import.dart';

class SuccessCheckIcon extends StatefulWidget {
  const SuccessCheckIcon({super.key});

  @override
  State<SuccessCheckIcon> createState() => _SuccessCheckIconState();
}

class _SuccessCheckIconState extends State<SuccessCheckIcon> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _show ? 1 : 0.6,
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: _show ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 72,
          width: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF34C759),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
