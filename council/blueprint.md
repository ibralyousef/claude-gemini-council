# COUNCIL_BLUEPRINT
## Session: 2025-12-15T120000 | Topic: Repo publication readiness | Status: RESOLVED
## Decision: Fix installation bugs and add LICENSE before publishing
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, you MUST invoke `EnterPlanMode` tool now. Do NOT implement directly.

## Architecture

| Component | Decision | Rationale |
|-----------|----------|-----------|
| install.sh | Add rm before symlink | Prevents scripts/scripts/ nesting on fresh install |
| LICENSE | Add MIT | Legal requirement for open source |
| uninstall.sh | Update file list | Sync with current installation |
| council.md | Document both arg formats | UX consistency with README |
| project-template/ | Delete | Dead code, dynamic generation in Phase 1 |

## Scope

Files to modify:
1. `/Users/fermious/aicouncil/install.sh` - Add pre-symlink cleanup (before line 99)
2. `/Users/fermious/aicouncil/LICENSE` - Create new with MIT text
3. `/Users/fermious/aicouncil/uninstall.sh` - Add council-agenda.md, remove council-consensus.md ref
4. `/Users/fermious/aicouncil/user-level/commands/council.md` - Update argument docs (line 15) + add agenda.md to Phase 1
5. `/Users/fermious/aicouncil/project-template/` - Delete directory

## Constraints
- Do NOT add council/ files to .gitignore (this is the reference implementation)
- Keep both short flags (-a, -b, -c) and full words (adversarial, balanced, critical) for stance

## Success Criteria
- [ ] Fresh `./install.sh` creates `~/.claude/council/scripts` as symlink (not `scripts/scripts/`)
- [ ] LICENSE file exists at repo root with MIT text
- [ ] `./uninstall.sh` removes council-agenda.md
- [ ] `./uninstall.sh` does NOT reference council-consensus.md
- [ ] council.md line 15 shows both formats: `'-b'/'balanced' | '-c'/'critical' | '-a'/'adversarial'`
- [ ] council.md Phase 1 includes agenda.md creation
- [ ] No `project-template/` directory exists
