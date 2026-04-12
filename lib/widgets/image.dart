import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width = 54,
    this.height = 54,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder ?? const SizedBox();
    }
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder ?? const SizedBox(),
    );
  }
}
