# Work Completion Workflow Plugin

Comprehensive work completion workflow that orchestrates memory update, deep code review, smart file cleanup, and git commit in a single command.

## Features

🔄 **4-Stage Workflow**
1. **Memory Update**: Integrate session docs into `.claude/memory/`
2. **Deep Review**: Run all 6 pr-review-toolkit agents
3. **Smart Cleanup**: Pattern-based file archiving with learning
4. **Git Commit**: Auto-commit with proper attribution

🧠 **Smart Pattern Learning**
- Learns cleanup patterns from user feedback
- Applies patterns automatically in future runs
- Multi-layered detection: universal → git → project → learned

🛡️ **Safety Features**
- Blocks workflow on critical review issues
- User approval required for file cleanup
- 2-year archive retention policy
- Preserves all changes in `.archive/` with MANIFEST

## Installation

### ⚠️ Important: Manual Dependency Installation Required

**Claude Code does NOT automatically install plugin dependencies.**

You MUST manually install `pr-review-toolkit` BEFORE installing this plugin, or `/complete-work` will fail at Step 2.

### Prerequisites

This plugin requires the following official plugins:

```bash
# Install pr-review-toolkit (required for deep code review)
/plugin install pr-review-toolkit@claude-code-plugins
```

**Why required?** The Deep Review step (Step 2/4) uses all 6 pr-review-toolkit agents:
- code-reviewer, silent-failure-hunter, pr-test-analyzer
- type-design-analyzer, comment-analyzer, code-simplifier

**What happens without it?**
```
/complete-work
✅ [Step 1/4] Memory Update - Success
❌ [Step 2/4] Deep Review - Error: pr-review-toolkit:code-reviewer not found
⏸️  Workflow stopped
```

### Installation Steps (In Order!)

**Step 1: Install pr-review-toolkit (Required)**
```bash
/plugin install pr-review-toolkit@claude-code-plugins
```

**Step 2: Add marketplace**
```bash
/plugin marketplace add ksj0109188/claude-workflow-plugins
```

**Step 3: Install work-completion-workflow**
```bash
/plugin install work-completion-workflow@claude-workflow-plugins
```

**Step 4: Verify installation**
```bash
# Check both plugins are installed
/plugin list

# Expected output should include:
# - pr-review-toolkit@claude-code-plugins
# - work-completion-workflow@claude-workflow-plugins
```

## Usage

```bash
/complete-work
```

### First-Time Workflow

```
[Step 1/4] Memory Update
Found 3 new .md files - which should I integrate?

[Step 2/4] Deep Code Review
Launching 6 review agents...
✓ No critical issues

[Step 3/4] File Cleanup
Found 15 candidates - should I learn cleanup patterns?
> Learn patterns: y/n/always for each pattern

[Step 4/4] Git Commit
✓ Committed with auto-generated message
```

### Subsequent Runs

Pattern learning reduces manual input:
- Automatic cleanup based on learned patterns
- Only asks about NEW patterns
- Review continues to run for safety

## Critical Issue Handling

If deep review finds critical issues:

```
🚨 Critical Issues Found
- silent-failure-hunter: Empty catch block (api.ts:42)
- code-reviewer: Memory leak (component.tsx:128)

Options:
1. Abort workflow (fix issues manually)
2. View detailed report
3. Continue anyway (not recommended)
```

Workflow stops and waits for user decision.

## File Cleanup

### Archive Structure

```
.archive/
└── 2026-01-23-11-45/
    ├── MANIFEST.md              # What was archived, why, retention
    ├── temp-files/
    ├── old-scripts/
    └── build-artifacts/
```

### Pattern Learning

Cleanup patterns stored in `.claude/cleanup-patterns.local.md`:

```yaml
patterns:
  archive_always:
    - "firebase-debug.log"        # Learned: 2026-01-23
    - "coverage/"                 # Universal pattern
  never_archive:
    - "scripts/setup.sh"          # User preference
  archive_if_old_days: 180
```

## Integration

### Dependencies

**Required**:
- `pr-review-toolkit@claude-code-plugins` - 6 review agents (code-reviewer, silent-failure-hunter, pr-test-analyzer, type-design-analyzer, comment-analyzer, code-simplifier)

**Optional** (built-in alternatives available):
- `update-memory` plugin (or built-in /update-memory command)
- `commit-commands` plugin (or built-in git commands)

### Workflow State

State managed via `.claude/work-completion.local.md`:
- Tracks current step
- Stores promise tags
- Auto-cleanup on completion

## Promise Tags

Internal workflow state markers:

- `MEMORY_UPDATED` → Proceed to review
- `REVIEW_COMPLETE` → Proceed to cleanup
- `REVIEW_ISSUES_FOUND` → STOP, ask user
- `CLEANUP_APPROVED` → Proceed to commit
- `WORKFLOW_COMPLETE` → Clean up, exit

## Safety Rules

**Never Archives**:
- Git-tracked files with uncommitted changes
- Files modified in last 7 days (unless temp)
- Config files (.env, .config, etc.)
- Files in never_archive list

**Review Blocking**:
- Critical issues → workflow stops
- User must fix or explicitly continue
- Prevents bad code from being committed

## Configuration

### Cleanup Pattern Override

Edit `.claude/cleanup-patterns.local.md` to customize:

```yaml
patterns:
  archive_always:
    - "my-custom-pattern-*.log"
  never_archive:
    - "important-script.sh"
  archive_if_old_days: 90  # Shorter retention
```

## Future Enhancements

- [ ] Parallel review mode (faster for large PRs)
- [ ] Archive compression for large files
- [ ] Export review report to GitHub PR comments
- [ ] Team-shared pattern config

## Troubleshooting

**Workflow stuck**: Check `.claude/work-completion.local.md` and delete if stale

**Pattern not learning**: Ensure `.claude/cleanup-patterns.local.md` is writable

**Review too slow**: Consider parallel mode (future enhancement)

**False positives in cleanup**: Add to never_archive list

## License

MIT
