# COUNCIL_BLUEPRINT
## Session: 2025-12-16-150000 | Topic: Improve README clarity | Status: RESOLVED
## Decision: Restructure README with conceptual intro, example session, and simplified technical reference
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture:
| Section | Purpose | Content |
|---------|---------|---------|
| Why Two AIs? | Conceptual understanding | Roles, strengths, senate/executive model |
| Quick Start | Get started fast | Existing commands, concise |
| Example Session | Make it tangible | 2-round dialogue + COUNCIL_RESPONSE + blueprint |
| How It Works | Technical overview | Protocol injection, session management, tool restrictions |
| Reference | Detailed docs | Stance levels, commands, file structure, config |

## Scope:
- `README.md`: Major restructure - add 2 new sections, simplify 1 section

## Constraints:
- Keep README under ~400 lines (currently ~260)
- Example should be realistic but concise
- Don't lose essential technical details

## Success Criteria:
- [ ] "Why Two AIs?" section explains conceptual model clearly
- [ ] Example session shows both AI perspectives and COUNCIL_RESPONSE format
- [ ] Example includes a blueprint
- [ ] "How It Works" is simplified but retains key technical details
- [ ] New users can understand the value proposition in <2 minutes
