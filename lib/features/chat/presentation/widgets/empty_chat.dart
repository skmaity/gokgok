import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class EmptyChat extends StatelessWidget {
  final String groupName;
  const EmptyChat({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waving_hand_rounded, size: 48.w, color: Colors.amber),
          AppSizes.s.verticalSpace,
          Text(
            'Say hi to $groupName!',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
