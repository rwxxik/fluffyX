# Architecture Overview

## FluffyChat Base Architecture

FluffyX is a fork of FluffyChat v2.5.1 (~25-30k lines of Dart, excluding localizations).

### Core Pattern

```
MatrixState (Provider)
    └── Client (Matrix Dart SDK)
            └── Business logic (rooms, sync, crypto, VoIP)

UI Layer
    └── Matrix.of(context)
            └── Client
```

`MatrixState` (in `lib/widgets/matrix.dart`) is the root Provider. It owns:
- `Client` — Matrix SDK client instance
- `VoipPlugin` — WebRTC delegate
- `BackgroundPush` — push notification handler

### Directory Structure

| Directory | Purpose |
|-----------|---------|
| `lib/config/` | App config (`app_config.dart`), settings keys, routes (`routes.dart`), themes |
| `lib/pages/` | Screens — each in its own directory with controller + view |
| `lib/pages/chat/events/` | Message type widgets; `message_content.dart` is the central switch by `messageType` |
| `lib/utils/` | Utilities, SDK extensions, `voip_plugin.dart` |
| `lib/widgets/` | Reusable components; `matrix.dart` = root `MatrixState` |

### Page Pattern (Controller + View)

Each screen follows the pattern:
```
lib/pages/<feature>/
├── <feature>.dart          # Controller (StatefulWidget with business logic)
└── <feature>_view.dart     # View (StatelessWidget, pure UI)
```

Controller holds state and logic, view receives controller as parameter and renders UI.

### FluffyX Extension Points

Areas where FluffyX modifies or extends upstream FluffyChat:

| Area | Files | Description |
|------|-------|-------------|
| Circle video messages | `message_content.dart`, new `circle_video_message.dart`, `circle_video_recorder.dart` | Custom `im.fluffy.video_message` field in `m.video` events |
| VoIP activation | `voip_plugin.dart`, `setting_keys.dart`, `dialer.dart` | Enable `experimentalVoip`, add call buttons |
| User search | `new_private_chat.dart` | Substring search, local+server combined results |
| Password reset | `sign_in/` | "Forgot password" flow via email |
| Telegram bridge | New `settings_telegram_bridge/` | UI wizard for mautrix-telegram bot interaction |

All custom code is marked with `// FluffyX: <description>` comments.
