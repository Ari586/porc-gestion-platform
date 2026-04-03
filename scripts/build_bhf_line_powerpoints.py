from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

import build_docx_theme_powerpoints as base


DEFAULT_DOCX = Path("/Users/arielhavana/Desktop/ÜBERSICHT ALLER THEMEN.docx")
DEFAULT_OUT_DIR = Path("/Users/arielhavana/antigr/porc/mockups/uebersicht_aller_themen_bhf_1b_bis_3b")
DEFAULT_BHFS = ("1B", "2", "3A", "3B")
LEARNING_MARKERS = {
    "Ich lerne etwas über:",
    "Ich festige mein Wissen über:",
    "Ich denke nach über:",
    "Ich reflektiere:",
    "Ich vertiefe meine Kenntnisse über:",
}
SECTION_TITLES_BY_BHF = {
    "1B": [
        "Kommunikation und Kontaktaufnahme",
        "Beziehungsgestaltung in der Pflege",
        "Familie und soziales Umfeld",
        "Reflexion des ersten Praxiseinsatzes",
        "Grundlagen des Pflegeberufs",
    ],
    "2": [
        "Gesundheit und Krankheit als Konzepte",
        "Wahrnehmung und Beobachtung in der Pflege",
        "Grundlagen der Anatomie und Physiologie",
        "Pflegetheorien und Pflegemodelle",
        "Grundlagen des Pflegeprozesses",
    ],
    "3A": [
        "Grundlagen des hygienischen Handelns",
        "Im Pflegealltag des Einsatzbereiches mitwirken",
        "Berührung – Interaktion bei der körpernahen Versorgung",
        "Recht und Pflegeethik",
        "Erste Grundlagen der Ernährung und Ausscheidung",
        "Körperpflege unterstützen – Wohlbefinden und Gesundheit fördern",
        "Haut und Hautzustände",
    ],
    "3B": [
        "Ernährungsmanagement",
        "Ausscheidung und Kontinenz",
        "Beobachtung und Assessment",
        "Kulturelle und religiöse Vielfalt in der Pflege",
        "Familie und Angehörige einbeziehen",
        "Hygiene vertiefen",
    ],
}

BHF_RE = re.compile(r"^BHF\s+([0-9]+[A-Z]?)\b")


def read_doc_lines(docx_path: Path) -> list[str]:
    doc = {"id": "UEBERSICHT", "path": docx_path}
    return base.clean_lines(base.read_doc_text(doc))


def normalize_bhf_ids(raw_ids: list[str] | tuple[str, ...]) -> set[str]:
    normalized: set[str] = set()
    for raw_id in raw_ids:
        normalized.add(base.fold_ascii(raw_id).upper().replace(" ", ""))
    return normalized


def bhf_id_from_heading(line: str) -> str | None:
    match = BHF_RE.match(base.fold_ascii(line).upper())
    if not match:
        return None
    return match.group(1)


def extract_atomic_topics(lines: list[str], target_bhfs: set[str]) -> list[dict]:
    entries: list[dict] = []
    bhf_boundaries: list[tuple[str, str, int, int]] = []
    for index, line in enumerate(lines):
        matched_bhf = bhf_id_from_heading(line)
        if matched_bhf:
            bhf_boundaries.append((matched_bhf, line, index, len(lines)))
    for idx, (bhf_id, bhf_heading, start, _) in enumerate(bhf_boundaries):
        end = bhf_boundaries[idx + 1][2] if idx + 1 < len(bhf_boundaries) else len(lines)
        if bhf_id not in target_bhfs:
            continue
        section_titles = SECTION_TITLES_BY_BHF.get(bhf_id, [])
        if not section_titles:
            continue

        section_starts: list[tuple[str, int]] = []
        search_start = start + 1
        for section_title in section_titles:
            match_index = base.find_match_index(lines, section_title, search_start)
            if match_index is None or match_index >= end:
                match_index = base.find_match_index(lines, section_title, start + 1)
            if match_index is None or match_index >= end:
                continue
            section_starts.append((section_title, match_index))
            search_start = match_index + 1

        for section_no, (section_title, section_start) in enumerate(section_starts, start=1):
            next_start = end
            for _, candidate_start in section_starts[section_no:]:
                if candidate_start > section_start:
                    next_start = candidate_start
                    break
            block = lines[section_start + 1 : next_start]
            block_points = [
                base.clean_space(line)
                for line in block
                if base.clean_space(line)
                and base.clean_space(line) not in LEARNING_MARKERS
                and not bhf_id_from_heading(base.clean_space(line))
            ]
            block_points = base.dedupe_keep_order(block_points)
            for topic_no, topic in enumerate(block_points, start=1):
                entries.append(
                    {
                        "bhf_id": bhf_id,
                        "bhf_heading": bhf_heading,
                        "section_no": section_no,
                        "section_title": section_title,
                        "topic_no": topic_no,
                        "topic_title": topic,
                        "block_points": block_points,
                    }
                )

    return entries


def infer_topic_kind(title: str, section_title: str) -> str:
    folded = base.fold_ascii(f"{title} {section_title}").lower()
    disease_signals = [
        "krankheitsbild",
        "mykose",
        "intertrigo",
        "dekubitus",
        "mangelernahrung",
        "harninkontinenz",
        "stuhlinkontinenz",
        "obstipation",
        "arthrose",
        "demenz",
        "depression",
        "asthma",
        "copd",
        "schlaganfall",
        "sepsis",
        "hiv",
        "hepatitis",
        "pneumonie",
    ]
    detail_signals = ["ursache", "ursachen", "risiko", "risikofaktoren", "symptome", "therapie", "verlauf", "diagnostik"]
    if any(signal in folded for signal in disease_signals):
        return "disease"
    if ":" in title and any(signal in folded for signal in detail_signals):
        return "disease"
    return "generic"


def build_payload(entry: dict, deck_index: int) -> dict:
    kind = infer_topic_kind(entry["topic_title"], entry["section_title"])
    accent, accent_dark = base.accent_for_index(deck_index)
    safe_title = base.trim_line(entry["topic_title"], 92)
    filename = (
        f"BHF_{entry['bhf_id']}_"
        f"{entry['section_no']:02d}_{entry['topic_no']:02d}_"
        f"{base.slugify(entry['topic_title'])}.pptx"
    )
    focus_lines = [
        f"Themenblock: {entry['section_title']}",
        f"Diese einzelne Zeile ist dein Lernfokus: {base.trim_line(entry['topic_title'], 84)}",
        f"Ordne sie im Kontext der restlichen Punkte aus {entry['bhf_heading'].split('–')[0].strip()} ein.",
    ]
    return {
        "kind": kind,
        "bhf_id": entry["bhf_id"],
        "bhf_heading": entry["bhf_heading"],
        "section_title": entry["section_title"],
        "topic_title": safe_title,
        "topic_full": entry["topic_title"],
        "block_points": entry["block_points"],
        "accent": accent,
        "accent_dark": accent_dark,
        "filename": filename,
        "focus_lines": focus_lines,
    }


def add_title_slide(prs, payload: dict, no: int, total: int) -> None:
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    base.add_background(slide, payload["accent"], payload["accent_dark"])
    panel = slide.shapes.add_shape(base.MSO_AUTO_SHAPE_TYPE.ROUNDED_RECTANGLE, base.Inches(0.62), base.Inches(0.86), base.Inches(6.2), base.Inches(5.85))
    base.set_fill(panel, payload["accent"])
    base.set_line(panel, payload["accent"], 0.8)
    base.add_box(slide, 0.96, 1.02, 2.9, 0.26, f"BHF {payload['bhf_id']}", 13, base.WHITE, True)
    base.add_box(slide, 0.96, 1.42, 5.4, 1.78, payload["topic_title"], 23, base.WHITE, True, font_name="Aptos Display")
    base.add_lines(slide, 0.96, 3.36, 5.35, 1.18, [payload["section_title"]], 16, base.rgb("E7F3FA"))
    base.add_card(
        slide,
        7.15,
        1.0,
        5.32,
        1.62,
        "Was ist dieses Deck?",
        [
            "ein Deck pro Zeile aus dem DOCX",
            "der Themenblock bleibt sichtbar als Kontext",
            "Krankheitsbilder bekommen ein DURST-Schema",
        ],
        base.TONES["sky"],
        payload["accent_dark"],
    )
    base.add_card(
        slide,
        7.15,
        2.92,
        5.32,
        1.84,
        "Lernweg",
        [
            "1. Zeile sauber definieren",
            "2. im Block einordnen",
            "3. frei in eigenen Worten wiedergeben",
        ],
        base.TONES["sand"],
        payload["accent_dark"],
    )
    base.add_card(
        slide,
        7.15,
        5.08,
        5.32,
        0.98,
        "Quelle",
        ["direkt aus ÜBERSICHT ALLER THEMEN.docx"],
        base.TONES["mint"],
        payload["accent_dark"],
    )
    base.add_footer(slide, "Line-by-line PowerPoint aus dem uebergebenen Word-Dokument", no, total, payload["accent"])


def add_context_slide(prs, payload: dict, no: int, total: int) -> None:
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    base.add_background(slide, payload["accent"], payload["accent_dark"])
    base.add_box(slide, 0.72, 0.92, 10.5, 0.42, "Dokumentkontext", 23, base.INK, True, font_name="Aptos Display")
    base.add_card(
        slide,
        0.72,
        1.7,
        5.78,
        1.38,
        "Fokuszeile",
        [payload["topic_full"]],
        base.TONES["white"],
        payload["accent_dark"],
        body_size=16,
    )
    base.add_card(
        slide,
        6.78,
        1.7,
        5.85,
        1.38,
        "Themenblock",
        [payload["section_title"]],
        base.TONES["sky"],
        payload["accent_dark"],
        body_size=16,
    )
    block_lines = []
    for point in payload["block_points"]:
        prefix = "• "
        if point == payload["topic_full"]:
            prefix = "• Schwerpunkt: "
        block_lines.append(f"{prefix}{base.trim_line(point, 94)}")
    base.add_card(
        slide,
        0.72,
        3.42,
        11.91,
        2.92,
        "Weitere Punkte aus demselben Block",
        block_lines[:9],
        base.TONES["white"],
        payload["accent_dark"],
        body_size=15,
    )
    base.add_footer(slide, "Die Nachbarpunkte helfen dir, das Thema im Gesamtblock sauber einzuordnen.", no, total, payload["accent"])


def add_durst_slide(prs, payload: dict, no: int, total: int) -> None:
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    base.add_background(slide, payload["accent"], payload["accent_dark"])
    base.add_box(slide, 0.72, 0.92, 10.5, 0.42, "DURST-Schema", 23, base.INK, True, font_name="Aptos Display")
    cards = [
        ("Definition", [f"Was ist '{payload['topic_full']}'?", "1-2 klare Saetze, ohne auszuschweifen"], base.TONES["sky"], 0.72, 1.72, 3.85, 1.7),
        ("Ursachen", ["Welche Ursachen oder Ausloeser gibt es?", "Wenn sinnvoll: akut vs. chronisch trennen"], base.TONES["mint"], 4.75, 1.72, 3.85, 1.7),
        ("Risikofaktoren", ["Wer ist besonders gefaehrdet?", "Alter, Vorerkrankungen, Verhalten, Setting"], base.TONES["sand"], 8.78, 1.72, 3.85, 1.7),
        ("Symptome", ["Leitsymptome, Warnzeichen, Beobachtung", "Worauf achtest du pflegerisch zuerst?"], base.TONES["rose"], 0.72, 3.82, 5.85, 1.82),
        ("Therapie", ["Medikamentoese Therapie", "Pflegerische Therapie / Massnahmen"], base.TONES["white"], 6.78, 3.82, 5.85, 1.82),
    ]
    for title, body_lines, tone, x, y, w, h in cards:
        base.add_card(slide, x, y, w, h, title, body_lines, tone, payload["accent_dark"], body_size=15)
    base.add_footer(slide, "Bei Krankheitsbildern immer in dieser Reihenfolge lernen: Definition -> Ursachen -> Risiken -> Symptome -> Therapie.", no, total, payload["accent"])


def add_generic_focus_slide(prs, payload: dict, no: int, total: int) -> None:
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    base.add_background(slide, payload["accent"], payload["accent_dark"])
    base.add_box(slide, 0.72, 0.92, 10.5, 0.42, "Lernfokus", 23, base.INK, True, font_name="Aptos Display")
    base.add_card(
        slide,
        0.72,
        1.72,
        3.85,
        1.7,
        "Erklaeren",
        [
            f"Was bedeutet '{payload['topic_full']}'?",
            "Erklaere es pflegerisch und alltagsnah.",
        ],
        base.TONES["sky"],
        payload["accent_dark"],
        body_size=15,
    )
    base.add_card(
        slide,
        4.75,
        1.72,
        3.85,
        1.7,
        "Praxis",
        [
            "Wie zeigt sich das im Pflegealltag?",
            "Welche Beobachtung oder Handlung passt dazu?",
        ],
        base.TONES["mint"],
        payload["accent_dark"],
        body_size=15,
    )
    base.add_card(
        slide,
        8.78,
        1.72,
        3.85,
        1.7,
        "Pruefung",
        [
            "2-3 Unterpunkte frei nennen koennen",
            "am besten direkt mit Beispiel",
        ],
        base.TONES["sand"],
        payload["accent_dark"],
        body_size=15,
    )
    base.add_card(slide, 0.72, 3.82, 11.91, 1.82, "Merksatz", payload["focus_lines"], base.TONES["rose"], payload["accent_dark"], body_size=16)
    base.add_footer(slide, "Nicht-Krankheitsbilder lernst du am besten ueber Bedeutung, Praxis und ein kleines Beispiel.", no, total, payload["accent"])


def build_deck(payload: dict, out_dir: Path) -> Path:
    prs = base.Presentation()
    prs.slide_width = base.Inches(13.333)
    prs.slide_height = base.Inches(7.5)
    prs.core_properties.title = payload["topic_full"]
    prs.core_properties.subject = payload["section_title"]
    prs.core_properties.author = "Codex"
    total = 3
    add_title_slide(prs, payload, 1, total)
    add_context_slide(prs, payload, 2, total)
    if payload["kind"] == "disease":
        add_durst_slide(prs, payload, 3, total)
    else:
        add_generic_focus_slide(prs, payload, 3, total)
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / payload["filename"]
    prs.save(str(path))
    return path


def build_zip_archive(out_dir: Path, zip_path: Path) -> None:
    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as archive:
        for file_path in sorted(out_dir.glob("*.pptx")):
            archive.write(file_path, arcname=file_path.name)
        manifest_path = out_dir / "manifest.json"
        if manifest_path.exists():
            archive.write(manifest_path, arcname=manifest_path.name)


def build_all(docx_path: Path, out_dir: Path, bhf_ids: list[str] | tuple[str, ...]) -> list[dict]:
    target_bhfs = normalize_bhf_ids(bhf_ids)
    entries = extract_atomic_topics(read_doc_lines(docx_path), target_bhfs)
    manifest: list[dict] = []
    for deck_index, entry in enumerate(entries):
        payload = build_payload(entry, deck_index)
        deck_path = build_deck(payload, out_dir)
        manifest.append(
            {
                "bhf_id": entry["bhf_id"],
                "bhf_heading": entry["bhf_heading"],
                "section_title": entry["section_title"],
                "topic_title": entry["topic_title"],
                "kind": payload["kind"],
                "deck": str(deck_path),
                "block_points": entry["block_points"],
            }
        )
        print(f"saved {deck_path}")
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = out_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"saved {manifest_path}")
    build_zip_archive(out_dir, out_dir.with_suffix(".zip"))
    print(f"saved {out_dir.with_suffix('.zip')}")
    return manifest


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build one PowerPoint per learning line from the overview DOCX.")
    parser.add_argument("--docx", type=Path, default=DEFAULT_DOCX)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--bhf", nargs="+", default=list(DEFAULT_BHFS))
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_all(args.docx, args.out_dir, args.bhf)


if __name__ == "__main__":
    main()
