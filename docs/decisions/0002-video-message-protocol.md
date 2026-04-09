# ADR-0002: Video Message Protocol — Custom Field in m.video

## Статус
Accepted (реализовано в milestones 2-3)

## Контекст
Нужно реализовать «кружочки» (circle video messages) как в Telegram. Matrix-протокол не имеет стандартного типа для таких сообщений. Варианты:

1. **Новый `msgtype`** (например `m.video_message`) — нарушает спецификацию, другие клиенты не отобразят даже как обычное видео
2. **MSC proposal** — правильно по процессу, но долго (месяцы на принятие), блокирует разработку
3. **Кастомное поле в `m.video`** — расширение стандартного типа, graceful degradation

## Решение
Используем стандартное событие `m.room.message` с `msgtype: "m.video"` и дополнительным кастомным полем:

```json
{
  "msgtype": "m.video",
  "body": "video_message.mp4",
  "im.fluffy.video_message": true,
  "info": {
    "mimetype": "video/mp4",
    "duration": 12000,
    "w": 400,
    "h": 400
  },
  "url": "mxc://server/media_id"
}
```

Namespace `im.fluffy` — наш проектный namespace (по конвенции Matrix для кастомных полей).

## Последствия

### Плюсы
- **Graceful degradation** — другие клиенты (Element, NeoChat) покажут обычное видео, просто проигнорировав неизвестное поле
- Не нарушает Matrix spec
- Быстрая реализация, не требует координации с сообществом
- Легко заменить на стандартный подход, если появится соответствующий MSC

### Минусы
- Только FluffyX показывает видео как «кружочек»
- Нет гарантии, что другие клиенты подхватят этот формат
- Теоретический риск коллизии namespace (крайне низкий)

### Параметры записи
- Максимальная длительность: 60 секунд
- Камера: фронтальная по умолчанию
- Aspect ratio: 1:1 (квадрат, отображается в круге через `ClipOval`)
- Сжатие: через `video_compress` перед отправкой

## Связанные документы
- docs/features/video-messages.md
- PR #7 (milestone 2: display)
- PR #8 (milestone 3: record & send)
