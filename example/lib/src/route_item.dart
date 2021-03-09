import 'package:flutter/material.dart';

typedef RouteCallback = void Function(BuildContext context);

class RouteItem {
  RouteItem({
    required this.title,
    this.subtitle,
    this.push,
  });

  final String title;
  final String? subtitle;
  final RouteCallback? push;
}
