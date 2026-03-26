# Skill Safety Review for Claude Code

A Claude Code skill that audits third-party skills for security before you install them. Catches prompt injection, remote code execution, data exfiltration, and other attack patterns.

## Install

```bash
mkdir -p skills
git clone https://github.com/federiconeri/review-skill-safety.git skills/review-skill-safety
```

## Usage

In Claude Code, when you want to vet a skill before installing:

```
/review-skill-safety https://github.com/owner/some-skill
```

Or ask naturally:

```
Check if this skill is safe: https://github.com/owner/some-skill
```

The skill walks through a structured security checklist and produces a SAFE / CAUTION / UNSAFE verdict.

## What It Checks

| Check | What It Catches |
|-------|----------------|
| **A. Frontmatter** | Non-standard fields (`allowed-tools`, `permissions`), invalid name format |
| **B. Prompt Injection** | "Ignore previous instructions", false authority claims, role reassignment, hidden directives |
| **C. Remote Code Execution** | `curl \| bash`, script downloads, eval of remote content |
| **D. Data Exfiltration** | Outbound POST with local data, env var theft, credential file access, fake telemetry |
| **E. System Modification** | Writing to `~/.bashrc`, `~/.claude/settings.json`, git config, system paths |
| **F. Tool Access** | High-risk tool usage (Bash, WebFetch) vs what the skill actually needs |
| **G. Content Legitimacy** | Does it do what it claims? Obfuscated/encoded content? Credible sources? |
| **H. Community Signals** | Stars, forks, age, contributors, license |

## Key Principles

- **Read ALL files** — attacks hide in READMEs, helper scripts, dot files, not just SKILL.md
- **Community signals don't guarantee safety** — still run the full checklist even for popular skills
- **Any prompt injection, RCE, or exfiltration = FAIL** — no exceptions, no "but it looks useful"

## Example Output

```
## Safety Verdict: some-skill

| Check | Result | Notes |
|-------|--------|-------|
| Frontmatter | PASS | Standard fields only |
| Prompt injection | PASS | No injection patterns found |
| Remote code execution | PASS | No download-and-execute patterns |
| Data exfiltration | PASS | No outbound data transmission |
| System modification | PASS | No config file modifications |
| Tool access | PASS | Read, Edit, Write only — appropriate for a writing skill |
| Content legitimacy | PASS | Content matches description, references verifiable sources |
| Community signals | LOW RISK | 5,600 stars, 420 forks, 1+ month old, MIT license |

**Overall: SAFE**
```

## License

MIT
