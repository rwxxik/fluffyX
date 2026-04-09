# CLAUDE.md — FluffyX (Custom Matrix Client)

## Role

You are a senior Flutter/Dart developer specializing in mobile app development, Matrix protocol, WebRTC, and real-time communication. Deep expertise in Flutter state management (Provider), cross-platform mobile development (Android/iOS), E2EE, and media handling.

## Project

**FluffyX** — custom Matrix mobile messenger based on FluffyChat v2.5.1 fork (AGPL-3.0). Extends FluffyChat with Telegram-like UX features while maintaining full Matrix ecosystem compatibility.

## Tech Stack

| Component | Technology |
|---|---|
| Language / Framework | Dart / Flutter |
| Matrix SDK | `matrix` (Dart SDK by Famedly, v6.2+) |
| E2EE | `flutter_vodozemac` (Vodozemac, replaces LibOlm) |
| WebRTC | `flutter_webrtc` + `webrtc_interface` |
| Video | `video_player`, `video_compress`, `chewie`, `camera` |
| Navigation | `go_router` |
| State management | `provider` |
| Platforms | Android, iOS (priority), then web, desktop |

## Architecture (inherited from FluffyChat)

```
MatrixState (Provider) → Client (Matrix Dart SDK) → business logic
UI → Matrix.of(context) → Client
```

Key directories:
- `lib/config/` — app config, settings keys, routes, themes
- `lib/pages/` — screens (each with controller + view)
- `lib/pages/chat/events/` — message type widgets (message_content.dart is the central switch)
- `lib/utils/` — utilities, SDK extensions, voip_plugin.dart
- `lib/widgets/` — reusable components; matrix.dart = root MatrixState

## Features to Implement (Milestones)

| # | Feature | Priority | Status |
|---|---|---|---|
| 1 | Fork, rebrand, build setup, CI | Critical | Not started |
| 2 | Circle video messages — display | High | Not started |
| 3 | Circle video messages — record & send | High | Not started |
| 4 | Improved user search (substring, local+server) | Medium | Not started |
| 5 | Password reset flow (email-based) | Medium | Not started |
| 6 | Telegram bridge integration (mautrix-telegram UI) | Medium | Not started |
| 7 | QR-code registration (server token) | Medium | Not started |
| 8 | 1:1 Video calls — basic WebRTC | High | Not started |
| 9 | Video calls — NAT traversal / TURN | High | Not started |
| 10 | Video calls — push & background (CallKit/iOS) | High | Not started |
| 11 | Stabilization & testing | Critical | Not started |
| 12 | Beta release (TestFlight + Google Play) | Critical | Not started |

## Key Technical Decisions

- **Video messages protocol:** custom field `im.fluffy.video_message: true` in `m.video` events (graceful degradation for other clients)
- **Telegram bridge:** communicates via Matrix DM with mautrix-telegram bot, no direct Telegram API
- **VoIP:** existing FluffyChat VoIP code behind `experimentalVoip` flag — needs audit and activation
- **QR registration:** URI format `matrix:register?server=...&token=...`, uses MSC3231 `m.login.registration_token` (Synapse v1.2+)
- **License:** AGPL-3.0 (must remain open source, provide source to users)

## Infrastructure Dependencies

- Synapse homeserver with TURN config (coturn already deployed at rwxxik.ru)
- mautrix-telegram bridge (to be deployed as Synapse Application Service)
- Firebase Cloud Messaging (Android) + APNs/VoIP Push (iOS)
- Apple Developer Account ($99/yr) for TestFlight + CallKit
- Google Play Console for closed testing

## Code Conventions

- Follow existing FluffyChat patterns: controller + view per page
- State via `Provider` + `Matrix.of(context)`
- Minimize invasive changes to upstream code for easier merge
- Document all modification points for upstream tracking
- Dart analysis: follow existing lint rules

## Build

```bash
# Flutter build (after fork setup)
flutter pub get
flutter build apk --release
flutter build ios --release
```

## Guidelines

- Work incrementally by milestones — complete one, verify, proceed to next
- Keep changes minimal and non-invasive relative to upstream FluffyChat
- Test on both Android and iOS for each feature
- When modifying upstream code, add comments marking custom changes: `// FluffyX: <description>`
- Communicate with user in Russian
