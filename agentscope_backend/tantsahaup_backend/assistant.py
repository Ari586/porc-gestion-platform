from __future__ import annotations

import os

import agentscope
from agentscope.agent import ReActAgent
from agentscope.formatter import OpenAIChatFormatter
from agentscope.message import Msg
from agentscope.model import OpenAIChatModel


class AgentScopeConfigurationError(RuntimeError):
  """Raised when the AgentScope backend lacks model credentials."""


class AgentScopeAssistantService:
  def __init__(self) -> None:
    self._model = self._build_model()
    agentscope.init(project="tantsahaup-backend", name="agentscope-assistant")

  async def ask(self, message: str, context_summary: str = "") -> str:
    prompt = (
      "You are the TantsahaUp AI assistant. Help with local community, market, "
      "social, and neighborhood questions. Keep answers concise and practical.\n\n"
      f"Current app context:\n{context_summary}\n\n"
      f"User question: {message}"
    )
    agent = ReActAgent(
      name="tantsahaup-assistant",
      sys_prompt=(
        "You are a friendly community assistant for TantsahaUp. "
        "Answer in French unless the user clearly uses another language."
      ),
      model=self._model,
      formatter=OpenAIChatFormatter(),
      max_iters=4,
    )
    response = await agent(Msg(name="user", content=prompt, role="user"))
    return str(response.content)

  def _build_model(self) -> OpenAIChatModel:
    openai_key = os.getenv("OPENAI_API_KEY", "").strip()
    openrouter_key = os.getenv("OPENROUTER_API_KEY", "").strip()
    model_name = os.getenv("AGENTSCOPE_MODEL", "").strip()

    if openai_key:
      return OpenAIChatModel(
        model_name=model_name or os.getenv("OPENAI_MODEL", "gpt-4.1-mini"),
        api_key=openai_key,
        client_kwargs=self._openai_client_kwargs(),
      )

    if openrouter_key:
      return OpenAIChatModel(
        model_name=model_name or os.getenv("OPENROUTER_MODEL", "openai/gpt-4.1-mini"),
        api_key=openrouter_key,
        client_kwargs=self._openrouter_client_kwargs(),
      )

    raise AgentScopeConfigurationError(
      "Set OPENAI_API_KEY or OPENROUTER_API_KEY for the AgentScope assistant backend.",
    )

  def _openai_client_kwargs(self) -> dict | None:
    base_url = os.getenv("OPENAI_BASE_URL", "").strip() or os.getenv(
      "AGENTSCOPE_BASE_URL",
      "",
    ).strip()
    return {"base_url": base_url} if base_url else None

  def _openrouter_client_kwargs(self) -> dict:
    headers: dict[str, str] = {}
    if referer := os.getenv("OPENROUTER_HTTP_REFERER", "").strip():
      headers["HTTP-Referer"] = referer
    if title := os.getenv("OPENROUTER_APP_NAME", "").strip():
      headers["X-Title"] = title

    payload = {
      "base_url": os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1"),
    }
    if headers:
      payload["default_headers"] = headers
    return payload
