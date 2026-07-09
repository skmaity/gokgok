import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color highlight;
  final MemberModel? sender;

  /// Show sender name + avatar (first message of a sender's run).
  final bool showSender;

  /// The message this one replies to, if loaded.
  final MessageModel? replied;
  final String? repliedSender;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.highlight,
    this.sender,
    this.showSender = false,
    this.replied,
    this.repliedSender,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final local = message.createdAt.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    final bubble = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: isMe ? highlight : Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusMedium),
          topRight: Radius.circular(AppSizes.radiusMedium),
          bottomLeft: Radius.circular(isMe ? AppSizes.radiusMedium : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : AppSizes.radiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showSender) ...[
            Text(
              sender?.username ?? 'Unknown',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: highlight,
              ),
            ),
            2.verticalSpace,
          ],
          if (message.hasReply) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: (isMe ? Colors.white : highlight).withAlpha(30),
                // No borderRadius: BoxDecoration forbids it with a
                // non-uniform border.
                border: Border(
                  left: BorderSide(
                    color: isMe ? Colors.white : highlight,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repliedSender ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white : highlight,
                    ),
                  ),
                  Text(
                    replied?.body ?? 'Message unavailable',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            4.verticalSpace,
          ],
          Text(
            message.body ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: isMe ? Colors.white : null,
            ),
          ),
          3.verticalSpace,
          Text(
            message.isEdited ? '$time · edited' : time,
            style: TextStyle(
              fontSize: 10.sp,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 3.h,
        bottom: 3.h,
        left: isMe ? 60.w : 0,
        right: isMe ? 0 : 60.w,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: isMe
            ? Align(alignment: Alignment.centerRight, child: bubble)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSender)
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: AppNetworkImage(
                        url: sender?.avatarUrl,
                        size: 30.w,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusCircular,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 36.w),
                  Flexible(child: bubble),
                ],
              ),
      ),
    );
  }
}
