import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/dash_board/providers/group_provider.dart';
import 'package:gokgok/features/dash_board/widgets/empty_state_no_friends_groups.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  // var group =  ref.watch(groupProvider.notifier).
  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
          child: Column(
            children: [
              MediaQuery.of(context).viewPadding.top.verticalSpace,
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GokGok',
                    style: GoogleFonts.lobster(
                      fontSize: AppSizes.logoMedium,
                      color: Colors.amber,
                    ),
                  ),

                  GestureDetector(
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(4, 3),
                    ),
                  ],
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

              // Empty state
              ref.watch(groupProvider).when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (groups) =>
                    groups.isEmpty ? EmptyStateNoFriendsGroups() : const SizedBox.shrink(),
              ),

              // Or embed inside your existing Scaffold body
              // Online Now section
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "Online now",
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontSize: 14.sp,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     AppSizes.s.verticalSpace,
              //     OnlineNowList(),
              //     AppSizes.s.verticalSpace,

              //     Consumer(
              //       builder: (context, ref, child) {
              //         final buzzer = ref.watch(buzzerProvider);
              //         return Text(
              //           buzzer,
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: 14.sp,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         );
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
