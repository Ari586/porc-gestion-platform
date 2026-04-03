# Socket Server (Node.js + Socket.io)

## Start server
1. `cd socket_server`
2. `npm install`
3. `npm start`

Server runs on `0.0.0.0:3001` and exposes:
- WebSocket signaling on `ws://<host>:3001`
- Health endpoint on `http://<host>:3001/health`

## Public deployment (already online)
- Socket/WebRTC signaling API:
  `https://porc-socket-signaling-520994990737.us-central1.run.app`
- Health check:
  `https://porc-socket-signaling-520994990737.us-central1.run.app/health`
- Online Socket demo (Flutter web):
  `https://porc-gestion-platform--socket-demo-puopa4iq.web.app`

## Flutter demo mode
The main Flutter app includes an optional Socket demo screen (`SocketChatCallPage`).

Run it with:

```bash
flutter run \
  --dart-define=SOCKET_DEMO=true \
  --dart-define=SOCKET_SERVER_URL=http://<YOUR_SERVER_PUBLIC_OR_LAN_IP>:3001 \
  --dart-define=SOCKET_ROOM_ID=chat-123 \
  --dart-define=SOCKET_USERNAME=UserA
```

For the second phone:

```bash
flutter run \
  --dart-define=SOCKET_DEMO=true \
  --dart-define=SOCKET_SERVER_URL=http://<YOUR_SERVER_PUBLIC_OR_LAN_IP>:3001 \
  --dart-define=SOCKET_ROOM_ID=chat-123 \
  --dart-define=SOCKET_USERNAME=UserB
```

## Important for different networks
- `localhost` or `10.0.2.2` only works locally, not phone-to-phone over internet.
- For two different networks, deploy this server on a public host (Render, Railway, Fly.io, VM, etc.).
- For WebRTC across mobile operators, provide TURN:
  - `--dart-define=WEBRTC_TURN_URLS=turn:...`
  - `--dart-define=WEBRTC_TURN_USERNAME=...`
  - `--dart-define=WEBRTC_TURN_CREDENTIAL=...`
