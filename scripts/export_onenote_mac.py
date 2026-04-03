from __future__ import annotations

import argparse
import json
import re
import sqlite3
import unicodedata
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


DEFAULT_DB_PATH = Path(
    "/Users/arielhavana/Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/"
    "Microsoft User Data/OneNote/15.0/FullTextSearchIndex/{F5FF1CE4-251B-4B4C-AC34-A9D31CD459EA}{30}.db"
)
DEFAULT_OUT_DIR = Path("/Users/arielhavana/antigr/porc/mockups/onenote_mac_export")
DEFAULT_NOTEBOOK = "GeP 23-10 S-Notizbuch"


@dataclass(frozen=True)
class Entity:
    rowid: int
    type: int
    title: str
    goid: str
    parent_goid: str | None


def slugify(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    normalized = normalized.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^A-Za-z0-9._-]+", "_", normalized).strip("._-")
    return slug or "untitled"


def clean_text(value: str) -> str:
    value = value.replace("\r", "\n")
    value = re.sub(r"\n{3,}", "\n\n", value)
    value = "\n".join(line.rstrip() for line in value.splitlines())
    return value.strip()


def is_probably_file_name(text: str) -> bool:
    lowered = text.lower().strip()
    return bool(re.search(r"\.(docx|pdf|pptx|xlsx|jpg|jpeg|png)$", lowered))


def dedupe_preserve_order(items: list[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for item in items:
        key = unicodedata.normalize("NFKD", item).encode("ascii", "ignore").decode("ascii").lower()
        key = re.sub(r"\s+", " ", key).strip(" -._,;:")
        if not key or key in seen:
            continue
        seen.add(key)
        result.append(item)
    return result


def fetch_entities(conn: sqlite3.Connection) -> dict[str, Entity]:
    rows = conn.execute(
        """
        select rowid, Type, coalesce(Title, '') as Title, GOID, ParentGOID
        from Entities
        order by rowid
        """
    ).fetchall()
    return {
        row["GOID"]: Entity(
            rowid=row["rowid"],
            type=row["Type"],
            title=(row["Title"] or "").strip(),
            goid=row["GOID"],
            parent_goid=row["ParentGOID"],
        )
        for row in rows
    }


def fetch_page_texts(conn: sqlite3.Connection) -> dict[int, list[str]]:
    rows = conn.execute(
        """
        select EntityRowId, Text
        from PageElements
        where Text is not null and trim(Text) != ''
        order by EntityRowId, rowid
        """
    ).fetchall()
    grouped: dict[int, list[str]] = defaultdict(list)
    for row in rows:
        text = clean_text(row["Text"])
        if text:
            grouped[row["EntityRowId"]].append(text)
    return grouped


def build_children(entities: dict[str, Entity]) -> dict[str, list[Entity]]:
    children: dict[str, list[Entity]] = defaultdict(list)
    for entity in entities.values():
        if entity.parent_goid:
            children[entity.parent_goid].append(entity)
    for bucket in children.values():
        bucket.sort(key=lambda item: (item.type, item.title.lower(), item.rowid))
    return children


def full_path(entity: Entity, entities: dict[str, Entity]) -> list[Entity]:
    chain: list[Entity] = [entity]
    current = entity
    while current.parent_goid and current.parent_goid in entities:
        current = entities[current.parent_goid]
        chain.append(current)
    chain.reverse()
    return chain


def is_bhf_related(entity: Entity, entities: dict[str, Entity]) -> bool:
    path_titles = " / ".join(part.title for part in full_path(entity, entities) if part.title)
    return bool(re.search(r"\bBHF\b", path_titles, flags=re.IGNORECASE))


def clean_page_blocks(title: str, blocks: list[str]) -> list[str]:
    cleaned: list[str] = []
    for block in blocks:
        block = clean_text(block)
        if not block:
            continue
        if block == title:
            continue
        if is_probably_file_name(block):
            continue
        cleaned.append(block)
    return dedupe_preserve_order(cleaned)


def ensure_unique_path(base_dir: Path, title: str, suffix: str = "") -> Path:
    stem = slugify(title)
    candidate = base_dir / f"{stem}{suffix}"
    index = 2
    while candidate.exists():
        candidate = base_dir / f"{stem}_{index}{suffix}"
        index += 1
    return candidate


def folder_readme(node: Entity, child_entities: list[Entity], page_blocks: list[str], path_titles: list[str]) -> str:
    lines = [
        f"# {node.title or 'Untitled'}",
        "",
        f"- OneNote type: `{node.type}`",
        f"- Hierarchie: `{' / '.join(path_titles)}`",
        f"- Kinder: `{len(child_entities)}`",
    ]
    if page_blocks:
        lines.extend(["", "## Inhalt", ""])
        for block in page_blocks:
            lines.append(block)
            lines.append("")
    if child_entities:
        lines.extend(["## Kinder", ""])
        for child in child_entities:
            marker = "/" if child.title and child_entities else ""
            lines.append(f"- {child.title or f'Untitled {child.rowid}'}")
    lines.append("")
    return "\n".join(lines)


def page_markdown(node: Entity, page_blocks: list[str], path_titles: list[str]) -> str:
    lines = [
        f"# {node.title or 'Untitled'}",
        "",
        f"- OneNote type: `{node.type}`",
        f"- Hierarchie: `{' / '.join(path_titles)}`",
        "",
    ]
    if page_blocks:
        for block in page_blocks:
            lines.append(block)
            lines.append("")
    else:
        lines.append("_Kein Text im lokalen Index gefunden._")
        lines.append("")
    return "\n".join(lines)


def export_tree(
    node: Entity,
    entities: dict[str, Entity],
    children: dict[str, list[Entity]],
    page_texts: dict[int, list[str]],
    parent_dir: Path,
    manifest: list[dict],
) -> None:
    node_children = children.get(node.goid, [])
    page_blocks = clean_page_blocks(node.title, page_texts.get(node.rowid, []))
    path_titles = [part.title or f"untitled-{part.rowid}" for part in full_path(node, entities)]

    if node_children:
        node_dir = ensure_unique_path(parent_dir, node.title or f"untitled_{node.rowid}")
        node_dir.mkdir(parents=True, exist_ok=True)
        readme_path = node_dir / "README.md"
        readme_path.write_text(folder_readme(node, node_children, page_blocks, path_titles), encoding="utf-8")
        manifest.append(
            {
                "title": node.title,
                "type": node.type,
                "path": str(readme_path),
                "hierarchy": path_titles,
                "child_count": len(node_children),
                "text_blocks": len(page_blocks),
            }
        )
        for child in node_children:
            export_tree(child, entities, children, page_texts, node_dir, manifest)
        return

    page_path = ensure_unique_path(parent_dir, node.title or f"untitled_{node.rowid}", ".md")
    page_path.write_text(page_markdown(node, page_blocks, path_titles), encoding="utf-8")
    manifest.append(
        {
            "title": node.title,
            "type": node.type,
            "path": str(page_path),
            "hierarchy": path_titles,
            "child_count": 0,
            "text_blocks": len(page_blocks),
        }
    )


def build_bhf_index(manifest: list[dict], out_dir: Path) -> None:
    grouped: dict[str, list[dict]] = defaultdict(list)
    for item in manifest:
        hierarchy = item["hierarchy"]
        bhf_name = next((part for part in hierarchy if re.search(r"\bBHF\s*\d+", part, re.IGNORECASE)), None)
        if bhf_name:
            grouped[bhf_name].append(item)

    json_path = out_dir / "bhf_index.json"
    md_path = out_dir / "bhf_index.md"
    ordered = dict(sorted(grouped.items(), key=lambda kv: kv[0]))
    json_path.write_text(json.dumps(ordered, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = ["# BHF Index", ""]
    for bhf_name, items in ordered.items():
        lines.append(f"## {bhf_name}")
        lines.append("")
        for item in items[:40]:
            rel = Path(item["path"]).relative_to(out_dir)
            title = item["title"] or Path(item["path"]).stem
            lines.append(f"- [{title}]({rel.as_posix()})")
        lines.append("")
    md_path.write_text("\n".join(lines), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Mac-side OneNote markdown exporter based on the local OneNote search index.")
    parser.add_argument("--db-path", type=Path, default=DEFAULT_DB_PATH)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--notebook-title", default=DEFAULT_NOTEBOOK)
    parser.add_argument("--bhf-only", action="store_true", help="Export only entities whose path contains 'BHF'.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(args.db_path)
    conn.row_factory = sqlite3.Row
    entities = fetch_entities(conn)
    page_texts = fetch_page_texts(conn)
    children = build_children(entities)

    notebook = next(
        (entity for entity in entities.values() if entity.type == 4 and entity.title == args.notebook_title),
        None,
    )
    if notebook is None:
        raise SystemExit(f"Notebook not found: {args.notebook_title}")

    root_export_dir = args.out_dir / slugify(notebook.title)
    root_export_dir.mkdir(parents=True, exist_ok=True)

    manifest: list[dict] = []
    top_level_children = children.get(notebook.goid, [])
    if args.bhf_only:
        filtered_children = [
            entity
            for entity in top_level_children
            if is_bhf_related(entity, entities) or any(is_bhf_related(child, entities) for child in children.get(entity.goid, []))
        ]
    else:
        filtered_children = top_level_children

    readme = [
        f"# {notebook.title}",
        "",
        f"- Export source: `{args.db_path}`",
        f"- Top-level nodes exported: `{len(filtered_children)}`",
        f"- Filter: `{'BHF only' if args.bhf_only else 'all nodes'}`",
        "",
        "## Children",
        "",
    ]
    for child in filtered_children:
        readme.append(f"- {child.title or f'Untitled {child.rowid}'}")
    readme.append("")
    (root_export_dir / "README.md").write_text("\n".join(readme), encoding="utf-8")

    for child in filtered_children:
        export_tree(child, entities, children, page_texts, root_export_dir, manifest)

    manifest_path = args.out_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    build_bhf_index(manifest, args.out_dir)

    print(f"exported {len(manifest)} items to {args.out_dir}")
    print(f"manifest: {manifest_path}")


if __name__ == "__main__":
    main()
