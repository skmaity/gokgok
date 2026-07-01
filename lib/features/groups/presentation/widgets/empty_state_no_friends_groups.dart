import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gokgok/core/widgets/submit_button.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:gokgok/features/groups/presentation/widgets/join_group_bottom_sheet.dart';

class EmptyStateNoFriendsGroups extends ConsumerStatefulWidget {
  const EmptyStateNoFriendsGroups({super.key});

  @override
  ConsumerState<EmptyStateNoFriendsGroups> createState() =>
      _EmptyStateNoFriendsGroupsState();
}

class _EmptyStateNoFriendsGroupsState
    extends ConsumerState<EmptyStateNoFriendsGroups> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        65.verticalSpace,
        SvgPicture.asset(AppAssets.emptyStateLogo, height: 200.h),
        Text("No groups yet? No worries.", style: TextStyle(fontSize: 24.sp)),
        AppSizes.s.verticalSpace,
        Text(
          "Jump into a group, vibe with people, and let the buzz begin. 🎉",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        AppSizes.l.verticalSpace,
        CommounSubmitBtn(
          label: 'Join Group',
          onPressed: () => showJoinGroupSheet(context),
        ),
        4.verticalSpace,
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),

                onTap: () => showCreateGroupSheet(context),
                child: Container(
                  height: 48.h,

                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Center(
                    child: Text(
                      "Create gorup",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).extension<AppColors>()!.highlight,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
