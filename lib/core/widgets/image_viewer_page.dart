import 'package:flutter/material.dart';

import 'package:gokgok/core/widgets/app_network_image.dart';

/// Opens [url] full-screen on black with pinch-zoom (InteractiveViewer).
/// Dismiss via the close button or system back.
void showImageViewer(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, _, _) => _ImageViewerPage(url: url),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _ImageViewerPage extends StatelessWidget {
  final String url;
  const _ImageViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 4,
              child: Hero(
                tag: url,
                child: AppNetworkImage(url: url, fit: BoxFit.contain),
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
