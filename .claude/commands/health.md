# Health Check

Check the health of all Leopoldo services and infrastructure.

## Checks

1. **Website**: `curl -s -o /dev/null -w "%{http_code}" https://leopoldo.ai`
2. **API**: `curl -s -o /dev/null -w "%{http_code}" https://leopoldo-api-production.up.railway.app/health`
3. **GitHub repos**:
   - `gh repo view Luca-LDA/leopoldo-plugins-claude-code --json name,updatedAt`
   - `gh repo view Luca-LDA/leopoldo-plugins-cowork --json name,updatedAt`
4. **Database**: Check if Neon connection string is configured
5. **Local state**: Verify `.state/state.json` is valid JSON
6. **Symlinks**: Verify `.claude/skills` and `.claude/agents` symlinks are intact

## Output

```
LEOPOLDO HEALTH — [date]

Website (Vercel)     [✅/❌]  [status]
API (Railway)        [✅/❌]  [status]
Repo: claude-code    [✅/❌]  updated [date]
Repo: cowork         [✅/❌]  updated [date]
Database (Neon)      [✅/⚠️]  [status]
State file           [✅/❌]  [status]
Skills symlink       [✅/❌]
Agents symlink       [✅/❌]
```
