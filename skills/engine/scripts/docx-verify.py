#!/usr/bin/env python3
"""
Verify tracked changes in a DOCX file (Python-only, no pandoc required).
Uses only stdlib + defusedxml. Auto-installs defusedxml if missing.

Usage: python3 docx-verify.py <path-to-docx>
Exit 0 = valid DOCX with summary printed.
Exit 1 = error (missing file, invalid DOCX, parse failure).
"""

import subprocess
import sys
import zipfile
from pathlib import Path

try:
    from defusedxml import ElementTree as ET
except ImportError:
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "--user", "--quiet", "defusedxml"]
    )
    from defusedxml import ElementTree as ET

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"


def extract_text(elem):
    """Extract visible text from a w:ins or w:del element."""
    parts = []
    for t in elem.iter(f"{{{W_NS}}}t"):
        if t.text:
            parts.append(t.text)
    for dt in elem.iter(f"{{{W_NS}}}delText"):
        if dt.text:
            parts.append(dt.text)
    return "".join(parts)


def verify_docx(path):
    docx = Path(path)
    if not docx.exists():
        print(f"Error: file not found: {docx}")
        return 1
    if not zipfile.is_zipfile(docx):
        print(f"Error: not a valid DOCX (ZIP) file: {docx}")
        return 1

    with zipfile.ZipFile(docx, "r") as zf:
        if "word/document.xml" not in zf.namelist():
            print("Error: word/document.xml not found in archive")
            return 1
        xml_bytes = zf.read("word/document.xml")

    root = ET.fromstring(xml_bytes)
    changes = []
    for tag, label in [(f"{{{W_NS}}}ins", "INSERT"), (f"{{{W_NS}}}del", "DELETE")]:
        for elem in root.iter(tag):
            author = elem.get(f"{{{W_NS}}}author", "unknown")
            text = extract_text(elem)
            snippet = (text[:60] + "...") if len(text) > 60 else text
            changes.append((label, author, snippet))

    print(f"File: {docx.name}")
    print(f"Tracked changes: {len(changes)}")
    if changes:
        print(f"  Insertions: {sum(1 for c in changes if c[0] == 'INSERT')}")
        print(f"  Deletions:  {sum(1 for c in changes if c[0] == 'DELETE')}")
        print()
        for kind, author, snippet in changes:
            print(f"  [{kind}] by {author}: {snippet!r}")
    else:
        print("  No tracked changes found.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file.docx>")
        sys.exit(1)
    sys.exit(verify_docx(sys.argv[1]))
