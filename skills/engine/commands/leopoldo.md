# /leopoldo

The main entry point for Leopoldo plugins. Discover what's installed and what you can do.

When the user runs this command, follow these steps:

1. Check which Leopoldo skills are installed by scanning for skill files in paths containing "leopoldo", "packs/finance", "packs/consulting", "packs/dev", "packs/intelligence", "packs/legal", or "packs/common".

2. Based on what you find, present the following:

---

**Welcome to Leopoldo.** Here is what you have installed.

## Installed Plugins

List each detected plugin with its slash command:

| Plugin | Command | Category |
|--------|---------|----------|
| Investment Core | `/investment` | Finance |
| Deal Engine | `/deal` | Finance |
| Fund Suite | `/fund` | Finance |
| Advisory Desk | `/advisory` | Finance |
| Markets Pro | `/markets` | Finance |
| Senior Consultant | `/consultant` | Business |
| Competitive Intelligence | `/intelligence` | Business |
| Marketing | `/marketing-hub` | Business |
| Medical Research | `/medresearch` | Medical |
| Full Stack | `/dev` | Maker |
| Legal Suite | `/legal` | Legal |

Only show rows for plugins that are actually installed.

## Lifecycle Commands

| Command | Purpose |
| ------- | ------- |
| `/leopoldo install [slug]` | First-time install of a plugin |
| `/leopoldo add [slug]` | Add another plugin |
| `/leopoldo update` | Check for updates and apply them (prompts for orphan removal) |
| `/leopoldo repair` | Reinstall missing or corrupted managed skills |
| `/leopoldo repair --prune` | Repair + remove orphan managed skills no longer shipped in current version |
| `/leopoldo status` | Show installed plugins, skill counts, health |
| `/leopoldo rollback` | Restore previous version from snapshot |
| `/leopoldo remove [slug]` | Remove one plugin |
| `/leopoldo uninstall` | Remove all Leopoldo skills |

## Quick Start

Pick any command above to see detailed capabilities and example prompts.

You can also just describe what you need. Leopoldo's expertise is always active, even without using a slash command.

## Useful Links

- Documentation: https://leopoldo.ai
- All plugins: https://leopoldo.ai/plugins
- Services: https://leopoldo.ai/services
