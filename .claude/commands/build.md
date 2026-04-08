# Build Plugins

Build plugin packages for both public repositories (Claude Code and Cowork format).

## Steps

1. **Pre-flight check**: Verify `bin/build-public-repos.sh` exists and is executable
2. **Skill count**: Count total SKILL.md files to include in build metadata
3. **Run build**: Execute the build script
4. **Verify output**: Check `plugins/` directory for generated output
5. **Summary**: Report what was built, file counts, and sizes

## Rules

- If the build script doesn't exist yet, report what needs to be created
- Never push to public repos automatically. Only build locally.
- Show a diff summary of what changed since last build if possible
