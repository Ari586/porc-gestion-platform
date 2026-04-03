from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class CreatePostRequest(BaseModel):
  author_name: str = Field(min_length=1, max_length=120)
  author_initials: str = Field(min_length=1, max_length=4)
  content: str = Field(min_length=1, max_length=4000)
  type: Literal["photo", "video", "humour", "debate"] = "photo"
  image_base64: str | None = None


class AssistantChatRequest(BaseModel):
  message: str = Field(min_length=1, max_length=4000)


class PostRecord(BaseModel):
  id: str
  author_name: str
  author_initials: str
  content: str
  created_at: datetime
  type: Literal["photo", "video", "humour", "debate"]
  like_count: int = 0
  comment_count: int = 0
  share_count: int = 0
  is_liked: bool = False
  image_base64: str | None = None


class TrendRecord(BaseModel):
  tag: str
  count: int
