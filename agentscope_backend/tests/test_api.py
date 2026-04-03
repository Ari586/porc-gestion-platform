import tempfile
import unittest
from pathlib import Path
import sys

from starlette.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
  sys.path.insert(0, str(ROOT))

from tantsahaup_backend.app import create_app
from tantsahaup_backend.store import JsonPostStore


class FakeAssistantService:
  async def ask(self, message: str, context_summary: str = "") -> str:
    return f"assistant:{message}"


class BackendApiTests(unittest.TestCase):
  def setUp(self) -> None:
    self._tmpdir = tempfile.TemporaryDirectory()
    data_file = Path(self._tmpdir.name) / "state.json"
    store = JsonPostStore(data_file)
    app = create_app(store=store, assistant_service=FakeAssistantService())
    self.client = TestClient(app)

  def tearDown(self) -> None:
    self._tmpdir.cleanup()

  def test_health_endpoint(self) -> None:
    response = self.client.get("/health")
    self.assertEqual(response.status_code, 200)
    payload = response.json()
    self.assertTrue(payload["ok"])
    self.assertEqual(payload["service"], "tantsahaup-agentscope-backend")

  def test_feed_returns_seed_posts(self) -> None:
    response = self.client.get("/api/feed")
    self.assertEqual(response.status_code, 200)
    payload = response.json()
    self.assertGreaterEqual(len(payload["posts"]), 1)
    self.assertIn("content", payload["posts"][0])

  def test_create_post_persists_to_feed(self) -> None:
    create_response = self.client.post(
      "/api/posts",
      json={
        "author_name": "rindra kattie",
        "author_initials": "RK",
        "content": "Bonjour TantsahaUp #vokatra",
        "type": "photo",
      },
    )
    self.assertEqual(create_response.status_code, 201)

    feed_response = self.client.get("/api/feed")
    payload = feed_response.json()
    self.assertEqual(payload["posts"][0]["content"], "Bonjour TantsahaUp #vokatra")

  def test_reacting_to_post_updates_counts(self) -> None:
    feed_response = self.client.get("/api/feed")
    post_id = feed_response.json()["posts"][0]["id"]

    like_response = self.client.post(f"/api/posts/{post_id}/like")
    self.assertEqual(like_response.status_code, 200)
    liked_post = like_response.json()["post"]
    self.assertTrue(liked_post["is_liked"])
    self.assertGreaterEqual(liked_post["like_count"], 1)

    comment_response = self.client.post(f"/api/posts/{post_id}/comment")
    self.assertEqual(comment_response.status_code, 200)
    self.assertGreaterEqual(comment_response.json()["post"]["comment_count"], 1)

    share_response = self.client.post(f"/api/posts/{post_id}/share")
    self.assertEqual(share_response.status_code, 200)
    self.assertGreaterEqual(share_response.json()["post"]["share_count"], 1)

  def test_trends_endpoint_aggregates_hashtags(self) -> None:
    self.client.post(
      "/api/posts",
      json={
        "author_name": "rindra kattie",
        "author_initials": "RK",
        "content": "Premier post #radar #radar #market",
        "type": "debate",
      },
    )

    response = self.client.get("/api/trends")
    self.assertEqual(response.status_code, 200)
    trends = response.json()["trends"]
    self.assertTrue(any(item["tag"] == "#radar" for item in trends))

  def test_assistant_chat_uses_injected_agent_service(self) -> None:
    response = self.client.post(
      "/api/assistant/chat",
      json={"message": "Quels modules sont populaires ?"},
    )
    self.assertEqual(response.status_code, 200)
    self.assertEqual(
      response.json()["reply"],
      "assistant:Quels modules sont populaires ?",
    )

  def test_assistant_chat_returns_503_without_agent_config(self) -> None:
    data_file = Path(self._tmpdir.name) / "state-no-agent.json"
    app = create_app(store=JsonPostStore(data_file))
    client = TestClient(app)

    response = client.post(
      "/api/assistant/chat",
      json={"message": "Bonjour ?"},
    )

    self.assertEqual(response.status_code, 503)
    self.assertEqual(response.json()["error"], "assistant_unavailable")


if __name__ == "__main__":
  unittest.main()
