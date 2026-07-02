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
