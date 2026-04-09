# Текущий спринт

## Активная веха
Milestone 4: Improved User Search

## В работе
- [x] Local contacts search (substring matching on displayName + userId)
- [x] Combined local + server results with deduplication
- [x] Section headers (Contacts / Search on server)
- [x] Limit server search to 20 results
- [x] dispose() for TextEditingController, FocusNode, Timer
- [x] L10n keys (en, ru)

## Заблокировано
- **Milestone 6** (Telegram bridge) — mautrix-telegram не развёрнут на сервере
- **Milestone 10** (VoIP push/background) — требует Apple Developer Account

## Low-priority fixes
- [LOW] `_SectionHeader` passes ThemeData as param instead of reading from context (works correctly, style nit)

## Решения принятые в процессе
- [2026-04-09] Реструктуризация документации в ADR-формат
- [2026-04-09] Milestone 4: используем `client.rooms` для локального поиска по direct chats

## Завершённые задачи (предыдущие спринты)
- [x] Milestone 1: Fork, rebrand — PR #6
- [x] Milestone 2: Circle video display — PR #7
- [x] Milestone 3: Circle video record & send — PR #8
