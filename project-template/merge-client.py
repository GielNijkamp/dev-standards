"""Adds the client part of project-template to a scaffolded repo.

Usage: python3 merge-client.py <template/client> <target repo>

- Files are copied as they are.
- X.client.md is merged into X.md. In CLAUDE.md it goes just above "## Project-specific";
  elsewhere it is appended.
"""

import shutil
import sys
from pathlib import Path

src, dst = Path(sys.argv[1]), Path(sys.argv[2])

for f in sorted(p for p in src.rglob("*") if p.is_file()):
    rel = f.relative_to(src)
    if f.name.endswith(".client.md"):
        base = dst / rel.with_name(f.name.replace(".client.md", ".md"))
        add = f.read_text().strip("\n")
        text = base.read_text().rstrip("\n")
        marker = "\n## Project-specific"
        if base.name == "CLAUDE.md" and marker in text:
            head, tail = text.split(marker, 1)
            text = head.rstrip("\n") + "\n\n" + add + "\n" + marker + tail
        else:
            sep = "\n" if add.startswith("- ") else "\n\n"
            text = text + sep + add
        base.write_text(text + "\n")
    else:
        (dst / rel).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(f, dst / rel)
