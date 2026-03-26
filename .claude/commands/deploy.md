# Deploy

Guide the deployment process for Leopoldo services.

## Pre-deploy checks

1. Run `git status` — ensure working tree is clean
2. Run `cd web && ./node_modules/.bin/next build` — verify website builds
3. Check current branch is `master`

## Deploy targets

### Website (Vercel) — automatic
- `git push origin master` triggers auto-deploy
- Verify at https://leopoldo.ai after push

### Backend API (Railway) — automatic
- Same push triggers Railway auto-deploy
- Verify at https://leopoldo-api-production.up.railway.app/health

### Plugin repos (manual)
1. Build: `bin/build-public-repos.sh`
2. Push to `Luca-LDA/leopoldo-plugins-claude-code`
3. Push to `Luca-LDA/leopoldo-plugins-cowork`
4. Tag release for auto-update

## Rules

- Never force push
- Always verify build passes before pushing
- Report deploy status after each step
