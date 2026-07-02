import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gokgok/features/groups/presentation/widgets/empty_state_no_friends_groups.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
import 'package:gokgok/features/groups/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:gokgok/features/groups/presentation/widgets/join_group_bottom_sheet.dart';
import 'package:gokgok/features/groups/presentation/widgets/your_groups_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;
    final cardBg = Theme.of(context).extension<AppColors>()!.searchBarBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.s,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(4, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: highlight.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                icon,
                color: highlight,
                size: AppSizes.iconSizeMedium,
              ),
            ),
            AppSizes.sm.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
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

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  // var group =  ref.watch(groupProvider.notifier).
  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    final profile = ref.watch(dashboardProvider).value;
    final avatarUrl = profile?.avatarUrl;

    final firstName = (profile?.fullName ?? '').trim().split(' ').first;

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
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.profile);
                    },
                    child: Row(
                      children: [
                        AppNetworkImage(
                          url: avatarUrl,
                          size: AppSizes.avatarSize,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCircular,
                          ),
                        ),
                        if (profile?.fullName != null &&
                            profile!.fullName!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: AppSizes.sm),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                firstName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'GokGok',
                    style: GoogleFonts.lobster(
                      fontSize: AppSizes.logoMedium,
                      color: Colors.amber,
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

              ref
                  .watch(groupProvider)
                  .when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (groups) => groups.isEmpty
                        ? EmptyStateNoFriendsGroups()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionCard(
                                      icon: Icons.add_rounded,
                                      title: 'new group',
                                      subtitle: 'start a squad',
                                      onTap: () =>
                                          showCreateGroupSheet(context),
                                    ),
                                  ),
                                  AppSizes.s.horizontalSpace,
                                  Expanded(
                                    child: _ActionCard(
                                      icon: Icons.tag_rounded,
                                      title: 'join with code',
                                      subtitle: 'got an invite?',
                                      onTap: () => showJoinGroupSheet(context),
                                    ),
                                  ),
                                ],
                              ),
                              AppSizes.m.verticalSpace,
                              YourGroupsWidget(),
                            ],
                          ),
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
