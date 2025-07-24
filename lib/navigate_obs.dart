import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPagePop;

  MyNavigatorObserver({required this.onPagePop});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    onPagePop();
  }
}
