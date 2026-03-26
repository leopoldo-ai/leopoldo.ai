# Release

Create a new release for Leopoldo plugins. Handles versioning, build, and GitHub release creation.

## Steps

1. **Current version**: Read `VERSION.json` or latest git tag
2. **Changelog**: Summarize commits since last release tag
3. **Bump version**: Ask user for bump type (patch/minor/major) if not specified
4. **Build**: Run plugin build for both formats (Claude Code + Cowork)
5. **Verify**: Check build output in `plugins/`
6. **Tag**: Create git tag with new version
7. **Push**: Push tags to origin
8. **GitHub Release**: Create release with changelog using `gh release create`

## Rules

- Always show the changelog before creating the release
- Never skip the build verification step
- Include skill count and plugin list in release notes
- Format: `vX.Y.Z`
