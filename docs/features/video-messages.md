# Video Messages (Circle / «Кружочки»)

## Статус
Done (Milestones 2-3)

## Описание
Telegram-подобные circle video messages: короткие видео (до 60 сек) с фронтальной камеры, отображаемые в круглом пузырьке с автоплеем без звука.

## Текущее состояние в FluffyChat
- Видео отправляются как вложения (`MessageTypes.Video` → `EventVideoPlayer`)
- Запись голосовых сообщений реализована (`RecordingInputRow` + `RecordingViewModel`) — использована как референс
- Нет аналога circle video messages

## Точки входа в код
- `lib/pages/chat/events/message_content.dart` — switch по типам сообщений, проверка `im.fluffy.video_message`
- `lib/pages/chat/events/circle_video_message.dart` — виджет отображения (NEW)
- `lib/pages/chat/circle_video_recorder.dart` — экран записи (NEW)
- `lib/pages/chat/chat_input_row.dart` — кнопка записи в панели ввода
- `lib/pages/chat/events/video_player.dart` — референс для обычного видео

## Задачи
- [x] Виджет `CircleVideoMessage` — `ClipOval` вокруг видеоплеера, ~200px, circular progress indicator
- [x] Автоплей без звука, тап для включения звука
- [x] Определение кружочка по полю `im.fluffy.video_message` в `message_content.dart`
- [x] Экран записи с круглым превью фронтальной камеры
- [x] Ограничение 60 секунд
- [x] Сжатие через `video_compress` перед отправкой
- [x] Генерация thumbnail
- [x] Отправка через `room.sendFileEvent()` с полем `im.fluffy.video_message: true`

## Зависимости
- Пакеты: `camera`, `video_player`, `video_compress`, `chewie`
- Все пакеты уже в `pubspec.yaml`

## Открытые вопросы
Нет — фича реализована.

## Связанные решения
- ADR-0002: Video Message Protocol
