import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:image_picker/image_picker.dart';

/// Picks an image from [source], then lets the user adjust it WhatsApp-style
/// (pinch-zoom, re-center, pick another from gallery) behind a circular mask.
/// Returns the cropped avatar as 500x500 JPG bytes, or null when cancelled.
Future<Uint8List?> pickAndCropAvatar(
  BuildContext context, {
  required ImageSource source,
}) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    imageQuality: 85,
  );
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  if (!context.mounted) return null;

  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _CropAvatarPage(initialBytes: bytes),
    ),
  );
}

/// Camera / Gallery / Remove sheet shared by profile and group avatars.
/// Each callback runs after the sheet closes itself.
void showAvatarOptionsSheet(
  BuildContext context, {
  required String title,
  required VoidCallback onCamera,
  required VoidCallback onGallery,
  required VoidCallback onRemove,
}) {
  final highlight = Theme.of(context).extension<AppColors>()!.highlight;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      void closeThen(VoidCallback action) {
        Navigator.pop(sheetContext);
        action();
      }

      return Container(
        margin: EdgeInsets.all(AppSizes.m),
        padding: EdgeInsets.all(AppSizes.m),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSizes.m.verticalSpace,
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            AppSizes.m.verticalSpace,
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              highlight: highlight,
              onTap: () => closeThen(onCamera),
            ),
            AppSizes.s.verticalSpace,
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              highlight: highlight,
              onTap: () => closeThen(onGallery),
            ),
            AppSizes.s.verticalSpace,
            _SheetOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Photo',
              highlight: Colors.red,
              onTap: () => closeThen(onRemove),
            ),
            AppSizes.m.verticalSpace,
          ],
        ),
      );
    },
  );
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color highlight;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 14.h),
        decoration: BoxDecoration(
          color: highlight.withAlpha(15),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          children: [
            Icon(icon, color: highlight, size: 22.w),
            AppSizes.m.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: highlight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-level so [compute] can run it in an isolate.
Uint8List _resizeAndEncodeJpg(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes; // shouldn't happen; upload as-is
  final resized = img.copyResize(decoded, width: 500, height: 500);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

class _CropAvatarPage extends StatefulWidget {
  final Uint8List initialBytes;
  const _CropAvatarPage({required this.initialBytes});

  @override
  State<_CropAvatarPage> createState() => _CropAvatarPageState();
}

class _CropAvatarPageState extends State<_CropAvatarPage> {
  final _controller = CropController();
  late Uint8List _bytes = widget.initialBytes;
  bool _isCropping = false;

  Future<void> _pickAnother() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (mounted) setState(() => _bytes = bytes);
  }

  void _done() {
    setState(() => _isCropping = true);
    _controller.crop(); // square output; circle mask is display-only
  }

  Future<void> _onCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        // Off the UI thread: decode -> 500x500 -> JPG.
        final jpg = await compute(_resizeAndEncodeJpg, croppedImage);
        if (mounted) Navigator.of(context).pop(jpg);
      case CropFailure(:final cause):
        setState(() => _isCropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not crop image: $cause'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                // New key forces a rebuild when another image is picked.
                key: ValueKey(identityHashCode(_bytes)),
                image: _bytes,
                controller: _controller,
                onCropped: _onCropped,
                aspectRatio: 1,
                withCircleUi: true,
                interactive: true,
                fixCropRect: true,
                cornerDotBuilder: (_, _) => const SizedBox.shrink(),
                baseColor: Colors.black,
                maskColor: Colors.black.withAlpha(160),
                progressIndicator: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.m,
                vertical: AppSizes.s,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isCropping
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _isCropping ? null : _pickAnother,
                    child: const Text(
                      'Choose another',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _isCropping ? null : _done,
                    child: _isCropping
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
