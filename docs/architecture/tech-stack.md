# Tech Stack

## Core

| Component | Technology | Version | Notes |
|-----------|-----------|---------|-------|
| Language | Dart | >=3.11.1 <4.0.0 | SDK constraint from pubspec |
| Framework | Flutter | latest stable | Material Design, cross-platform |
| Matrix SDK | `matrix` (Famedly) | 6.2.0 | Core protocol, sync, crypto |
| E2EE | `flutter_vodozemac` | 0.5.0 | Vodozemac (replaces LibOlm) |
| State management | `provider` | 6.0.2 | `MatrixState` as root provider |
| Navigation | `go_router` | 17.1.0 | Declarative routing |

## Media & Communication

| Component | Technology | Version | Notes |
|-----------|-----------|---------|-------|
| WebRTC | `flutter_webrtc` | 1.3.1 | 1:1 video/audio calls |
| WebRTC interface | `webrtc_interface` | 1.3.0 | Abstract WebRTC layer |
| Video playback | `video_player` | 2.11.1 | Standard video widget |
| Video UI | `chewie` | 1.13.0 | Video player controls |
| Video compression | `video_compress` | 3.1.4 | Pre-send compression |
| Camera | `camera` | 0.11.1 | Circle video recording |
| Audio | `just_audio` | 0.10.5 | Audio message playback |
| Audio recording | `record` | 6.1.2 | Voice message capture |

## Platform & System

| Component | Technology | Version | Notes |
|-----------|-----------|---------|-------|
| Push (unified) | `unifiedpush` | 6.2.0 | Push notification abstraction |
| Foreground tasks | `flutter_foreground_task` | 9.2.1 | Background call handling (Android) |
| Local notifications | `flutter_local_notifications` | 21.0.0 | Local notification display |
| Secure storage | `flutter_secure_storage` | 10.0.0 | Credential storage |
| File picker | `file_picker` | 10.3.10 | File attachment selection |
| Image picker | `image_picker` | 1.2.1 | Gallery/camera image selection |
| SQLite | `sqflite_common_ffi` + `sqlcipher_flutter_libs` | 2.3.7+1 / 0.6.8 | Encrypted local database |

## Target Platforms

| Platform | Priority | Status |
|----------|----------|--------|
| Android | Primary | Active development |
| iOS | Primary | Active development |
| Web | Secondary | Inherited from FluffyChat |
| Desktop (Linux/macOS/Windows) | Tertiary | Inherited from FluffyChat |

## Dependency Overrides

| Package | Reason | Tracking |
|---------|--------|----------|
| `webcrypto` (git master) | 16kb page size compatibility for Play Store | [webcrypto#207](https://github.com/google/webcrypto.dart/issues/207) |
