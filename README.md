<div align="center">

# 📢 GokGok

**A social fun app with a twist — chat with friends, hang out in groups, and _buzz_ them with meme sounds.**

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-45AAF2)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-blueviolet)](#-architecture)

</div>

---

## 🔔 What makes GokGok different?

Most chat apps let you _send_ a message. GokGok lets you **demand attention**.

The **Buzzer** is GokGok's signature feature: pick a popular meme sound effect (or import your own), aim it at a friend or a whole group, and press the buzzer — their phone **rings loud and vibrates** with your chosen sound. No more being left on read. 😈

## ✨ Features

|     | Feature              | Description                                                                           |
| --- | -------------------- | ------------------------------------------------------------------------------------- |
| 🔐  | **Auth**             | Email login & sign-up powered by Supabase Auth                                        |
| 💬  | **Realtime chat**    | Group messaging with live updates — no refresh needed                                 |
| ↩️  | **Message actions**  | Reply, edit, delete & copy via long-press                                             |
| 🧑‍🤝‍🧑  | **Groups**           | Create groups, manage roles (promote / demote / kick / transfer admin), group avatars |
| 📋  | **Smart chat list**  | Last-message previews, relative timestamps, sorted by recent activity                 |
| 🗓️  | **Readable history** | Date separators (Today / Yesterday / …), sender names & avatars                       |
| 🏠  | **Dashboard**        | Your groups and activity at a glance, with member avatar stacks                       |
| 👤  | **Profile**          | Avatar upload with built-in image cropping                                            |
| 📢  | **Buzzer**           | Meme-sound buzzer — the star of the show _(in progress)_                              |

## 🛠️ Tech stack

- **[Flutter](https://flutter.dev)** — one codebase, every platform
- **[Supabase](https://supabase.com)** — auth, Postgres, storage & realtime subscriptions
- **[Riverpod](https://riverpod.dev)** — state management
- **[go_router](https://pub.dev/packages/go_router)** — declarative navigation
- **just_audio · cached_network_image · flutter_svg · google_fonts** — the supporting cast

## 🏗️ Architecture

Pragmatic **Clean Architecture**, organised feature-first:

```
lib/
├── core/            # shared config, widgets, utilities
└── features/
    ├── auth/
    ├── buzzer/
    ├── chat/
    │   ├── data/          # Supabase data sources & repositories
    │   ├── domain/        # entities
    │   └── presentation/  # pages, widgets, providers
    ├── dashboard/
    ├── groups/
    ├── profile/
    └── splash/
```

Every feature keeps its `data` / `domain` / `presentation` layers to itself — easy to find, easy to change.

## 🚀 Getting started

**1. Clone & install**

```bash
git clone https://github.com/<your-username>/gokgok.git
cd gokgok
flutter pub get
```

**2. Configure Supabase**

Create an `env.json` in the project root with your [Supabase](https://supabase.com) project credentials:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key"
}
```

**3. Run**

```bash
flutter run
```

## 🗺️ Roadmap

- [x] Auth (login / sign-up)
- [x] Group chat with replies, edits & deletes
- [x] Dashboard & profile
- [x] Group management (roles, avatars)
- [ ] Buzzer v1 — sound picker, custom sound import, remote buzz 📢
- [ ] Image messages
- [ ] 1:1 direct messages
- [ ] Unread badges & read receipts
- [ ] Typing indicators
- [ ] Push notifications
- [ ] Voice & video calls

## 🤝 Contributing

Found a bug or have an idea? Open an issue or send a PR — all contributions welcome.

---

<div align="center">

**Made with 💙 and Flutter**

_Don't just text them. Buzz them._ 📢

</div>
