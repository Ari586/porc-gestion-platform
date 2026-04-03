# TantsahaUp AgentScope Backend

Dockerized ASGI backend for the TantsahaUp Flutter app.

## Features

- Feed API for posts, likes, comments, shares
- Trending hashtag aggregation
- AgentScope-powered assistant endpoint
- JSON file persistence mounted via Docker volume

## Local Docker Run

1. Copy `.env.example` to `.env`
2. Set `OPENAI_API_KEY` or `OPENROUTER_API_KEY`
3. Start:

```bash
docker compose up --build
```

The API will be available at `http://localhost:8088`.

If you keep `OPENAI_API_KEY` empty, the feed endpoints still work and the
assistant endpoint will return `503 assistant_unavailable`.

## Flutter App Against Docker Backend

Run the backend:

```bash
cd /Users/arielhavana/antigr/porc/agentscope_backend
docker compose up --build
```

Then start the Flutter app against it:

```bash
cd /Users/arielhavana/antigr/porc
flutter run -d chrome --web-port 8767 --dart-define=TANTSAHAUP_APP=true --dart-define=TANTSAHAUP_API_BASE_URL=http://localhost:8088
```

## Main Endpoints

- `GET /health`
- `GET /api/feed`
- `POST /api/posts`
- `POST /api/posts/{post_id}/like`
- `POST /api/posts/{post_id}/comment`
- `POST /api/posts/{post_id}/share`
- `GET /api/trends`
- `POST /api/assistant/chat`
