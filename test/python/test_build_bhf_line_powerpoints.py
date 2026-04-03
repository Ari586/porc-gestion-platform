from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

import build_bhf_line_powerpoints as subject


class BuildBhfLinePowerpointsTest(unittest.TestCase):
    def test_extract_atomic_topics_for_bhf_1b_to_3b(self):
        lines = subject.read_doc_lines(Path("/Users/arielhavana/Desktop/ÜBERSICHT ALLER THEMEN.docx"))
        topics = subject.extract_atomic_topics(lines, {"1B", "2", "3A", "3B"})

        self.assertEqual(len(topics), 90)
        self.assertEqual(topics[0]["section_title"], "Kommunikation und Kontaktaufnahme")
        self.assertEqual(topics[0]["topic_title"], "Grundlagen der verbalen und nonverbalen Kommunikation")
        self.assertEqual(topics[-1]["section_title"], "Hygiene vertiefen")
        self.assertEqual(topics[-1]["topic_title"], "Hygieneplan und Desinfektionsmaßnahmen")

    def test_infer_topic_kind_marks_disease_like_lines(self):
        self.assertEqual(subject.infer_topic_kind("Harninkontinenz: Formen, Ursachen, Assessmentinstrumente", "Ausscheidung und Kontinenz"), "disease")
        self.assertEqual(subject.infer_topic_kind("Grundlagen der verbalen und nonverbalen Kommunikation", "Kommunikation und Kontaktaufnahme"), "generic")


if __name__ == "__main__":
    unittest.main()
