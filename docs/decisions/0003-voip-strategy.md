# ADR-0003: VoIP Strategy — Phased Activation of Existing Code

## Статус
Accepted

## Контекст
FluffyChat уже содержит VoIP-инфраструктуру, скрытую за флагом `experimentalVoip`:
- `VoipPlugin` — WebRTC delegate, обработка `CallSession`
- `Dialer` — UI звонка (~610 строк), видеопотоки, PIP, mute/hold
- Jitsi Meet интеграция (отдельная, для групповых звонков)

Сервер уже готов: coturn (TURN/STUN) на rwxxik.ru:5349, LiveKit v1.8.4 для групповых звонков.

Варианты:
1. **Написать VoIP с нуля** — полный контроль, но дублирование работы
2. **Активировать существующий код поэтапно** — быстрее, но риск legacy багов
3. **Использовать стороннее решение** (например, только Jitsi) — ограниченный UX

## Решение
Поэтапная активация существующего VoIP кода с аудитом и доработкой:

### Phase 1 — Basic WebRTC (Milestone 8)
- Включить `experimentalVoip` flag
- Аудит `VoipPlugin` и `Dialer` на совместимость с текущей версией Matrix SDK
- Добавить кнопки вызова (аудио/видео) в шапку 1:1 чата
- Тестирование в LAN (без TURN)

### Phase 2 — NAT Traversal (Milestone 9)
- Интеграция с coturn через Synapse TURN API (`/voip/turnServer`)
- Тестирование за NAT (мобильная сеть → Wi-Fi)
- Обработка переключения сетей, reconnect

### Phase 3 — Push & Background (Milestone 10)
- **Android:** `FlutterForegroundTask` для входящих при заблокированном экране
- **iOS:** CallKit + VoIP Push через APNs
- Обработка прерываний (GSM-звонок, переключение аудиоустройств)

## Последствия

### Плюсы
- Быстрый старт — основной код уже написан
- Инкрементальная сложность — каждая фаза тестируема независимо
- Серверная инфраструктура готова (coturn, LiveKit)

### Минусы
- Существующий VoIP код может быть устаревшим (риск: средний)
- CallKit на iOS — значительная нативная работа (риск: высокий)
- Без Phase 3 звонки не будут работать в фоне на iOS

### Критический риск: iOS CallKit
CallKit-интеграция обязательна для прохождения App Store Review. Требуется:
- VoIP Push certificate (Apple Developer Account)
- Нативный Swift-код в `ios/Runner/`
- Тестирование на реальном устройстве (симулятор не поддерживает push)

**Fallback:** если CallKit окажется слишком сложным на первом этапе — iOS звонки только в foreground, выпуск через TestFlight (не App Store).

## Связанные документы
- docs/features/video-calls.md
- docs/server/matrix-server-context.md (TURN/LiveKit status)
