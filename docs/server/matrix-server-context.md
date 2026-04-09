# Контекст серверного проекта Matrix

## Homeserver
- **Тип:** Synapse v1.127.1
- **Server name:** `rwxxik.ru`
- **Public URL:** `https://matrix.rwxxik.ru`
- **API:** `https://matrix.rwxxik.ru/_matrix/client/versions`
- **TLS:** Let's Encrypt (Caddy auto-renewal, cert valid until 2026-07-01)
- **Registration:** Disabled (`enable_registration: false`) — admin-only user creation
- **Статус:** Production ready, all 7 deployment phases complete (2026-04-02)

## Компоненты

| Компонент | Версия | Статус | Ограничения |
|-----------|--------|--------|-------------|
| Synapse | v1.127.1 | DEPLOYED, healthy | — |
| PostgreSQL | 17.7 (Timeweb managed) | DEPLOYED | External DB, 164 tables |
| S3 storage | Timeweb S3-250 | DEPLOYED | Bucket `matrix-data`, endpoint `s3.twcstorage.ru` |
| Caddy | v2.9-alpine | DEPLOYED | Reverse proxy, auto TLS |
| Element Web | v1.11.96 | DEPLOYED | `https://matrix.rwxxik.ru` |
| synapse-admin | v0.10.3 | DEPLOYED | `https://admin.rwxxik.ru` (basic auth) |
| Coturn (TURN/STUN) | v4.6.3-alpine | DEPLOYED, VERIFIED | Shared-secret auth, UDP 49152-65535 |
| LiveKit (SFU) | v1.8.4 | DEPLOYED, VERIFIED | Group video, ports 50000-60000/UDP |
| lk-jwt-service | v0.4.2 | DEPLOYED | `https://matrix.rwxxik.ru/lk-jwt` |
| Prometheus | v3.4.0 | DEPLOYED | Scraping Synapse, Node Exporter |
| Grafana | v11.6.0 | DEPLOYED | `https://admin.rwxxik.ru/grafana/` |
| Loki + Promtail | v3.5.0 | DEPLOYED | 30-day log retention |
| Alertmanager | v0.28.1 | DEPLOYED | Telegram webhook NOT configured |
| mautrix-telegram | — | NOT DEPLOYED | Блокирует milestone 6 |
| Push gateway | — | NOT CONFIGURED | Клиент должен реализовать Firebase/APNs |

## TURN/STUN Configuration (for VoIP)

```
Protocol: TURN/STUN (RFC 5766)
External IP: 72.56.243.73
Ports: 3478/TCP+UDP, 5349/TCP+UDP (TURNS)
Media ports: 49152-65535/UDP
Auth: Shared secret (time-based HMAC, matched in Synapse)
```

Synapse integration:
- `turn_uris`: `["turns:matrix.rwxxik.ru:5349?transport=udp", "turns:matrix.rwxxik.ru:5349?transport=tcp"]`
- `turn_shared_secret`: configured in `.env`
- `/voip/turnServer` API — verified working

**Verified:** 1:1 audio calls work from mobile networks.

## LiveKit (Group Video)

- SFU mode, network mode: `host`
- IP filtering: only public IP 72.56.243.73
- `.well-known/matrix/client` includes `org.matrix.msc4143.rtc_foci`
- **Verified:** Group video calls (3+ users) work without VPN

## Ограничения для клиентской разработки

1. **Push notifications:** No server-side push gateway — клиент должен реализовать Firebase (Android) и APNs (iOS) самостоятельно
2. **Telegram bridge:** mautrix-telegram не развёрнут — milestone 6 заблокирован
3. **User registration:** Отключена — новые пользователи создаются только через admin panel или API
4. **Email (SMTP):** Статус неизвестен — нужно проверить для password recovery flow (milestone 5)
5. **Docker Hub:** Заблокирован в России — используется mirror `dockerhub.timeweb.cloud`

## Пользователи

| User | Role |
|------|------|
| `@rwxxik:rwxxik.ru` | Admin (primary) |
| `@admin:rwxxik.ru` | Admin (secondary) |

## Инфраструктура (Timeweb Cloud)

| Ресурс | Endpoint | Характеристики |
|--------|----------|----------------|
| VPS | 72.56.243.73 | 4 vCPU, 8GB RAM, Ubuntu 24.04 |
| PostgreSQL | 10.0.0.4:5432 | Managed, auto backups |
| S3 | s3.twcstorage.ru | 250GB plan |
| Domain | rwxxik.ru | A-record → 72.56.243.73 |

**Monthly cost:** ~3,000₽ (~50 users)

## Серверный проект
- Path: `/home/rwxxik/serverProjects/matrix`
- Spec: `MATRIX_DEPLOYMENT_TASK.md`
- Progress: `PROGRESS.md`
