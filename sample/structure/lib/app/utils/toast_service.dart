import 'dart:ui';

import 'import.dart';

void showToast({String message = '', ToastType type = ToastType.warning}) {
  if (message.trim().isEmpty) return;

  toastification.showCustom(
    alignment: Alignment.topCenter,

    autoCloseDuration: Duration(seconds: _getDuration(type)),
    animationDuration: const Duration(milliseconds: 250),
    animationBuilder: (context, animation, alignment, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    builder: (context, holder) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _glassColor(type),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(_toastIcon(type), color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => toastification.dismissById(holder.id),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Color _glassColor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Colors.green.withValues(alpha: 0.8);
    case ToastType.error:
      return Colors.red.withValues(alpha: 0.8);
    case ToastType.warning:
      return Colors.orange.withValues(alpha: 0.8);
    case ToastType.info:
      return Colors.blue.withValues(alpha: 0.8);
  }
}

IconData _toastIcon(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Icons.check_circle;
    case ToastType.error:
      return Icons.error_rounded;
    case ToastType.warning:
      return Icons.warning_amber_rounded;
    case ToastType.info:
      return Icons.info_outline;
  }
}

int _getDuration(ToastType type) {
  switch (type) {
    case ToastType.success:
      return 5;
    case ToastType.error:
      return 7;
    case ToastType.warning:
      return 7;
    case ToastType.info:
      return 6;
  }
}

enum ToastType { success, error, warning, info }
