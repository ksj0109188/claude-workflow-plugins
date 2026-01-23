---
name: complete-work
description: Complete work session with memory update, deep review, file cleanup, and git commit
examples:
  - "/complete-work"
  - "complete work"
  - "finish session"
---

You are executing the `/complete-work` command. Your task is to invoke the `complete-work` skill using the Skill tool.

Use the Skill tool with:
- skill: "work-completion-workflow:complete-work"

The skill will orchestrate the 4-stage workflow: memory update → deep review → file cleanup → git commit.

Do NOT provide any explanation or introduction - immediately invoke the skill.

---

# Complete Work Command (Documentation)

Runs the complete work workflow: memory update → deep review → file cleanup → git commit.

## Usage

```
/complete-work
```

## What This Does

This command triggers the `complete-work` skill which orchestrates:

1. **Memory Update** (`/update-memory`)
   - Scans git-tracked .md files
   - User selects files to integrate
   - Updates `.claude/memory/` files

2. **Deep Code Review** (6 pr-review-toolkit agents)
   - code-reviewer: General quality
   - silent-failure-hunter: Error handling
   - pr-test-analyzer: Test coverage
   - type-design-analyzer: Type design (if types changed)
   - comment-analyzer: Comment accuracy (if comments changed)
   - code-simplifier: Refactoring suggestions (if no critical issues)

3. **File Cleanup** (Smart pattern learning)
   - Multi-layer detection (universal, git, project, learned patterns)
   - User teaches patterns (first run)
   - Auto-applies learned patterns (future runs)
   - Creates `.archive/` with 2-year retention

4. **Git Commit** (`commit-commands:commit`)
   - Auto-generates commit message
   - Includes Claude Code attribution
   - Stages and commits changes

## Critical Issue Handling

If deep review finds critical issues, the workflow **blocks** and asks:

```
🚨 Critical Issues Detected

Fix these issues before continuing:
- Empty catch block (api.ts:42)
- No error tests (payment.ts)

What should I do?
1. Abort and fix manually
2. View full report
3. Continue anyway (not recommended)
```

## Pattern Learning Example

**First Run**:
```
Found 15 cleanup candidates.

What should I do?
1. Archive all
2. Let me teach you patterns
3. Skip

User: 2

Pattern: "firebase-debug.log" - Archive? (y/n/always)
User: always
✅ Learned

Pattern: "coverage/" - Archive? (y/n/always)
User: always
✅ Learned

...

Patterns saved to .claude/cleanup-patterns.local.md
```

**Future Runs**:
```
Auto-archiving (learned patterns):
✓ firebase-debug.log
✓ coverage/
✓ scripts/old-migration-2024-05.sql

New pattern: .next/cache/ - Archive? (y/n/always)
User: always
✅ Added to patterns
```

## State Management

Workflow state tracked in: `.claude/work-completion.local.md`

**On failure**: State preserved for retry
**On abort**: State cleaned up
**On success**: State cleaned up

## Quick Reference

| Step | Promise Tag | Action |
|------|-------------|--------|
| Memory | MEMORY_UPDATED | Continue |
| Review (pass) | REVIEW_COMPLETE | Continue |
| Review (fail) | REVIEW_ISSUES_FOUND | **BLOCK** - ask user |
| Cleanup | CLEANUP_APPROVED | Continue |
| Cleanup | CLEANUP_SKIPPED | Continue |
| Commit | WORKFLOW_COMPLETE | Clean up, exit |
| Any error | *_FAILED | **BLOCK** - show error |

## Logs

All workflow activity logged to:
```
~/.claude/logs/work-completion.log
```

## Troubleshooting

**Stuck in workflow**:
```bash
rm ~/.claude/work-completion.local.md
```

**Pattern not learning**:
- Check file is writable: `.claude/cleanup-patterns.local.md`
- Verify patterns saved after "always" selection

**Review too strict**:
- Check severity thresholds in review-checklist.md
- Critical issues are truly critical (empty catches, no error tests)

## See Also

- `/update-memory` - Just memory update
- `commit-commands:commit` - Just git commit
- `pr-review-toolkit:review-pr` - Just code review
