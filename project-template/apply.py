"""Brings an existing repo up to the project template, keeping its own content.

Usage: python3 apply.py <fresh scaffold dir> <repo dir> <skills.txt>

- Managed files are overwritten: the capture map, issue tracker doc, our skills, the CI check
  (client: also /capture-review and the change-request form).
- CODING_STANDARDS.md and the PR template get the Capture section if they lack one.
- Missing starter files are created: .env.example, CODING_STANDARDS.md, PR template
  (client: .capture/project.yaml).
- CLAUDE.md: the template's Agent skills / Capture / Client capture sections replace any old
  ones. They go above "## Project-specific". Every other section stays.
- Skills: mattpocock skills outside skills.txt are removed, plus Codex agents/openai.yaml files.
  Skills from other sources are left alone.
"""

import json
import re
import shutil
import sys
from pathlib import Path

scaffold, repo, skills_file = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
pipeline = {l.strip() for l in skills_file.read_text().splitlines() if l.strip() and not l.startswith("#")}
done = []

MANAGED = [
    "docs/agents/capture.md",
    "docs/agents/issue-tracker.md",
    ".claude/skills/capture/SKILL.md",
    ".github/workflows/capture-checks.yml",
    ".claude/skills/capture-review/SKILL.md",
    ".github/ISSUE_TEMPLATE/change-request.yml",
    ".capture/project.yaml",
]
CREATE_IF_MISSING = [".env.example", "CODING_STANDARDS.md", ".github/pull_request_template.md"]
REMOVE = ["docs/agents/domain.md", "docs/agents/triage-labels.md"]
CLAUDE_SECTIONS = {"Agent skills", "Capture", "Capture rules", "Client capture", "Client capture rules"}


def sections(text):
    """Split markdown into (heading or None, text) chunks on level-2 headings."""
    parts = re.split(r"(?m)^(?=## )", text)
    out = []
    for p in parts:
        m = re.match(r"## (.+)\n", p)
        out.append((m.group(1).strip() if m else None, p))
    return out


def capture_section(text):
    for head, body in sections(text):
        if head == "Capture":
            return body
    return None


for rel in MANAGED:
    src = scaffold / rel
    if not src.exists():
        continue
    dst = repo / rel
    if rel == ".capture/project.yaml" and dst.exists():
        continue  # project data, never overwrite
    if not dst.exists() or dst.read_text() != src.read_text():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        done.append(f"wrote {rel}")

for rel in CREATE_IF_MISSING:
    src, dst = scaffold / rel, repo / rel
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        done.append(f"created {rel}")
    elif rel != ".env.example" and capture_section(dst.read_text()) is None:
        dst.write_text(dst.read_text().rstrip("\n") + "\n\n" + capture_section(src.read_text()).rstrip("\n") + "\n")
        done.append(f"added Capture section to {rel}")

for rel in REMOVE:
    if (repo / rel).exists():
        (repo / rel).unlink()
        done.append(f"removed {rel} (now in CLAUDE.md)")

# CLAUDE.md: swap the managed sections, keep the rest.
claude = repo / "CLAUDE.md"
new = [b for h, b in sections((scaffold / "CLAUDE.md").read_text()) if h in CLAUDE_SECTIONS]
if claude.exists():
    kept = [(h, b) for h, b in sections(claude.read_text()) if h not in CLAUDE_SECTIONS]
    idx = next((i for i, (h, _) in enumerate(kept) if h == "Project-specific"), len(kept))
    chunks = [b.rstrip("\n") + "\n" for _, b in kept[:idx]] + [b.rstrip("\n") + "\n" for b in new] + [b.rstrip("\n") + "\n" for _, b in kept[idx:]]
    text = "\n".join(c for c in chunks if c.strip())
else:
    text = "\n".join(b.rstrip("\n") + "\n" for b in new)
if not claude.exists() or claude.read_text() != text:
    claude.write_text(text)
    done.append("updated CLAUDE.md sections: " + ", ".join(h for h, _ in sections("".join(new)) if h))

# Skills: trim to the pipeline set.
lock = repo / "skills-lock.json"
skills_dir = repo / ".claude/skills"
if lock.exists():
    data = json.loads(lock.read_text())
    for name, meta in list(data.get("skills", {}).items()):
        if meta.get("source") == "mattpocock/skills" and name not in pipeline:
            shutil.rmtree(skills_dir / name, ignore_errors=True)
            del data["skills"][name]
            done.append(f"removed skill {name}")
    lock.write_text(json.dumps(data, indent=2) + "\n")
if skills_dir.exists():
    codex = list(skills_dir.glob("*/agents/openai.yaml"))
    for f in codex:
        f.unlink()
        if not any(f.parent.iterdir()):
            f.parent.rmdir()
    if codex:
        done.append(f"removed {len(codex)} Codex agents/openai.yaml files")

print("\n".join(done) if done else "nothing to change")
