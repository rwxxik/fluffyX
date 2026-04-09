# FluffyX

**FluffyX** is a custom [Matrix](https://matrix.org) messenger based on [FluffyChat](https://github.com/krille-chan/fluffychat) v2.5.1 fork. It extends FluffyChat with Telegram-like UX features while maintaining full Matrix ecosystem compatibility.

**FluffyX** — кастомный мессенджер на базе протокола [Matrix](https://matrix.org), форк [FluffyChat](https://github.com/krille-chan/fluffychat) v2.5.1. Расширяет FluffyChat функциями в стиле Telegram, сохраняя полную совместимость с экосистемой Matrix.

> **This project contains AI-generated code.**
> Parts of the codebase were generated and/or modified using [Claude Code](https://claude.ai/claude-code) by [Anthropic](https://anthropic.com) (model: Claude Opus 4.6).

> **Проект содержит код, сгенерированный ИИ.**
> Часть кодовой базы была сгенерирована и/или изменена с помощью [Claude Code](https://claude.ai/claude-code) от [Anthropic](https://anthropic.com) (модель: Claude Opus 4.6).

---

## Features / Функции

### Inherited from FluffyChat / Унаследовано от FluffyChat

- End-to-end encryption (Vodozemac) — Сквозное шифрование
- Private and public group chats — Приватные и публичные групповые чаты
- Voice messages — Голосовые сообщения
- File, image and location sharing — Отправка файлов, изображений, геолокации
- Push notifications — Push-уведомления
- Spaces support — Поддержка пространств
- Cross-signing & emoji verification — Кросс-подпись и верификация эмодзи
- Material You design — Дизайн Material You

### Planned FluffyX Features / Планируемые функции FluffyX

| # | Feature / Функция | Description / Описание | Priority / Приоритет |
|---|---|---|---|
| 1 | **Circle video messages** — Круглые видеосообщения | Telegram-style round video messages — record, send and display / Круглые видеосообщения в стиле Telegram — запись, отправка и отображение | High / Высокий |
| 2 | **1:1 Video calls (WebRTC)** — Видеозвонки 1:1 | Native video/audio calls with TURN/NAT traversal support / Нативные видео/аудиозвонки с поддержкой TURN и NAT traversal | High / Высокий |
| 3 | **Push & background calls** — Push и фоновые звонки | CallKit (iOS) and background call handling / CallKit (iOS) и обработка звонков в фоновом режиме | High / Высокий |
| 4 | **Improved user search** — Улучшенный поиск пользователей | Substring search across local contacts and server directory / Поиск по подстроке среди локальных контактов и серверного каталога | Medium / Средний |
| 5 | **Password reset** — Сброс пароля | Email-based password reset flow on the login screen / Сброс пароля через email на экране входа | Medium / Средний |
| 6 | **Telegram bridge UI** — UI для Telegram-моста | Built-in UI for mautrix-telegram bridge login and status / Встроенный интерфейс для входа и статуса моста mautrix-telegram | Medium / Средний |
| 7 | **QR-code registration** — Регистрация по QR-коду | Scan QR code to auto-fill homeserver and registration token / Сканирование QR-кода для автозаполнения сервера и токена регистрации | Medium / Средний |

---

## Build / Сборка

### Requirements / Требования

- [Flutter](https://flutter.dev) 3.29+
- [Rust](https://www.rust-lang.org/tools/install) (for Vodozemac)

### Android

```bash
git clone https://github.com/rwxxik/fluffyX.git
cd fluffyX
flutter pub get
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
./scripts/prepare-web.sh
flutter build web --release
```

---

## Tech Stack / Стек технологий

| Component | Technology |
|---|---|
| Language / Framework | Dart / Flutter |
| Matrix SDK | `matrix` (Dart SDK by Famedly) |
| E2EE | `flutter_vodozemac` (Vodozemac) |
| WebRTC | `flutter_webrtc` |
| Navigation | `go_router` |
| State management | `provider` |
| Platforms | Android, iOS, Web, Desktop |

---

## Credits / Благодарности

FluffyX is a fork of [FluffyChat](https://github.com/krille-chan/fluffychat) v2.5.1 by [Krille](https://github.com/krille-chan).

FluffyX — форк [FluffyChat](https://github.com/krille-chan/fluffychat) v2.5.1 от [Krille](https://github.com/krille-chan).

Special thanks to the FluffyChat team, Famedly, and the Matrix community.

Отдельная благодарность команде FluffyChat, Famedly и сообществу Matrix.

---

## License / Лицензия

FluffyX is licensed under the [AGPL-3.0](LICENSE).

FluffyX распространяется под лицензией [AGPL-3.0](LICENSE).
