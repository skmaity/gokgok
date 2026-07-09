import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/widgets/app_bottom_padding.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color highlight;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomPadding(
      handelKeyboardHeight: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(AppSizes.m, 0, AppSizes.m, 0),

        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).extension<AppColors>()!.searchBarBg,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.m,
                          vertical: AppSizes.sm,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
              ),
            ),
            AppSizes.s.horizontalSpace,
            GestureDetector(
              onTap: onSend,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).extension<AppColors>()!.searchBarBg.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: AppSizes.iconSizeMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
