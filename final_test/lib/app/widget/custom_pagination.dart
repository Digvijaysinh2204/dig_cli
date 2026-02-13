import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/import.dart';

class CustomPagination extends StatelessWidget {
  final RefreshController controller;
  final VoidCallback? onLoading;
  final VoidCallback? onRefresh;
  final Widget child;

  const CustomPagination({
    super.key,
    required this.controller,
    required this.onLoading,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      onLoading: onLoading,
      onRefresh: onRefresh,
      enablePullDown: true,
      physics: RefreshPhysics(
        controller: controller,
        springDescription: const SpringDescription(
          mass: 2.2,
          stiffness: 150,
          damping: 16,
        ),
      ),
      enablePullUp: true,
      header: CustomHeader(builder: (context, mode) => const SizedBox.shrink()),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          body = const SizedBox.shrink();

          return SizedBox(height: 55, child: Center(child: body));
        },
      ),
      child: child,
    );
  }
}
