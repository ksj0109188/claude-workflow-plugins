# Promise Tag Reference

Complete reference for workflow state management via promise tags.

## Overview

Promise tags are markers inserted into agent responses to signal workflow state transitions. The Stop Hook (`stop-workflow-handler.sh`) monitors these tags and takes appropriate actions.

## Tag Format

```markdown
<promise>TAG_NAME</promise>
```

**Rules**:
- Must be at the end of agent response
- Exactly one tag per agent response
- Case-sensitive
- No spaces inside tags

## Tag Hierarchy

```
WORKFLOW_STARTED
  └─> MEMORY_UPDATED ──┐
        │               │
        ↓               │
  REVIEW_COMPLETE ──┐  │
        │            │  │
        ↓            │  │
  CLEANUP_APPROVED ─┤  │
        │            │  │
        ↓            ↓  ↓
  WORKFLOW_COMPLETE    (CONTINUE)
        │
        ↓
    (EXIT)

  (Alternative paths)
  REVIEW_ISSUES_FOUND ──> (BLOCK)
  CLEANUP_SKIPPED ──────> (CONTINUE to commit)
  MEMORY_UPDATE_FAILED ─> (BLOCK)
  COMMIT_FAILED ────────> (BLOCK)
  WORKFLOW_ABORTED ─────> (EXIT)
```

## Tag Definitions

### Step 1: Memory Update

#### MEMORY_UPDATED

**Agent**: memory-updater
**Meaning**: Memory files successfully updated (or user skipped)
**Action**: Continue to Step 2 (review)
**Hook Behavior**: Allow continuation

**Example**:
```markdown
# Memory Update Complete

- decisions.md: +1 entry
- issues.md: +1 entry
- progress.md: +1 session

<promise>MEMORY_UPDATED</promise>
```

#### MEMORY_UPDATE_FAILED

**Agent**: memory-updater
**Meaning**: Memory update encountered error
**Action**: STOP workflow, show error
**Hook Behavior**: Block session

**Hook Response**:
```json
{
  "decision": "block",
  "reason": "Memory update failed - cannot proceed",
  "systemMessage": "❌ Memory Update Failed\n\nFix file permissions/locks and retry."
}
```

**Example**:
```markdown
# Memory Update Failed

Error: Cannot write to .claude/memory/decisions.md (file locked)

<promise>MEMORY_UPDATE_FAILED</promise>
```

---

### Step 2: Deep Review

#### REVIEW_COMPLETE

**Agent**: deep-reviewer
**Meaning**: No critical issues found
**Action**: Continue to Step 3 (cleanup)
**Hook Behavior**: Allow continuation

**Example**:
```markdown
# Deep Review Summary

✅ No critical issues found

Important Issues (1):
- type encapsulation could be better

<promise>REVIEW_COMPLETE</promise>
```

#### REVIEW_ISSUES_FOUND

**Agent**: deep-reviewer
**Meaning**: Critical issues detected
**Action**: STOP workflow, ask user
**Hook Behavior**: **BLOCK session** - most important hook behavior

**Hook Response**:
```json
{
  "decision": "block",
  "reason": "Critical review issues detected",
  "systemMessage": "🚨 Critical Issues\n\nFix before continuing:\n- Empty catch block (api.ts:42)\n- No error tests (payment.ts)\n\nWhat should I do?\n1. Abort and fix\n2. View report\n3. Continue anyway"
}
```

**User Options**:

1. **Abort**: Return `<promise>WORKFLOW_ABORTED</promise>`
2. **View Report**: Show full report, return to decision
3. **Continue**: Override to `<promise>REVIEW_COMPLETE</promise>`

**Example**:
```markdown
# Deep Review Summary

🚨 Critical Issues (2 found)

1. silent-failure-hunter: Empty catch (api.ts:42)
2. pr-test-analyzer: No error tests (payment.ts)

<promise>REVIEW_ISSUES_FOUND</promise>
```

---

### Step 3: File Cleanup

#### CLEANUP_APPROVED

**Agent**: file-cleaner
**Meaning**: User approved cleanup, files archived
**Action**: Continue to Step 4 (commit)
**Hook Behavior**: Allow continuation

**Example**:
```markdown
# File Cleanup Complete

✓ 4 files archived to .archive/2026-01-23-11-45/
✓ 48 MB freed
✓ MANIFEST.md created

<promise>CLEANUP_APPROVED</promise>
```

#### CLEANUP_SKIPPED

**Agent**: file-cleaner
**Meaning**: User declined cleanup
**Action**: Continue to Step 4 (commit without cleanup)
**Hook Behavior**: Allow continuation

**Example**:
```markdown
# File Cleanup Skipped

User chose not to archive files.

Proceeding to commit...

<promise>CLEANUP_SKIPPED</promise>
```

---

### Step 4: Git Commit

#### WORKFLOW_COMPLETE

**Agent**: commit-manager
**Meaning**: Commit created successfully, workflow done
**Action**: Clean up state, exit
**Hook Behavior**: Delete state file, exit normally

**Hook Actions**:
1. Delete `.claude/work-completion.local.md`
2. Log completion to `work-completion.log`
3. Exit with success

**Example**:
```markdown
# Git Commit Complete

Commit: abc1234567890def
Message: "Fix errors, update memory, cleanup files"

Workflow complete! 🎉

<promise>WORKFLOW_COMPLETE</promise>
```

**Special Case - No Changes**:
```markdown
# No Changes to Commit

Working tree clean.

This is OK - workflow still complete.

<promise>WORKFLOW_COMPLETE</promise>
```

#### COMMIT_FAILED

**Agent**: commit-manager
**Meaning**: Commit failed (pre-commit hook, conflicts, etc.)
**Action**: STOP workflow, preserve state for retry
**Hook Behavior**: Block session, show error

**Hook Response**:
```json
{
  "decision": "block",
  "reason": "Git commit failed",
  "systemMessage": "❌ Commit Failed\n\nMost steps completed:\n✅ Memory\n✅ Review\n✅ Cleanup\n❌ Commit (pre-commit hook blocked)\n\nFix issues and retry."
}
```

**Example**:
```markdown
# Git Commit Failed

Pre-commit hook failed: ESLint errors

src/api/client.ts:42 - no-console

<promise>COMMIT_FAILED</promise>
```

---

### Workflow Control

#### WORKFLOW_ABORTED

**Source**: User decision after REVIEW_ISSUES_FOUND
**Meaning**: User chose to abort workflow
**Action**: Clean up state, exit with partial completion
**Hook Behavior**: Delete state file, report what was done

**Hook Actions**:
1. Delete `.claude/work-completion.local.md`
2. Log abortion reason
3. Exit normally (not error)

**Example**:
```markdown
User chose to abort workflow.

Completed:
✅ Memory updated
⏹️ Review complete (issues found)

Not completed:
⊙ Cleanup skipped
⊙ Commit skipped

<promise>WORKFLOW_ABORTED</promise>
```

---

## Hook Implementation

### stop-workflow-handler.sh Logic

```bash
#!/bin/bash
set -eo pipefail

STATE_FILE="$HOME/.claude/work-completion.local.md"
LOG_FILE="$HOME/.claude/logs/work-completion.log"

# Extract promise
PROMISE=$(echo "$TRANSCRIPT" | grep -oP '<promise>\K[^<]+' | tail -1)

case "$PROMISE" in
    "REVIEW_ISSUES_FOUND")
        # BLOCK workflow
        cat <<EOF
{
  "decision": "block",
  "reason": "Critical issues",
  "systemMessage": "🚨 Fix critical issues first"
}
EOF
        ;;

    "WORKFLOW_COMPLETE"|"WORKFLOW_ABORTED")
        # Clean up and exit
        rm -f "$STATE_FILE"
        echo "✅ Workflow finished"
        exit 0
        ;;

    "MEMORY_UPDATE_FAILED"|"COMMIT_FAILED")
        # Block with specific error
        cat <<EOF
{
  "decision": "block",
  "reason": "Step failed",
  "systemMessage": "❌ Fix error and retry"
}
EOF
        ;;

    *)
        # Allow continuation
        exit 0
        ;;
esac
```

## State File

**Location**: `$HOME/.claude/work-completion.local.md`

**Purpose**:
- Track workflow progress
- Enable resume after failure
- Provide context for retry

**Format**:
```yaml
---
step: 2
memory_updated: true
review_complete: false
cleanup_done: false
commit_hash: null
last_promise: "MEMORY_UPDATED"
timestamp: 2026-01-23T11:45:00Z
---
```

**Lifecycle**:
- Created: On workflow start (first promise)
- Updated: After each successful step
- Deleted: On WORKFLOW_COMPLETE or WORKFLOW_ABORTED

**Resume Logic**:
```markdown
If state file exists on /complete-work:
  Load state
  Skip completed steps
  Resume from last_promise

Example:
  "Resuming workflow from Step 2 (review)..."
```

## Error Recovery

### Transient Errors

**MEMORY_UPDATE_FAILED**, **COMMIT_FAILED**:
- State file preserved
- User fixes issue
- Re-run /complete-work → resumes from failure point

**Example**:
```
Run 1: Memory → Review → Cleanup → Commit FAILED
       (pre-commit hook error)

User fixes ESLint errors

Run 2: Memory SKIPPED (already done)
       Review SKIPPED (already done)
       Cleanup SKIPPED (already done)
       Commit → SUCCESS
```

### Critical Issues

**REVIEW_ISSUES_FOUND**:
- Workflow blocked
- User must choose: abort/continue/view
- State file updated with decision

**Decision Tree**:
```
REVIEW_ISSUES_FOUND
  ├─> User: "Abort" → WORKFLOW_ABORTED → clean up
  ├─> User: "View" → show report → return to decision
  └─> User: "Continue" → override to REVIEW_COMPLETE → proceed
```

## Testing Promise Tags

### Manual Testing

```bash
# Test REVIEW_ISSUES_FOUND blocking
echo "<promise>REVIEW_ISSUES_FOUND</promise>" | \
  TRANSCRIPT="$(cat)" \
  ~/claude-workflow-plugins/work-completion-workflow/hooks/scripts/stop-workflow-handler.sh

# Expected: JSON with "decision": "block"

# Test WORKFLOW_COMPLETE cleanup
touch ~/.claude/work-completion.local.md
echo "<promise>WORKFLOW_COMPLETE</promise>" | \
  TRANSCRIPT="$(cat)" \
  ~/claude-workflow-plugins/work-completion-workflow/hooks/scripts/stop-workflow-handler.sh

# Expected: State file deleted, success message
```

### Integration Testing

```markdown
1. Run /complete-work with intentional critical issue
2. Verify REVIEW_ISSUES_FOUND blocks
3. Choose "Abort"
4. Verify WORKFLOW_ABORTED cleans up
5. Check logs for correct sequence

Expected logs:
  [timestamp] MEMORY_UPDATED
  [timestamp] REVIEW_ISSUES_FOUND
  [timestamp] BLOCKING: Critical issues
  [timestamp] WORKFLOW_ABORTED
  [timestamp] ✅ Workflow aborted by user
```

## Best Practices

### For Agent Developers

1. **Always include exactly one promise tag** at end of response
2. **Match tag to actual state** - don't use COMPLETE if failed
3. **Provide context** - explain WHY this tag was chosen
4. **Be consistent** - same situation = same tag

### For Skill Developers

1. **Parse tags reliably** - use grep/regex, not string search
2. **Handle missing tags** - assume continuation if no tag
3. **Log all tags** - helps debugging
4. **Test all paths** - success, failure, abort

### For Users

1. **Trust critical blocks** - if blocked, there's a reason
2. **Check logs** - `.claude/logs/work-completion.log` has details
3. **Clean state on errors** - delete `.claude/work-completion.local.md` if stuck
4. **Report tag bugs** - wrong tag = broken workflow

## Common Issues

### Wrong Tag Used

**Problem**: Agent returns WORKFLOW_COMPLETE but commit failed

**Impact**: Hook cleans up state, can't retry

**Fix**: Agent should return COMMIT_FAILED instead

### Missing Tag

**Problem**: Agent doesn't include promise tag

**Impact**: Hook can't determine state, allows continuation (might not be correct)

**Fix**: Always include tag, even for errors

### Multiple Tags

**Problem**: Agent includes multiple tags in response

**Impact**: Hook uses last tag (tail -1), might not be intended

**Fix**: Only one tag per response

### Tag in Wrong Location

**Problem**: Tag appears mid-response, not at end

**Impact**: grep captures it, but semantically incorrect

**Fix**: Always place tag at very end of response
