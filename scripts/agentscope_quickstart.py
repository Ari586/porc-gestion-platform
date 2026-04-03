#!/usr/bin/env python3
"""Run a minimal AgentScope ReAct agent against a detected model provider."""

from __future__ import annotations

import asyncio
import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

import agentscope
from agentscope.agent import ReActAgent
from agentscope.formatter import (
    AnthropicChatFormatter,
    DashScopeChatFormatter,
    GeminiChatFormatter,
    OpenAIChatFormatter,
)
from agentscope.message import Msg
from agentscope.model import (
    AnthropicChatModel,
    DashScopeChatModel,
    GeminiChatModel,
    OpenAIChatModel,
)
from agentscope.tool import Toolkit, execute_python_code

try:
    from openai import APIConnectionError, APIStatusError, AuthenticationError, RateLimitError
except Exception:  # pragma: no cover - defensive import fallback
    APIConnectionError = APIStatusError = AuthenticationError = RateLimitError = ()  # type: ignore[assignment]


DEFAULT_PROMPT = (
    "Use Python if it helps. What is the CAGR from 1.2 million to 2.1 million "
    "over 3 years?"
)
REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ENV_FILE = REPO_ROOT / ".env.agentscope"


def _env(name: str) -> str | None:
    value = os.getenv(name)
    if value is None:
        return None
    value = value.strip()
    return value or None


def _strip_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def _load_env_file(env_file: Path) -> None:
    if not env_file.exists():
        return

    for raw_line in env_file.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        if not key:
            continue
        os.environ.setdefault(key, _strip_quotes(value.strip()))


def _make_openai() -> dict[str, Any] | None:
    api_key = _env("OPENAI_API_KEY")
    if not api_key:
        return None

    model_name = _env("AGENTSCOPE_MODEL") or _env("OPENAI_MODEL") or "gpt-4.1-mini"
    base_url = _env("AGENTSCOPE_BASE_URL") or _env("OPENAI_BASE_URL") or _env("OPENAI_API_BASE")
    client_kwargs = {"base_url": base_url} if base_url else None

    return {
        "provider": "openai",
        "label": "OpenAI",
        "model_name": model_name,
        "model": OpenAIChatModel(
            model_name=model_name,
            api_key=api_key,
            client_kwargs=client_kwargs,
        ),
        "formatter": OpenAIChatFormatter(),
    }


def _make_openrouter() -> dict[str, Any] | None:
    api_key = _env("OPENROUTER_API_KEY")
    if not api_key:
        return None

    model_name = (
        _env("AGENTSCOPE_MODEL")
        or _env("OPENROUTER_MODEL")
        or "openai/gpt-4.1-mini"
    )
    client_kwargs: dict[str, Any] = {
        "base_url": _env("OPENROUTER_BASE_URL") or "https://openrouter.ai/api/v1",
    }

    headers: dict[str, str] = {}
    http_referer = _env("OPENROUTER_HTTP_REFERER")
    app_name = _env("OPENROUTER_APP_NAME")
    if http_referer:
        headers["HTTP-Referer"] = http_referer
    if app_name:
        headers["X-Title"] = app_name
    if headers:
        client_kwargs["default_headers"] = headers

    return {
        "provider": "openrouter",
        "label": "OpenRouter (OpenAI-compatible)",
        "model_name": model_name,
        "model": OpenAIChatModel(
            model_name=model_name,
            api_key=api_key,
            client_kwargs=client_kwargs,
        ),
        "formatter": OpenAIChatFormatter(),
    }


def _make_anthropic() -> dict[str, Any] | None:
    api_key = _env("ANTHROPIC_API_KEY")
    if not api_key:
        return None

    model_name = (
        _env("AGENTSCOPE_MODEL")
        or _env("ANTHROPIC_MODEL")
        or "claude-3-5-sonnet-latest"
    )
    return {
        "provider": "anthropic",
        "label": "Anthropic",
        "model_name": model_name,
        "model": AnthropicChatModel(model_name=model_name, api_key=api_key),
        "formatter": AnthropicChatFormatter(),
    }


def _make_gemini() -> dict[str, Any] | None:
    api_key = _env("GEMINI_API_KEY") or _env("GOOGLE_API_KEY")
    if not api_key:
        return None

    model_name = _env("AGENTSCOPE_MODEL") or _env("GEMINI_MODEL") or "gemini-2.0-flash"
    return {
        "provider": "gemini",
        "label": "Gemini",
        "model_name": model_name,
        "model": GeminiChatModel(model_name=model_name, api_key=api_key),
        "formatter": GeminiChatFormatter(),
    }


def _make_dashscope() -> dict[str, Any] | None:
    api_key = _env("DASHSCOPE_API_KEY")
    if not api_key:
        return None

    model_name = _env("AGENTSCOPE_MODEL") or _env("DASHSCOPE_MODEL") or "qwen-plus"
    return {
        "provider": "dashscope",
        "label": "DashScope",
        "model_name": model_name,
        "model": DashScopeChatModel(model_name=model_name, api_key=api_key),
        "formatter": DashScopeChatFormatter(),
    }


PROVIDER_FACTORIES = {
    "openai": _make_openai,
    "openrouter": _make_openrouter,
    "anthropic": _make_anthropic,
    "gemini": _make_gemini,
    "dashscope": _make_dashscope,
}

DEFAULT_PROVIDER_ORDER = (
    "openai",
    "openrouter",
    "anthropic",
    "gemini",
    "dashscope",
)


def _pick_provider(preferred: str | None) -> dict[str, Any]:
    if preferred:
        factory = PROVIDER_FACTORIES.get(preferred)
        if factory is None:
            raise SystemExit(
                f"Unsupported provider '{preferred}'. "
                f"Choose one of: {', '.join(PROVIDER_FACTORIES)}."
            )
        config = factory()
        if config is None:
            raise SystemExit(
                f"Provider '{preferred}' was selected, but its credentials were not found in the environment."
            )
        return config

    for provider in DEFAULT_PROVIDER_ORDER:
        config = PROVIDER_FACTORIES[provider]()
        if config is not None:
            return config

    raise SystemExit(
        "No supported provider credentials found. Set one of: "
        "OPENAI_API_KEY, OPENROUTER_API_KEY, ANTHROPIC_API_KEY, "
        "GEMINI_API_KEY, GOOGLE_API_KEY, DASHSCOPE_API_KEY."
    )


def _build_agent(model: Any, formatter: Any, max_iters: int) -> ReActAgent:
    toolkit = Toolkit(
        agent_skill_instruction=(
            "Use the Python tool when a calculation or quick structured "
            "transformation would improve accuracy."
        ),
    )
    toolkit.register_tool_function(execute_python_code)

    return ReActAgent(
        name="assistant",
        sys_prompt=(
            "You are a concise, practical assistant. "
            "Use tools when they improve the answer."
        ),
        model=model,
        formatter=formatter,
        toolkit=toolkit,
        max_iters=max_iters,
    )


async def _run_agent(prompt: str, config: dict[str, Any], max_iters: int) -> str:
    agentscope.init(project="agentscope-quickstart", name=f"{config['provider']}-cli")
    agent = _build_agent(
        model=config["model"],
        formatter=config["formatter"],
        max_iters=max_iters,
    )
    response = await agent(Msg(name="user", content=prompt, role="user"))
    return response.content


def _format_runtime_error(exc: Exception, provider: str) -> str:
    if RateLimitError and isinstance(exc, RateLimitError):
        return (
            f"{provider} request failed because the account has no available quota "
            "or has hit a rate limit. Check billing, project quota, and model access."
        )
    if AuthenticationError and isinstance(exc, AuthenticationError):
        return (
            f"{provider} rejected the credentials. Rotate the key if needed and verify "
            "that the provider env vars point to the right account and endpoint."
        )
    if APIConnectionError and isinstance(exc, APIConnectionError):
        return (
            f"{provider} could not be reached. Check network access, firewall rules, "
            "or any custom base URL configuration."
        )
    if APIStatusError and isinstance(exc, APIStatusError):
        status_code = getattr(exc, "status_code", "unknown")
        return f"{provider} returned API status {status_code}: {exc}"
    return f"{provider} request failed: {exc.__class__.__name__}: {exc}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "prompt",
        nargs="*",
        help="Prompt to send to the agent. Defaults to a short math task.",
    )
    parser.add_argument(
        "--provider",
        choices=tuple(PROVIDER_FACTORIES),
        help="Force a specific provider instead of auto-detecting from env vars.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Only print the detected provider config without calling the model.",
    )
    parser.add_argument(
        "--max-iters",
        type=int,
        default=6,
        help="Maximum ReAct iterations before the agent stops.",
    )
    parser.add_argument(
        "--env-file",
        default=str(DEFAULT_ENV_FILE),
        help="Optional env file to load before provider auto-detection.",
    )
    args = parser.parse_args()

    if args.env_file:
        _load_env_file(Path(args.env_file).expanduser())

    config = _pick_provider(args.provider or _env("AGENTSCOPE_PROVIDER"))

    if args.dry_run:
        print(
            json.dumps(
                {
                    "provider": config["provider"],
                    "label": config["label"],
                    "model_name": config["model_name"],
                },
                indent=2,
            )
        )
        return 0

    user_prompt = " ".join(args.prompt).strip() or DEFAULT_PROMPT

    try:
        response_text = asyncio.run(
            _run_agent(
                prompt=user_prompt,
                config=config,
                max_iters=args.max_iters,
            ),
        )
    except Exception as exc:
        print(_format_runtime_error(exc, config["label"]), file=sys.stderr)
        return 1
    print(response_text)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("Interrupted.", file=sys.stderr)
        raise SystemExit(130)
