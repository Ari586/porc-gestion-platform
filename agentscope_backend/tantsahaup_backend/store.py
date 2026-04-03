from __future__ import annotations

import json
import re
import threading
from datetime import UTC, datetime, timedelta
from pathlib import Path

from .models import CreatePostRequest, PostRecord, TrendRecord


class JsonPostStore:
  def __init__(self, data_file: Path) -> None:
    self.data_file = data_file
    self.data_file.parent.mkdir(parents=True, exist_ok=True)
    self._lock = threading.Lock()
    if not self.data_file.exists():
      self._write_posts(self._seed_posts())

  def list_posts(self) -> list[PostRecord]:
    with self._lock:
      return self._read_posts()

  def create_post(self, payload: CreatePostRequest) -> PostRecord:
    with self._lock:
      posts = self._read_posts()
      post = PostRecord(
        id=f"post-{int(datetime.now(UTC).timestamp() * 1000000)}",
        author_name=payload.author_name,
        author_initials=payload.author_initials,
        content=payload.content,
        created_at=datetime.now(UTC),
        type=payload.type,
        image_base64=payload.image_base64,
      )
      posts.insert(0, post)
      self._write_posts(posts)
      return post

  def toggle_like(self, post_id: str) -> PostRecord:
    def mutate(post: PostRecord) -> PostRecord:
      next_liked = not post.is_liked
      like_count = post.like_count + 1 if next_liked else max(post.like_count - 1, 0)
      return post.model_copy(update={"is_liked": next_liked, "like_count": like_count})

    return self._update_post(post_id, mutate)

  def increment_comment(self, post_id: str) -> PostRecord:
    return self._update_post(
      post_id,
      lambda post: post.model_copy(
        update={"comment_count": post.comment_count + 1},
      ),
    )

  def increment_share(self, post_id: str) -> PostRecord:
    return self._update_post(
      post_id,
      lambda post: post.model_copy(update={"share_count": post.share_count + 1}),
    )

  def trends(self, limit: int = 5) -> list[TrendRecord]:
    counts: dict[str, int] = {}
    for post in self.list_posts():
      for match in re.finditer(r"#([A-Za-z0-9_]+)", post.content):
        tag = f"#{match.group(1)}"
        counts[tag] = counts.get(tag, 0) + 1
    trends = [TrendRecord(tag=tag, count=count) for tag, count in counts.items()]
    trends.sort(key=lambda item: (-item.count, item.tag))
    return trends[:limit]

  def build_context_summary(self, limit: int = 5) -> str:
    posts = self.list_posts()[:limit]
    trends = self.trends(limit=5)
    post_lines = [
      f"- {post.author_name}: {post.content} "
      f"(likes={post.like_count}, comments={post.comment_count}, shares={post.share_count})"
      for post in posts
    ]
    trend_lines = [f"- {trend.tag}: {trend.count}" for trend in trends]
    return "\n".join(
      [
        "Recent posts:",
        *post_lines,
        "",
        "Trending tags:",
        *trend_lines,
      ],
    ).strip()

  def _update_post(self, post_id: str, mutator) -> PostRecord:
    with self._lock:
      posts = self._read_posts()
      for index, post in enumerate(posts):
        if post.id != post_id:
          continue
        updated = mutator(post)
        posts[index] = updated
        self._write_posts(posts)
        return updated
    raise KeyError(post_id)

  def _read_posts(self) -> list[PostRecord]:
    if not self.data_file.exists():
      return self._seed_posts()
    payload = json.loads(self.data_file.read_text(encoding="utf-8"))
    posts = [PostRecord.model_validate(item) for item in payload.get("posts", [])]
    posts.sort(key=lambda item: item.created_at, reverse=True)
    return posts

  def _write_posts(self, posts: list[PostRecord]) -> None:
    payload = {"posts": [post.model_dump(mode="json") for post in posts]}
    self.data_file.write_text(json.dumps(payload, indent=2), encoding="utf-8")

  def _seed_posts(self) -> list[PostRecord]:
    return [
      PostRecord(
        id="seed-justin",
        author_name="Justin Be Riziky",
        author_initials="JR",
        content="😍😍😍😍 Chocolat #111 #tinnay",
        created_at=datetime.now(UTC) - timedelta(days=72),
        type="photo",
        like_count=24,
        comment_count=7,
        share_count=3,
      ),
      PostRecord(
        id="seed-miora",
        author_name="Miora Rabe",
        author_initials="MR",
        content="Alerte quartier ce soir a Ambanidia #se #radar",
        created_at=datetime.now(UTC) - timedelta(hours=19),
        type="debate",
        like_count=10,
        comment_count=5,
        share_count=2,
      ),
    ]
