import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/services/audio_service.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/glass_pill.dart';
import 'package:gokgok/features/buzzer/domain/entities/buzzer_sound.dart';
import 'package:gokgok/features/buzzer/presentation/providers/buzzer_provider.dart';
import 'package:gokgok/features/dashboard/presentation/widgets/top_header_widget_title_only.dart';

class SoundsPage extends ConsumerWidget {
  const SoundsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(buzzerSoundsProvider);
    final selectedId = ref.watch(selectedSoundProvider)?.id;

    return Column(
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top),
        TopHeaderWidgetTitleOnly(title: 'Sounds', padding: 24.w),
        Expanded(
          child: soundsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorRetry(
              onRetry: () => ref.invalidate(buzzerSoundsProvider),
            ),
            data: (sounds) {
              if (sounds.isEmpty) return const _Empty();
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(buzzerSoundsProvider),
                // Bottom inset clears the floating nav bar.
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 120.h),
                  itemCount: sounds.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    final s = sounds[i];
                    return _SoundCard(
                      sound: s,
                      selected: selectedId == s.id,
                      onPreview: () =>
                          ref.read(audioServiceProvider).playUrl(s.soundUrl),
                      onSelect: () =>
                          ref.read(selectedSoundProvider.notifier).select(s),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.selected,
    required this.onPreview,
    required this.onSelect,
  });

  final BuzzerSound sound;
  final bool selected;
  final VoidCallback onPreview;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;
    final secondary = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    final category = sound.category?.trim() ?? '';

    return GlassPill(
      onTap: onSelect,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.s,
        ),
        child: Row(
          children: [
            // Preview: its own tap target so it doesn't trigger selection.
            GestureDetector(
              onTap: onPreview,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: highlight.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: highlight,
                  size: AppSizes.iconSizeMedium,
                ),
              ),
            ),
            AppSizes.sm.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (category.isNotEmpty) ...[
                    2.verticalSpace,
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: secondary),
                    ),
                  ],
                ],
              ),
            ),
            AppSizes.s.horizontalSpace,
            // Selection: icon + color (never color alone).
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? highlight : Colors.black.withAlpha(60),
              size: AppSizes.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq_rounded, size: 44.w, color: secondary),
          8.verticalSpace,
          Text(
            'No buzzer sounds yet',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          4.verticalSpace,
          Text(
            'Sounds added in the admin panel show up here.',
            style: TextStyle(fontSize: 13.sp, color: secondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load sounds",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          8.verticalSpace,
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
