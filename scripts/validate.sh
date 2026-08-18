#!/usr/bin/env bash
#
# Validates the plugin against the Agent Plugins 1.0.0 specification:
# the two manifests against their published JSON schemas, and the skills
# directory against the discovery rules (immediate subdirectories with a
# SKILL.md carrying a name that matches the directory).
#
# Requires: python3, and one of uvx or pipx to run check-jsonschema.

set -euo pipefail

cd "$(dirname "$0")/.."

SPEC_VERSION="1.0.0"
SCHEMA_BASE="https://agent-plugins.org/schemas/${SPEC_VERSION}"

if command -v uvx >/dev/null 2>&1; then
  runner=(uvx --quiet)
elif command -v pipx >/dev/null 2>&1; then
  runner=(pipx run)
else
  echo "error: neither uvx nor pipx is available to run check-jsonschema" >&2
  exit 1
fi

echo "==> Validating plugin.json"
"${runner[@]}" check-jsonschema --schemafile "${SCHEMA_BASE}/plugin.schema.json" plugin.json

echo "==> Validating mcp.json"
"${runner[@]}" check-jsonschema --schemafile "${SCHEMA_BASE}/mcp.schema.json" mcp.json

echo "==> Validating skills/"
python3 - <<'PY'
import pathlib
import re
import sys

root = pathlib.Path("skills")
errors = []

directories = sorted(p for p in root.iterdir() if p.is_dir())
if not directories:
    errors.append("skills/ has no skill directories")

for directory in directories:
    skill = directory / "SKILL.md"
    if not skill.is_file():
        errors.append(f"{directory}/ has no SKILL.md")
        continue

    content = skill.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not match:
        errors.append(f"{skill} has no YAML frontmatter")
        continue

    frontmatter = match.group(1)
    fields = dict(
        re.findall(r"^([A-Za-z0-9_-]+):[ \t]*(.*)$", frontmatter, re.MULTILINE)
    )

    name = fields.get("name", "").strip()
    if not name:
        errors.append(f"{skill} is missing a name")
    elif name != directory.name:
        errors.append(f"{skill} declares name '{name}' but lives in '{directory.name}/'")

    if not fields.get("description", "").strip():
        errors.append(f"{skill} is missing a description")

for error in errors:
    print(f"error: {error}", file=sys.stderr)

if errors:
    sys.exit(1)

print(f"ok -- {len(directories)} skills")
PY
