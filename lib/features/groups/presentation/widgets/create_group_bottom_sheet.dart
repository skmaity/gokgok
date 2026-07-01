import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/widgets/submit_button.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';

void showCreateGroupSheet(BuildContext context) {
  showModalBottomSheet(
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusMedium),
      ),
    ),
    builder: (_) => const _CreateGroupBottomSheet(),
  );
}

class _CreateGroupBottomSheet extends ConsumerStatefulWidget {
  const _CreateGroupBottomSheet();

  @override
  ConsumerState<_CreateGroupBottomSheet> createState() =>
      _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState
    extends ConsumerState<_CreateGroupBottomSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a group name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(groupProvider.notifier).createGroup(name);
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
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            AppSizes.m,
        // + AppSizes.xl,
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
            'Create a Group',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
          AppSizes.xs.verticalSpace,
          Text(
            'Give your squad a name to get started.',
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
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Weekend Crew',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.m,
                  vertical: AppSizes.m,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.group_rounded, color: highlight),
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
            label: 'Create Group',
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
