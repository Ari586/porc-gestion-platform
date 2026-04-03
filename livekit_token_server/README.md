# LiveKit Token Server

Minimal backend that generates LiveKit JWT tokens for the Flutter app.

## 1) Setup

```bash
cd livekit_token_server
npm install
cp .env.example .env
```

Fill `.env`:

- `LIVEKIT_URL`
- `LIVEKIT_API_KEY`
- `LIVEKIT_API_SECRET`
- optional `CLIENT_SHARED_SECRET`
- optional `CORS_ORIGIN`

## 2) Run

```bash
npm start
```

Health:

```bash
curl http://localhost:3000/health
```

## 3) Token endpoint

`POST /livekit/token`

Body:

```json
{
  "roomName": "pigia_CALL-123",
  "participantId": "U1",
  "participantName": "Jean Responsable",
  "sessionId": "CALL-123"
}
```

Response:

```json
{
  "url": "wss://YOUR-LIVEKIT-ENDPOINT",
  "token": "LIVEKIT_JWT",
  "roomName": "pigia_CALL-123",
  "participantId": "U1"
}
```

If `CLIENT_SHARED_SECRET` is configured, send header:

`x-client-secret: <same secret>`

## 4) Connect Flutter app

In `.env.turn` at project root:

```bash
CALL_TRANSPORT=livekit
LIVEKIT_TOKEN_ENDPOINT=https://YOUR_TOKEN_SERVER/livekit/token
LIVEKIT_CLIENT_SECRET=CHANGE_ME
```

Then deploy:

```bash
./scripts/deploy_webrtc_prod.sh
```
