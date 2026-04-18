---
name: codeql
description: "Use when scanning a codebase with CodeQL for security vulnerabilities, running interprocedural data flow and taint tracking analysis, building a CodeQL database, creating data extensions, or running multiple query packs. Supports 'run all' and 'important only' modes."
type: technique
version: 0.2.0
layer: userland
category: security
triggers:
  - pattern: "run codeql"
  - pattern: "codeql scan"
  - pattern: "codeql analysis"
  - pattern: "build codeql database"
  - pattern: "find vulnerabilities with codeql"
dependencies:
  hard: []
  soft:
    - sarif-parsing
    - semgrep
    - variant-analysis
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
metadata:
  author: trailofbits
  source: https://github.com/trailofbits/skills
license: MIT
---

# CodeQL Analysis

Supported languages: Python, JavaScript/TypeScript, Go, Java/Kotlin, C/C++, C#, Ruby, Swift.

**Skill resources:** Reference files and templates are located at `{baseDir}/references/` and `{baseDir}/workflows/`.

## Essential Principles

1. **Database quality is non-negotiable.** A database that builds is not automatically good. Always run quality assessment (file counts, baseline LoC, extractor errors) and compare against expected source files. A cached build produces zero useful extraction.

2. **Data extensions catch what CodeQL misses.** Even projects using standard frameworks (Django, Spring, Express) have custom wrappers around database calls, request parsing, or shell execution. Skipping the create-data-extensions workflow means missing vulnerabilities in project-specific code paths.

3. **Explicit suite references prevent silent query dropping.** Never pass pack names directly to `codeql database analyze` — each pack's `defaultSuiteFile` applies hidden filters that can produce zero results. Always generate a custom `.qls` suite file.

4. **Zero findings needs investigation, not celebration.** Zero results can indicate poor database quality, missing models, wrong query packs, or silent suite filtering. Investigate before reporting clean.

5. **macOS Apple Silicon requires workarounds for compiled languages.** Exit code 137 is `arm64e`/`arm64` mismatch, not a build failure. Try Homebrew arm64 tools or Rosetta before falling back to `build-mode=none`.

6. **Follow workflows step by step.** Once a workflow is selected, execute it step by step without skipping phases. Each phase gates the next — skipping quality assessment or data extensions leads to incomplete analysis.

## Output Directory

All generated files (database, build logs, diagnostics, extensions, results) are stored in a single output directory.

- **If the user specifies an output directory** in their prompt, use it as `OUTPUT_DIR`.
- **If not specified**, default to `./static_analysis_codeql_1`. If that already exists, increment to `_2`, `_3`, etc.

In both cases, **always create the directory** with `mkdir -p` before writing any files.

```bash
# Resolve output directory
if [ -n "$USER_SPECIFIED_DIR" ]; then
  OUTPUT_DIR="$USER_SPECIFIED_DIR"
else
  BASE="static_analysis_codeql"
  N=1
  while [ -e "${BASE}_${N}" ]; do
    N=$((N + 1))
  done
  OUTPUT_DIR="${BASE}_${N}"
fi
mkdir -p "$OUTPUT_DIR"
```

The output directory is resolved **once** at the start before any workflow executes. All workflows receive `$OUTPUT_DIR` and store their artifacts there:

```
$OUTPUT_DIR/
├── rulesets.txt                 # Selected query packs (logged after Step 3)
├── codeql.db/                   # CodeQL database (dir containing codeql-database.yml)
├── build.log                    # Build log
├── codeql-config.yml            # Exclusion config (interpreted languages)
├── diagnostics/                 # Diagnostic queries and CSVs
├── extensions/                  # Data extension YAMLs
├── raw/                         # Unfiltered analysis output
│   ├── results.sarif
│   └── <mode>.qls
└── results/                     # Final results (filtered for important-only, copied for run-all)
    └── results.sarif
```

### Database Discovery

A CodeQL database is identified by the presence of a `codeql-database.yml` marker file inside its directory. When searching for existing databases, **always collect all matches** — there may be multiple databases from previous runs or for different languages.

**Discovery command:**

```bash
# Find ALL CodeQL databases (top-level and one subdirectory deep)
find . -maxdepth 3 -name "codeql-database.yml" -not -path "*/\.*" 2>/dev/null \
  | while read -r yml; do dirname "$yml"; done
```

Never assume a database is named `codeql.db` — discover it by its marker file.

## Quick Start

For the common case ("scan this codebase for vulnerabilities"):

```bash
# 1. Verify CodeQL is installed
if ! command -v codeql >/dev/null 2>&1; then
  echo "NOT INSTALLED: codeql binary not found on PATH"
else
  codeql --version || echo "ERROR: codeql found but --version failed (check installation)"
fi

# 2. Resolve output directory
BASE="static_analysis_codeql"; N=1
while [ -e "${BASE}_${N}" ]; do N=$((N + 1)); done
OUTPUT_DIR="${BASE}_${N}"; mkdir -p "$OUTPUT_DIR"
```

Then execute the full pipeline: **build database -> create data extensions -> run analysis** using the workflows below.

## When to Use

- Scanning a codebase for security vulnerabilities with deep data flow analysis
- Building a CodeQL database from source code (with build capability for compiled languages)
- Finding complex vulnerabilities that require interprocedural taint tracking or AST/CFG analysis
- Performing comprehensive security audits with multiple query packs

## When NOT to Use

- **Writing custom queries** - Use a dedicated query development skill
- **CI/CD integration** - Use GitHub Actions documentation directly
- **Quick pattern searches** - Use Semgrep or grep for speed
- **No build capability** for compiled languages - Consider Semgrep instead
- **Single-file or lightweight analysis** - Semgrep is faster for simple pattern matching

## Rationalizations to Reject

These shortcuts lead to missed findings. Do not accept them:

- **"security-extended is enough"** - It is the baseline. Always check if Trail of Bits packs and Community Packs are available for the language.
- **"The database built, so it's good"** - A database that builds does not mean it extracted well. Always run quality assessment.
- **"Data extensions aren't needed for standard frameworks"** - Even Django/Spring apps have custom wrappers that CodeQL does not model.
- **"build-mode=none is fine for compiled languages"** - It produces severely incomplete analysis. Only use as an absolute last resort.
- **"No findings means the code is secure"** - Zero findings can indicate poor database quality, missing models, or wrong query packs.
- **"I'll just run the default suite"** - Each pack's `defaultSuiteFile` applies hidden filters and can produce zero results.

---

## Workflow Selection

This skill has three workflows. **Once a workflow is selected, execute it step by step without skipping phases.**

| Workflow | Purpose |
|----------|---------|
| [build-database](workflows/build-database.md) | Create CodeQL database using build methods in sequence |
| [create-data-extensions](workflows/create-data-extensions.md) | Detect or generate data extension models for project APIs |
| [run-analysis](workflows/run-analysis.md) | Select rulesets, execute queries, process results |

### Auto-Detection Logic

**Default pipeline for "test", "scan", "analyze", or similar:** Discover existing databases first, then decide.

| Condition | Action |
|-----------|--------|
| No databases found | Resolve new `$OUTPUT_DIR`, execute build -> extensions -> analysis (full pipeline) |
| One database found | Ask user: reuse it or build new? |
| Multiple databases found | List all with metadata, let user pick one or build new |
| User explicitly stated intent | Skip prompt, act on their instructions directly |

---

## Reference Index

| File | Content |
|------|---------|
| **Workflows** | |
| [workflows/build-database.md](workflows/build-database.md) | Database creation with build method sequence |
| [workflows/create-data-extensions.md](workflows/create-data-extensions.md) | Data extension generation pipeline |
| [workflows/run-analysis.md](workflows/run-analysis.md) | Query execution and result processing |
| **References** | |
| [references/macos-arm64e-workaround.md](references/macos-arm64e-workaround.md) | Apple Silicon build tracing workarounds |
| [references/build-fixes.md](references/build-fixes.md) | Build failure fix catalog |
| [references/quality-assessment.md](references/quality-assessment.md) | Database quality metrics and improvements |
| [references/extension-yaml-format.md](references/extension-yaml-format.md) | Data extension YAML column definitions and examples |
| [references/sarif-processing.md](references/sarif-processing.md) | jq commands for SARIF output processing |
| [references/diagnostic-query-templates.md](references/diagnostic-query-templates.md) | QL queries for source/sink enumeration |
| [references/important-only-suite.md](references/important-only-suite.md) | Important-only suite template and generation |
| [references/run-all-suite.md](references/run-all-suite.md) | Run-all suite template |
| [references/ruleset-catalog.md](references/ruleset-catalog.md) | Available query packs by language |
| [references/threat-models.md](references/threat-models.md) | Threat model configuration |
| [references/language-details.md](references/language-details.md) | Language-specific build and extraction details |
| [references/performance-tuning.md](references/performance-tuning.md) | Memory, threading, and timeout configuration |

---

## Success Criteria

A complete CodeQL analysis run should satisfy:

- [ ] Output directory resolved (user-specified or auto-incremented default)
- [ ] All generated files stored inside `$OUTPUT_DIR`
- [ ] Database built (discovered via `codeql-database.yml` marker) with quality assessment passed (baseline LoC > 0, errors < 5%)
- [ ] Data extensions evaluated — either created in `$OUTPUT_DIR/extensions/` or explicitly skipped with justification
- [ ] Analysis run with explicit suite reference (not default pack suite)
- [ ] All installed query packs (official + Trail of Bits + Community) used or explicitly excluded
- [ ] Selected query packs logged to `$OUTPUT_DIR/rulesets.txt`
- [ ] Unfiltered results preserved in `$OUTPUT_DIR/raw/results.sarif`
- [ ] Final results in `$OUTPUT_DIR/results/results.sarif` (filtered for important-only, copied for run-all)
- [ ] Zero-finding results investigated (database quality, model coverage, suite selection)
- [ ] Build log preserved at `$OUTPUT_DIR/build.log` with all commands, fixes, and quality assessments
