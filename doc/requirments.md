# idea

Project idea is to have a social fun app. Users can login, chat with friends, audio call, video call, chat in groups — a normal social app.

One special feature that makes my app different from others is the **buzzer** feature. It's a feature where a user can select from a given list of popular meme sound effects (or import their own personal one), and when they press the buzzer a group or a targeted user gets buzzed with the selected meme sound. Their phone rings loud with the selected sound and vibrates.

# structure

- backend: Supabase (chosen for its realtime data)
- frontend: Flutter
- state management: Riverpod
- follow clean architecture all over the app

# feature required vs done

- [x] auth (login / sign up)
- [x] chat (1-to-1)
- [x] group chat
- [x] profile
- [x] dashboard / home
- [ ] voice call
- [ ] video call
- [~] buzzer function — plays a local buzzer sound; still need: sound selection from list, import personal sound, and remote buzz to a targeted user/group (ring loud + vibrate)

# chat feature gaps (audit 2026-07-03)

Working today: realtime group text chat, auto-created conversation per group, members page (roles, promote/demote/kick/transfer admin, group avatar). Schema already supports replies (`reply_to_id`), edit (`edited_at`), delete (`deleted_at`), media (`type`/`metadata`); `last_message_at` is written but unused.

- [x] don't lose message text on failed send (input is cleared before the await, no error handling)
- [x] remove dead "Abc" menu item in group chat header; direct members button
- [x] don't auto-scroll to bottom while user is reading history
- [x] sender name + avatar on others' bubbles in group chat
- [x] date separators (Today / Yesterday / date)
- [x] chat list: last-message preview + timestamp per tile
- [x] chat list: sort by recent activity (`last_message_at`)
- [x] message actions on long-press: copy / reply / edit / delete (own)
- [ ] image messages (picker + storage upload + viewer already exist for avatars)
- [ ] unread badges (needs `last_read_at` column on `conversation_members`)
- [ ] read receipts
- [ ] typing indicators (Supabase realtime broadcast)
- [ ] message pagination (stream currently loads full history)
- [ ] push notifications for new messages (needs FCM setup)
- [ ] 1:1 direct messages (schema has `conversations.type`; chat list is group-only today)
