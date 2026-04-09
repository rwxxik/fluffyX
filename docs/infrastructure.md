# Зависимости и инфраструктура

## Серверная инфраструктура

| Компонент | Endpoint | Статус | Нужен для |
|-----------|----------|--------|-----------|
| Synapse homeserver | `https://matrix.rwxxik.ru` | DEPLOYED | Всё |
| Coturn (TURN/STUN) | `matrix.rwxxik.ru:5349` | DEPLOYED | Milestones 8-10 (VoIP) |
| LiveKit (SFU) | `matrix.rwxxik.ru:7881` | DEPLOYED | Групповые звонки |
| mautrix-telegram | — | NOT DEPLOYED | Milestone 6 |
| SMTP (email) | — | Unknown | Milestone 5 (password reset) |

## Внешние сервисы

| Сервис | Статус | Нужен для | Стоимость |
|--------|--------|-----------|-----------|
| Apple Developer Account | Not purchased | TestFlight, CallKit, VoIP Push (milestones 10, 12) | $99/year |
| Google Play Console | Not configured | Closed testing (milestone 12) | $25 one-time |
| Firebase (FCM) | Not configured | Push notifications (Android) | Free tier |
| APNs | Not configured | Push notifications (iOS) | Included in Apple Dev Account |

## Пакеты Flutter (ключевые)

| Пакет | Назначение | Milestones |
|-------|-----------|------------|
| `matrix` (6.2.0) | Matrix SDK | All |
| `flutter_webrtc` (1.3.1) | WebRTC | 8-10 |
| `camera` (0.11.1) | Video capture | 3 (done) |
| `video_compress` (3.1.4) | Video compression | 3 (done) |
| `video_player` (2.11.1) | Video playback | 2-3 (done) |
| `flutter_foreground_task` (9.2.1) | Background calls (Android) | 10 |
| `unifiedpush` (6.2.0) | Push abstraction | 10 |

## CI/CD

- **GitHub Actions** — inherited from FluffyChat, workflows in `.github/workflows/`
- **Fastlane** — configured for iOS and Android builds
- **Docker Hub mirror:** `dockerhub.timeweb.cloud` (Docker Hub blocked in Russia)
