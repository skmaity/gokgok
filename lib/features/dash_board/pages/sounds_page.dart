import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/features/dash_board/widgets/top_header_widget_title_only.dart';

class SoundsPage extends StatelessWidget {
  const SoundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MediaQuery.of(context).viewPadding.top.verticalSpace,

        TopHeaderWidgetTitleOnly(title: 'Sounds', padding: 24.w),
      ],
    );
  }
}
