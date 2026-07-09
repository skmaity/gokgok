import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;
  const DateSeparator({super.key, required this.date});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    final label = diff == 0
        ? 'Today'
        : diff == 1
        ? 'Yesterday'
        : '${date.day} ${_months[date.month - 1]}'
              '${date.year == now.year ? '' : ' ${date.year}'}';

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.s),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
        ),
      ),
    );
  }
}
