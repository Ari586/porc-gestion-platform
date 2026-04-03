from __future__ import annotations

import json
import os
from pathlib import Path

from pydantic import ValidationError
from starlette.applications import Starlette
from starlette.middleware.cors import CORSMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette.routing import Route

from .assistant import AgentScopeAssistantService, AgentScopeConfigurationError
from .models import AssistantChatRequest, CreatePostRequest
from .store import JsonPostStore


def create_app(
  *,
  store: JsonPostStore | None = None,
  assistant_service=None,
) -> Starlette:
  data_file = Path(os.getenv("TANTSAHAUP_DATA_FILE", "data/state.json"))
  store = store or JsonPostStore(data_file)
  assistant_service = assistant_service or _build_assistant_service()

  async def health(_request: Request) -> JSONResponse:
    return JSONResponse(
      {
        "ok": True,
        "service": "tantsahaup-agentscope-backend",
        "posts": len(store.list_posts()),
      },
    )

  async def feed(_request: Request) -> JSONResponse:
    return JSONResponse({"posts": [post.model_dump(mode="json") for post in store.list_posts()]})

  async def create_post(request: Request) -> JSONResponse:
    payload = _parse_model(await request.body(), CreatePostRequest)
    if isinstance(payload, JSONResponse):
      return payload
    post = store.create_post(payload)
    return JSONResponse({"post": post.model_dump(mode="json")}, status_code=201)

  async def like_post(request: Request) -> JSONResponse:
    return _mutate_post(store, request.path_params["post_id"], "like")

  async def comment_post(request: Request) -> JSONResponse:
    return _mutate_post(store, request.path_params["post_id"], "comment")

  async def share_post(request: Request) -> JSONResponse:
    return _mutate_post(store, request.path_params["post_id"], "share")

  async def trends(_request: Request) -> JSONResponse:
    return JSONResponse(
      {"trends": [trend.model_dump(mode="json") for trend in store.trends()]},
    )

  async def assistant_chat(request: Request) -> JSONResponse:
    payload = _parse_model(await request.body(), AssistantChatRequest)
    if isinstance(payload, JSONResponse):
      return payload
    if assistant_service is None:
      return JSONResponse(
        {
          "error": "assistant_unavailable",
          "detail": "AgentScope assistant is not configured. Add OPENAI_API_KEY or OPENROUTER_API_KEY.",
        },
        status_code=503,
      )
    try:
      reply = await assistant_service.ask(
        payload.message,
        context_summary=store.build_context_summary(),
      )
    except AgentScopeConfigurationError as exc:
      return JSONResponse(
        {"error": "assistant_not_configured", "detail": str(exc)},
        status_code=503,
      )
    except Exception as exc:  # pragma: no cover - defensive runtime path
      return JSONResponse(
        {"error": "assistant_failed", "detail": str(exc)},
        status_code=502,
      )
    return JSONResponse({"reply": reply})

  app = Starlette(
    debug=os.getenv("DEBUG", "").lower() == "true",
    routes=[
      Route("/health", health),
      Route("/api/feed", feed),
      Route("/api/posts", create_post, methods=["POST"]),
      Route("/api/posts/{post_id:str}/like", like_post, methods=["POST"]),
      Route("/api/posts/{post_id:str}/comment", comment_post, methods=["POST"]),
      Route("/api/posts/{post_id:str}/share", share_post, methods=["POST"]),
      Route("/api/trends", trends),
      Route("/api/assistant/chat", assistant_chat, methods=["POST"]),
    ],
  )
  app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
  )
  return app


def _parse_model(raw_body: bytes, model_cls):
  try:
    payload = json.loads(raw_body.decode("utf-8") or "{}")
  except json.JSONDecodeError:
    return JSONResponse({"error": "invalid_json"}, status_code=400)
  try:
    return model_cls.model_validate(payload)
  except ValidationError as exc:
    return JSONResponse(
      {"error": "validation_error", "detail": exc.errors()},
      status_code=400,
    )


def _mutate_post(store: JsonPostStore, post_id: str, action: str) -> JSONResponse:
  try:
    if action == "like":
      post = store.toggle_like(post_id)
    elif action == "comment":
      post = store.increment_comment(post_id)
    else:
      post = store.increment_share(post_id)
  except KeyError:
    return JSONResponse({"error": "post_not_found"}, status_code=404)
  return JSONResponse({"post": post.model_dump(mode="json")})


def _build_assistant_service():
  try:
    return AgentScopeAssistantService()
  except AgentScopeConfigurationError:
    return None


app = create_app()
