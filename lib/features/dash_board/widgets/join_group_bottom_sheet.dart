import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/common/widgets/submit_button.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/dash_board/providers/group_provider.dart';

void showJoinGroupSheet(BuildContext context) {
  showModalBottomSheet(
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusMedium),
      ),
    ),
    builder: (_) => const _JoinGroupBottomSheet(),
  );
}

class _JoinGroupBottomSheet extends ConsumerStatefulWidget {
  const _JoinGroupBottomSheet();

  @override
  ConsumerState<_JoinGroupBottomSheet> createState() =>
      _JoinGroupBottomSheetState();
}

class _JoinGroupBottomSheetState extends ConsumerState<_JoinGroupBottomSheet> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter an invite code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(groupProvider.notifier).joinGroup(code);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.screenPadding,
        right: AppSizes.screenPadding,
        top: AppSizes.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          AppSizes.l.verticalSpace,
          Text(
            'Join a Group',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
          AppSizes.xs.verticalSpace,
          Text(
            'Enter the invite code shared by your friend.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          AppSizes.l.verticalSpace,
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppColors>()!.searchBarBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: _error != null
                    ? Colors.red.shade300
                    : Colors.grey.shade200,
              ),
            ),
            child: TextField(
              controller: _codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g. ABC123',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.m,
                  vertical: AppSizes.m,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.tag_rounded, color: highlight),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          if (_error != null) ...[
            AppSizes.xs.verticalSpace,
            Text(
              _error!,
              style: TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
            ),
          ],
          AppSizes.l.verticalSpace,
          CommounSubmitBtn(
            label: 'Join Group',
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
