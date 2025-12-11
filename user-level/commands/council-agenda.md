# Council Agenda Management

Manage the strategic agenda for future council sessions.

## Arguments
Parse arguments in this order:
1. **Action** (required): `add` | `list` | `remove` | `promote` | `park`
2. **Additional args** depend on action

**Input received:** $ARGUMENTS

## Actions

### list
Show all agenda items grouped by priority.
```
/council-agenda list
```

### add <priority> <topic>
Add a new agenda item.
```
/council-agenda add P1 Evaluate caching strategy for API responses
```

### remove <topic-pattern>
Remove an agenda item by partial title match.
```
/council-agenda remove caching
```

### promote <topic-pattern>
Increase priority of an item (P2 → P1 → P0).
```
/council-agenda promote caching
```

### park <topic-pattern>
Move an item to "Parked" status.
```
/council-agenda park caching
```

## Instructions

1. **Parse arguments**: Determine action and additional parameters

2. **Read the agenda file**: `council/memory/agenda.md`
   - If file doesn't exist, create it with the template

3. **Execute the action**:

   **For `list`**:
   - Display agenda items grouped by priority (P0 → P1 → P2 → Parked)
   - Show item count per priority level
   - Format nicely for terminal display

   **For `add`**:
   - Validate priority is one of: P0, P1, P2, Parked
   - Append new item to agenda.md with format:
     ```markdown
     ## [Priority] Topic Title
     - **Added**: YYYY-MM-DD
     - **Context**: [User can edit this]
     - **Suggested Stance**: balanced
     - **Related Decisions**: None yet
     ```
   - Confirm addition

   **For `remove`**:
   - Find item matching the topic pattern (case-insensitive)
   - Ask for confirmation before removing
   - Remove the entire item block

   **For `promote`**:
   - Find item matching the topic pattern
   - Increase priority: Parked → P2 → P1 → P0
   - If already P0, inform user

   **For `park`**:
   - Find item matching the topic pattern
   - Change priority to Parked

4. **Display result**: Show confirmation and current agenda state

## Template for agenda.md (if missing)

```markdown
# Council Agenda

Strategic topics queued for future council sessions.

## Priority Levels
- **P0**: Blocking issues requiring immediate attention
- **P1**: Important topics to address soon
- **P2**: Nice-to-have discussions
- **Parked**: Ideas to revisit later

---

<!-- Add agenda items below this line -->
```

## Usage Tips Displayed After Actions

After any action, remind user:
- `/council <topic>` - Start a council session on any agenda item
- `/council-agenda list` - View full agenda
- Agenda items provide continuity - the council can reference them in sessions

## Error Handling

- If `council/memory/agenda.md` doesn't exist: Create it
- If no items match pattern: Show helpful message with existing items
- If action is invalid: Show usage help
