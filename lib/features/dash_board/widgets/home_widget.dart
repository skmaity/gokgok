import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/dash_board/providers/buzzer_provider.dart';
import 'package:gokgok/features/dash_board/widgets/log_out_bottom_drawer.dart';
import 'package:gokgok/features/dash_board/widgets/online_now_list.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
          child: Column(
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GokGok',
                    style: GoogleFonts.lobster(
                      fontSize: AppSizes.logoMedium,
                      color: Theme.of(context).extension<AppColors>()!.logoColor,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isDismissible: false,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: LogOutBottomDrawer(context: context),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusCircular,
                      ),
                      child: SizedBox(
                        height: AppSizes.avatarSize,
                        width: AppSizes.avatarSize,
                        child: Center(
                          child: Image(
                            image: AssetImage(AppAssets.profilePlaceholder),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.m.verticalSpace,
              // body (Search bar)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<AppColors>()!.searchBarBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    AppSizes.m.horizontalSpace,
                    Icon(Icons.search_rounded),
                    AppSizes.s.horizontalSpace,

                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "find squads or people...",
                          border: InputBorder.none,
                        ),
                        controller: searchController,
                      ),
                    ),
                    AppSizes.m.horizontalSpace,
                  ],
                ),
              ),
              AppSizes.m.verticalSpace,

              // Online Now section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Online now",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSizes.s.verticalSpace,
                  OnlineNowList(),
                  AppSizes.s.verticalSpace,

                  Consumer(
                    builder: (context, ref, child) {
                      final buzzer = ref.watch(buzzerProvider);
                      return Text(
                        buzzer,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
