# Handover — Dashboard profile (avatar + name)

## Goal
Show the logged-in user's profile avatar and full name in the dashboard header,
sourced from the Supabase `profiles` table via a Riverpod provider.

## What was done this session

### 1. `DashboardModel` — `domain/entities/dashboard_model.dart`
- Added `copyWith({avatarUrl, fullName})`.
- Added `factory DashboardModel.fromJson(Map<String, dynamic>)` reading JSON keys
  `avatar_url` and `full_name`.

### 2. Repository impl — `data/repository/dashboard_repository_impl.dart`
- Fixed a runtime bug: it was casting the un-awaited `Future` from
  `fetchProfileRow` to a `Map` (would crash).
- Now awaits `fetchProfileRow` and returns `DashboardModel(null, null)` when the
  user id or the profile row is null.

### 3. Provider — `presentation/providers/dashboard_provider.dart`
- Added `dashboardRepositoryProvider` (DI via `supabaseClientProvider`, matching
  the `groupProvider` pattern).
- Implemented `DashboardNotifier.build()` → `_repository.getDashboardData()`.

### 4. Screen — `presentation/screens/home_widget.dart`
- Header watches `dashboardProvider` (`.value`) and shows:
  - `fullName` text (when non-empty).
  - Avatar from `avatarUrl` via `Image.network`, falling back to
    `AppAssets.profilePlaceholder` on error / empty URL.

## Notes / dependencies
- Requires the Supabase `profiles` table to have `full_name` and `avatar_url`
  columns (the keys `fromJson` reads). Different column names → null values →
  placeholder shown with no name.
- This Riverpod version exposes `AsyncValue.value` (not `.valueOrNull`).
- All four files pass analysis with no diagnostics.

## Possible follow-ups
- Add loading/error UI in the header (currently just falls back to placeholder).
- Refresh the profile after edits (e.g. `ref.invalidate(dashboardProvider)` from
  the profile screen).
- The other avatar spot (`/profile` route) could reuse the same provider.
