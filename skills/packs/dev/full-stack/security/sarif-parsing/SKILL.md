---
name: sarif-parsing
description: >
  Parses and processes SARIF files from static analysis tools like CodeQL, Semgrep, or other
  scanners. Handles filtering, deduplication, format conversion, aggregation, and CI/CD
  integration of SARIF data. Does NOT run scans — use the Semgrep or CodeQL skills for that.
version: 0.2.0
layer: userland
category: security
triggers:
  - pattern: "parse sarif"
  - pattern: "read scan results"
  - pattern: "aggregate findings"
  - pattern: "deduplicate alerts"
  - pattern: "process sarif output"
dependencies:
  hard: []
  soft:
    - codeql
    - semgrep
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
metadata:
  author: trailofbits
  source: https://github.com/trailofbits/skills
license: MIT
---

# SARIF Parsing Best Practices

You are a SARIF parsing expert. Your role is to help users effectively read, analyze, and process SARIF files from static analysis tools.

## When to Use

Use this skill when:
- Reading or interpreting static analysis scan results in SARIF format
- Aggregating findings from multiple security tools
- Deduplicating or filtering security alerts
- Extracting specific vulnerabilities from SARIF files
- Integrating SARIF data into CI/CD pipelines
- Converting SARIF output to other formats

## When NOT to Use

Do NOT use this skill for:
- Running static analysis scans (use CodeQL or Semgrep skills instead)
- Writing CodeQL or Semgrep rules (use their respective skills)
- Analyzing source code directly (SARIF is for processing existing scan results)
- Triaging findings without SARIF input (use variant-analysis or audit skills)

## SARIF Structure Overview

SARIF 2.1.0 is the current OASIS standard. Every SARIF file has this hierarchical structure:

```
sarifLog
├── version: "2.1.0"
├── $schema: (optional, enables IDE validation)
└── runs[] (array of analysis runs)
    ├── tool
    │   ├── driver
    │   │   ├── name (required)
    │   │   ├── version
    │   │   └── rules[] (rule definitions)
    │   └── extensions[] (plugins)
    ├── results[] (findings)
    │   ├── ruleId
    │   ├── level (error/warning/note)
    │   ├── message.text
    │   ├── locations[]
    │   │   └── physicalLocation
    │   │       ├── artifactLocation.uri
    │   │       └── region (startLine, startColumn, etc.)
    │   ├── fingerprints{}
    │   └── partialFingerprints{}
    └── artifacts[] (scanned files metadata)
```

### Why Fingerprinting Matters

Without stable fingerprints, you cannot track findings across runs:

- **Baseline comparison**: "Is this a new finding or did we see it before?"
- **Regression detection**: "Did this PR introduce new vulnerabilities?"
- **Suppression**: "Ignore this known false positive in future runs"

Tools report different paths (`/path/to/project/` vs `/github/workspace/`), so path-based matching fails. Fingerprints hash the *content* (code snippet, rule ID, relative location) to create stable identifiers regardless of environment.

## Tool Selection Guide

| Use Case | Tool | Installation |
|----------|------|--------------|
| Quick CLI queries | jq | `brew install jq` / `apt install jq` |
| Python scripting (simple) | pysarif | `pip install pysarif` |
| Python scripting (advanced) | sarif-tools | `pip install sarif-tools` |
| .NET applications | SARIF SDK | NuGet package |
| JavaScript/Node.js | sarif-js | npm package |
| Go applications | garif | `go get github.com/chavacava/garif` |
| Validation | SARIF Validator | sarifweb.azurewebsites.net |

## Strategy 1: Quick Analysis with jq

For rapid exploration and one-off queries:

```bash
# Pretty print the file
jq '.' results.sarif

# Count total findings
jq '[.runs[].results[]] | length' results.sarif

# List all rule IDs triggered
jq '[.runs[].results[].ruleId] | unique' results.sarif

# Extract errors only
jq '.runs[].results[] | select(.level == "error")' results.sarif

# Get findings with file locations
jq '.runs[].results[] | {
  rule: .ruleId,
  message: .message.text,
  file: .locations[0].physicalLocation.artifactLocation.uri,
  line: .locations[0].physicalLocation.region.startLine
}' results.sarif

# Filter by severity and get count per rule
jq '[.runs[].results[] | select(.level == "error")] | group_by(.ruleId) | map({rule: .[0].ruleId, count: length})' results.sarif
```

## Strategy 2: Python with pysarif

For programmatic access with full object model:

```python
from pysarif import load_from_file, save_to_file

sarif = load_from_file("results.sarif")

for run in sarif.runs:
    tool_name = run.tool.driver.name
    print(f"Tool: {tool_name}")

    for result in run.results:
        print(f"  [{result.level}] {result.rule_id}: {result.message.text}")

        if result.locations:
            loc = result.locations[0].physical_location
            if loc and loc.artifact_location:
                print(f"    File: {loc.artifact_location.uri}")
                if loc.region:
                    print(f"    Line: {loc.region.start_line}")
```

## Strategy 3: Aggregating Multiple SARIF Files

When combining results from multiple tools:

```python
import json
from pathlib import Path

def aggregate_sarif_files(sarif_paths: list[str]) -> dict:
    """Combine multiple SARIF files into one."""
    aggregated = {
        "version": "2.1.0",
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "runs": []
    }

    for path in sarif_paths:
        with open(path) as f:
            sarif = json.load(f)
            aggregated["runs"].extend(sarif.get("runs", []))

    return aggregated

def deduplicate_results(sarif: dict) -> dict:
    """Remove duplicate findings based on fingerprints."""
    seen_fingerprints = set()

    for run in sarif["runs"]:
        unique_results = []
        for result in run.get("results", []):
            fp = None
            if result.get("partialFingerprints"):
                fp = tuple(sorted(result["partialFingerprints"].items()))
            elif result.get("fingerprints"):
                fp = tuple(sorted(result["fingerprints"].items()))
            else:
                loc = result.get("locations", [{}])[0]
                phys = loc.get("physicalLocation", {})
                fp = (
                    result.get("ruleId"),
                    phys.get("artifactLocation", {}).get("uri"),
                    phys.get("region", {}).get("startLine")
                )

            if fp not in seen_fingerprints:
                seen_fingerprints.add(fp)
                unique_results.append(result)

        run["results"] = unique_results

    return sarif
```

## Strategy 4: Extracting Actionable Data

```python
import json
from dataclasses import dataclass
from typing import Optional

@dataclass
class Finding:
    rule_id: str
    level: str
    message: str
    file_path: Optional[str]
    start_line: Optional[int]
    end_line: Optional[int]
    fingerprint: Optional[str]

def extract_findings(sarif_path: str) -> list[Finding]:
    """Extract structured findings from SARIF file."""
    with open(sarif_path) as f:
        sarif = json.load(f)

    findings = []
    for run in sarif.get("runs", []):
        for result in run.get("results", []):
            loc = result.get("locations", [{}])[0]
            phys = loc.get("physicalLocation", {})
            region = phys.get("region", {})

            findings.append(Finding(
                rule_id=result.get("ruleId", "unknown"),
                level=result.get("level", "warning"),
                message=result.get("message", {}).get("text", ""),
                file_path=phys.get("artifactLocation", {}).get("uri"),
                start_line=region.get("startLine"),
                end_line=region.get("endLine"),
                fingerprint=next(iter(result.get("partialFingerprints", {}).values()), None)
            ))

    return findings

def prioritize_findings(findings: list[Finding]) -> list[Finding]:
    """Sort findings by severity."""
    severity_order = {"error": 0, "warning": 1, "note": 2, "none": 3}
    return sorted(findings, key=lambda f: severity_order.get(f.level, 99))
```

## Common Pitfalls and Solutions

### 1. Path Normalization Issues

Different tools report paths differently (absolute, relative, URI-encoded):

```python
from urllib.parse import unquote
from pathlib import Path

def normalize_path(uri: str, base_path: str = "") -> str:
    """Normalize SARIF artifact URI to consistent path."""
    if uri.startswith("file://"):
        uri = uri[7:]
    uri = unquote(uri)
    if not Path(uri).is_absolute() and base_path:
        uri = str(Path(base_path) / uri)
    return str(Path(uri))
```

### 2. Large File Performance

For very large SARIF files (100MB+):

```python
import ijson  # pip install ijson

def stream_results(sarif_path: str):
    """Stream results without loading entire file."""
    with open(sarif_path, "rb") as f:
        for result in ijson.items(f, "runs.item.results.item"):
            yield result
```

### 3. Schema Validation

Validate before processing to catch malformed files:

```bash
# Using ajv-cli
npm install -g ajv-cli
ajv validate -s sarif-schema-2.1.0.json -d results.sarif
```

## CI/CD Integration Patterns

### GitHub Actions

```yaml
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif

- name: Check for high severity
  run: |
    HIGH_COUNT=$(jq '[.runs[].results[] | select(.level == "error")] | length' results.sarif)
    if [ "$HIGH_COUNT" -gt 0 ]; then
      echo "Found $HIGH_COUNT high severity issues"
      exit 1
    fi
```

### Fail on New Issues

```python
from sarif import loader

def check_for_regressions(baseline: str, current: str) -> int:
    """Return count of new issues not in baseline."""
    baseline_data = loader.load_sarif_file(baseline)
    current_data = loader.load_sarif_file(current)

    baseline_fps = {get_fingerprint(r) for r in baseline_data.get_results()}
    new_issues = [r for r in current_data.get_results()
                  if get_fingerprint(r) not in baseline_fps]

    return len(new_issues)
```

## Key Principles

1. **Validate first**: Check SARIF structure before processing
2. **Handle optionals**: Many fields are optional; use defensive access
3. **Normalize paths**: Tools report paths differently; normalize early
4. **Fingerprint wisely**: Combine multiple strategies for stable deduplication
5. **Stream large files**: Use ijson or similar for 100MB+ files
6. **Aggregate thoughtfully**: Preserve tool metadata when combining files

## Skill Resources

For ready-to-use query templates, see [references/jq-queries.md](references/jq-queries.md):
- 40+ jq queries for common SARIF operations
- Severity filtering, rule extraction, aggregation patterns

For Python utilities, see [references/sarif_helpers.py](references/sarif_helpers.py):
- `normalize_path()` - Handle tool-specific path formats
- `compute_fingerprint()` - Stable fingerprinting ignoring paths
- `deduplicate_results()` - Remove duplicates across runs

## Reference Links

- [OASIS SARIF 2.1.0 Specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html)
- [Microsoft SARIF Tutorials](https://github.com/microsoft/sarif-tutorials)
- [SARIF SDK (.NET)](https://github.com/microsoft/sarif-sdk)
- [sarif-tools (Python)](https://github.com/microsoft/sarif-tools)
- [pysarif (Python)](https://github.com/Kjeld-P/pysarif)
- [GitHub SARIF Support](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning)
