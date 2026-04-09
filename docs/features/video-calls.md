# Video Calls (1:1 WebRTC)

## Статус
Not Started (Milestones 8-10)

## Описание
1:1 аудио- и видеозвонки через WebRTC с поддержкой NAT traversal (TURN), push-уведомлений и фонового режима.

## Текущее состояние в FluffyChat
- `VoipPlugin` (`utils/voip_plugin.dart`) — реализация `WebRTCDelegate`, создаёт `VoIP(client, this)`, обрабатывает `CallSession`, управляет overlay
- `Dialer` (`pages/dialer/dialer.dart`, ~610 строк) — UI звонка: видеопотоки, mute/hold/screenshare, PIP
- Jitsi Meet интеграция (`jitsi_popup_button.dart`) — конференция в браузере (отдельная, не WebRTC)
- Всё скрыто за флагом `experimentalVoip` (default: `false`)
- Каркас `FlutterForegroundTask` для Android уже существует

## Точки входа в код
- `lib/utils/voip_plugin.dart` — основной VoIP delegate
- `lib/pages/dialer/dialer.dart` — UI звонка
- `lib/widgets/matrix.dart` — инициализация `voipPlugin`
- `lib/config/setting_keys.dart` — флаги `experimentalVoip`, `jitsiFeature`, `jitsiDomain`
- `ios/Runner/` — для CallKit интеграции (нативный Swift)

## Задачи

### Phase 1 — Basic WebRTC (Milestone 8)
- [ ] Аудит `VoipPlugin` и `Dialer` на совместимость с Matrix SDK v6.2
- [ ] Включить `experimentalVoip` по умолчанию
- [ ] Добавить кнопки аудио/видео вызова в шапку 1:1 чата
- [ ] Стабилизировать сигналинг: `m.call.invite`, `m.call.answer`, `m.call.candidates`, `m.call.hangup`
- [ ] Тестирование в LAN (без TURN)

### Phase 2 — NAT Traversal (Milestone 9)
- [ ] Интеграция с TURN через Synapse API (`/voip/turnServer`)
- [ ] Тестирование: мобильная сеть ↔ Wi-Fi
- [ ] Обработка переключения сетей, reconnect
- [ ] Edge cases: wakelock, переключение аудиоустройств

### Phase 3 — Push & Background (Milestone 10)
- [ ] Android: `FlutterForegroundTask` для входящих при заблокированном экране
- [ ] iOS: CallKit + VoIP Push (APNs)
- [ ] Обработка прерываний (GSM-звонок поверх VoIP)
- [ ] Переключение динамик / наушники / Bluetooth

## Зависимости
- **Серверные:** coturn (TURN/STUN) — DEPLOYED, LiveKit — DEPLOYED
- **Пакеты:** `flutter_webrtc` (1.3.1), `webrtc_interface` (1.3.0) — уже в pubspec
- **iOS:** Apple Developer Account ($99/yr), VoIP Push Certificate
- **Android:** Firebase Cloud Messaging config

## Открытые вопросы
- Насколько актуален VoIP код FluffyChat с текущей версией Matrix SDK? (требуется аудит)
- Сложность CallKit на iOS — возможно потребуется fallback на foreground-only
- Нужна ли поддержка групповых звонков (LiveKit) или только 1:1?

## Связанные решения
- ADR-0003: VoIP Strategy
