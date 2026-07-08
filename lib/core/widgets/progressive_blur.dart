// import 'package:flutter/material.dart';
// import 'package:soft_edge_blur/soft_edge_blur.dart';

// /// iOS-style progressive blur on the top [height] pixels of [child]:
// /// strongest at the very top, dissolving to nothing at the bottom of the
// /// region — a single shader pass, so no visible seams.
// ///
// /// Wrap the *content that scrolls under the header* (not the header itself),
// /// e.g. the message list on a page using `GlassHeaderBar`.
// class ProgressiveBlur extends StatelessWidget {
//   final Widget child;

//   /// Height in logical px of the blurred region from the top
//   /// (typically header height + status bar).
//   final double height;

//   /// Blur strength at the very top.
//   final double sigma;

//   const ProgressiveBlur({
//     super.key,
//     required this.child,
//     required this.height,
//     this.sigma = 25,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SoftEdgeBlur(
//       edges: [
//         EdgeBlur(
//           type: EdgeType.topEdge,
//           size: height,
//           sigma: sigma,
//           controlPoints: [
//             ControlPoint(position: 0, type: ControlPointType.visible),
//             ControlPoint(position: 1, type: ControlPointType.transparent),
//           ],
//         ),
//       ],
//       child: child,
//     );
//   }
// }
