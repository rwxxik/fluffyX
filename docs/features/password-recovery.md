# Password Recovery (Email-based)

## Статус
Not Started (Milestone 5)

## Описание
Flow «забыл пароль» на экране логина через привязанный email. Доработка существующего экрана смены пароля.

## Текущее состояние в FluffyChat
- `settings_password/` — экран смены пароля при известном текущем пароле (через `Client.changePassword`)
- UIA (User-Interactive Authentication) flow частично реализован
- Нет сценария «забыл пароль» на экране логина
- `settings_3pid/` — управление привязанными email (для контекста)

## Точки входа в код
- `lib/pages/settings_password/` — текущий экран смены пароля
- `lib/pages/sign_in/` — экран логина (добавить "Забыли пароль?")
- `lib/pages/settings_3pid/` — управление привязанными email

## Задачи
- [ ] Проверить и доработать `settings_password` — корректная работа UIA flow (включая 2FA)
- [ ] Добавить ссылку «Забыли пароль?» на экран логина
- [ ] Реализовать flow: `requestTokenToResetPasswordEmail` → ожидание подтверждения → `setPassword`
- [ ] Информативные сообщения об ошибках (email не привязан, homeserver не поддерживает, ссылка просрочена)
- [ ] Визуальное оформление: поля ввода email, нового пароля, индикатор ожидания

## Зависимости
- **Серверные:** Synapse должен поддерживать email-based password reset (настроен SMTP)
- **Пакеты:** Matrix Dart SDK — `requestTokenToResetPasswordEmail`, `setPassword` (уже есть)

## Открытые вопросы
- Настроен ли SMTP на сервере rwxxik.ru для отправки email?
- Поддерживает ли текущий Synapse UIA flow для password reset?
