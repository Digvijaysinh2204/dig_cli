import '../utils/import.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final loader = Get.find<AppLoadingService>();

    return StreamBuilder<bool>(
      stream: loader.stream,
      initialData: false,
      builder: (context, snapshot) {
        final isLoading = snapshot.data ?? false;

        if (!isLoading) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(child: Loader(size: 30)),
            ),
          ),
        );
      },
    );
  }
}
