# Handover — Chat feature: gap audit + first batch of fixes/features

Session date: 2026-07-03. **All changes are uncommitted** (see `git status`) —
analyzer is clean, but nothing has been run on a device yet. Verify (below),
then commit.

## What was done this session

### 1. Group avatar in dashboard groups widget
`lib/features/groups/presentation/widgets/your_groups_widget.dart` — tile
`leading` now shows `AppNetworkImage(group.groupAvatarUrl)` with the
initial-letter `CircleAvatar` fallback (same pattern as `chat_page.dart`).

### 2. Disk caching for all network images
- Added `cached_network_image` to pubspec.
- `lib/core/widgets/app_network_image.dart` body swapped from `Image.network`
  to `CachedNetworkImage` — every image in the app routes through this widget,
  so avatars/photos no longer re-download on app restart.
- The two raw `NetworkImage(member.avatarUrl)` uses in the avatar stacks
  (`your_groups_widget.dart`, `chat_page.dart`) now use
  `CachedNetworkImageProvider`.

### 3. Chat gap audit → `doc/requirments.md`
New "chat feature gaps" section: full checklist of what was missing,
implemented items ticked, backlog unticked. **That checklist is the
source of truth for what's pending.**

### 4. Chat reliability fixes (`group_chat_page.dart`)
- Failed send restores the typed text + shows a SnackBar (was silently lost:
  input cleared before the await, no error handling).
- Dead "Abc" popup menu removed from the chat header (now a direct members
  IconButton) and from the chat-list tiles.
- Auto-scroll only fires within ~200px of the bottom; first open still jumps
  to the newest message (`_didInitialScroll`).

### 5. Group chat readability (`group_chat_page.dart`)
- Others' bubbles: sender username + avatar on the first message of each
  sender run. Members come from `groupMembersProvider(group.id)` (live) with
  `widget.group.members` as fallback.
- `_DateSeparator` chips: Today / Yesterday / "5 Mar" (year appended if not
  current). Hand-rolled month names — no intl dependency.
- Timestamps now `.toLocal()` (were displayed in UTC before).

### 6. Chat list previews + sorting (`chat_page.dart` + data layer)
- New entity: `lib/features/chat/domain/entities/conversation_preview.dart`.
- Data source: `fetchConversationPreviews(groupIds)` (conversations with
  embedded newest non-deleted message) and `watchConversations(groupIds)`
  stream.
- Repository: `watchConversationPreviews()` re-fetches previews on every
  conversations-stream event. Works live because every send bumps
  `last_message_at` (`touchConversation`).
- Provider: `conversationPreviewsProvider` in `chat_provider.dart` (derives
  group ids from `groupProvider.future`).
- UI: tile subtitle "sender: message" (falls back to the old avatar stack when
  no messages yet), trailing relative time, list sorted by `last_message_at`
  desc, empty groups last.

### 7. Message actions (`group_chat_page.dart` + data layer)
- Long-press bubble → bottom sheet: Reply / Copy always; Edit / Delete on own
  messages.
- Data: `insertMessage` gained `replyToId`; new `updateMessage` (sets
  `edited_at`) and `softDeleteMessage` (sets `deleted_at`; the stream already
  filtered deleted). Repository: `sendMessage(..., {replyToId})`,
  `editMessage`, `deleteMessage`.
- Reply: quoted box inside the bubble (resolved from the loaded message list;
  "Message unavailable" if the original was deleted) + "Replying to X" strip
  above the input.
- Edit: prefills the input, strip shows "Editing message", bubble gets
  "· edited" next to the time.

## Known ceilings (marked with `ponytail:` comments)
- `chat_repository_impl.dart` → `watchConversationPreviews`: editing/deleting
  the *latest* message doesn't refresh the chat-list preview until the next
  send (only sends bump `last_message_at`).

## Pending — next session starts here

**Not yet verified on device** (do this first):
- Run with two accounts: send / reply / edit / delete propagation, sender
  names + date separators, chat-list preview updating + sort order,
  failed-send path (airplane mode → text restored + snackbar),
  scroll behavior while reading history.
- Then commit.

**Backlog** (unticked in `doc/requirments.md`, roughly in order of value):
1. Image messages — picker, storage upload, and viewer already exist for
   avatars; messages have `type`/`metadata` columns ready.
2. Unread badges — needs a `last_read_at` column on `conversation_members`
   (schema migration) + update-on-open + count in chat list.
3. Message pagination — stream currently loads full history per conversation.
4. Read receipts, typing indicators (Supabase realtime broadcast).
5. Push notifications — no FCM in the project at all; needs Firebase setup.
6. 1:1 direct messages — `conversations.type` exists; chat list is
   group-only today.
7. Older backlog from the same file: voice call, video call, buzzer
   completion (sound list, import, remote buzz).

## Notes
- No intl package; dates/times are hand-formatted (chat_page `_relativeTime`,
  group_chat_page `_DateSeparator`).
- `firstOrNull` is used without importing package:collection — resolves fine
  with the current SDK.
- `macos/GeneratedPluginRegistrant.swift` + `pubspec.lock` changed as a side
  effect of `flutter pub add cached_network_image`.
