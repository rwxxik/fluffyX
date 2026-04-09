# Telegram Bridge Integration

## Статус
Not Started (Milestone 6)

## Описание
UI-обёртка в настройках приложения для привязки Telegram-аккаунта через mautrix-telegram bot. Визард авторизации (телефон/QR), отображение статуса.

## Текущее состояние в FluffyChat
- Нет встроенной поддержки мостов (bridges)
- Для mautrix-telegram пользователь должен вручную найти бота, создать DM и вводить текстовые команды

## Точки входа в код
- `lib/pages/settings/` — добавить пункт меню «Telegram»
- Создать `lib/pages/settings_telegram_bridge/` — новая страница (controller + view)
- `lib/config/app_config.dart` — адрес бота моста по умолчанию
- `lib/config/routes.dart` — маршрут к новой странице

## Задачи
- [ ] Конфиг: `telegramBridgeBot` в `app_config.dart` (default: `@telegrambot:<homeserver>`)
- [ ] Новая страница `settings_telegram_bridge` (controller + view по паттерну FluffyChat)
- [ ] Маршрут в `routes.dart`
- [ ] Пункт меню в `settings/`
- [ ] Определение статуса: проверка DM с ботом + команда `ping`
- [ ] UI flow — по телефону:
  - Шаг 1: Выбор способа входа
  - Шаг 2: Поле ввода номера телефона с маской, отправка `login` + номер
  - Шаг 3: Поле ввода кода подтверждения из Telegram
  - Шаг 4: Поле ввода 2FA пароля (если требуется)
  - Шаг 5: Успешная привязка
- [ ] UI flow — по QR:
  - Отправка `login-qr`, отображение QR из `m.image` ответа бота
- [ ] Отвязка: команда `logout`, подтверждение, обновление статуса
- [ ] Обработка ошибок: неверный код, истёкший код, 2FA, бот недоступен, rate limit

## Зависимости
- **Серверные:** mautrix-telegram установлен на homeserver'е — **NOT DEPLOYED** (см. docs/server/)
- **Пакеты:** нет дополнительных, используется стандартный Matrix SDK для отправки/получения сообщений

## Открытые вопросы
- Когда будет развёрнут mautrix-telegram на сервере?
- Какую версию mautrix-telegram таргетировать для парсинга ответов?
- Нужна ли поддержка нескольких мостов (теоретически несколько homeserver'ов)?

## Связанные решения
- ADR-0004: Telegram Bridge Integration
