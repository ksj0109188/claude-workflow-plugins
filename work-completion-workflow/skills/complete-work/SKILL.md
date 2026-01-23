---
name: complete-work
description: >
  This skill should be used when the user asks to "complete work", "finish up",
  "wrap up the session", uses the /complete-work command, or mentions finalizing
  their work with commit. Orchestrates 4-stage workflow: memory update → deep
  review → file cleanup → git commit. Implements smart pattern learning for
  automated cleanup decisions.
examples:
  - "/complete-work"
  - "complete my work"
  - "wrap up this session"
  - "finish and commit everything"
  - "run the completion workflow"
version: 1.0.0
---

# Work Completion Workflow Skill

Comprehensive 4-stage workflow orchestrator for completing work sessions with quality assurance.

## Overview

This skill coordinates specialized agents to execute a complete workflow:
1. **Memory Update**: Integrate session docs into `.claude/memory/`
2. **Deep Review**: Run all 6 pr-review-toolkit agents
3. **Smart Cleanup**: Pattern-based file archiving with learning
4. **Git Commit**: Auto-commit with proper attribution

**Critical**: Simply mentioning agent names in this skill body will cause Claude to automatically use the Task tool to invoke them (Claude Code 2.1.0 pattern).

## Workflow Orchestration

### Step 1: Memory Update

Launch the **memory-updater agent** to execute /update-memory:

```
Use Task tool to call memory-updater agent with prompt:
"Execute the /update-memory workflow:
1. Scan git-tracked .md files (new/modified)
2. Present file classification to user
3. Integrate selected files into .claude/memory/*.md
4. Handle line limits with auto-archive
5. Update progress.md with session summary

Report status and any warnings."
```

**Expected Output**:
- Success: `<promise>MEMORY_UPDATED</promise>`
- Failure: `<promise>MEMORY_UPDATE_FAILED</promise>` → Stop workflow

**On MEMORY_UPDATE_FAILED**:
```markdown
⚠️ Memory update failed

The workflow cannot continue without memory being up-to-date.

Please fix the issue and re-run /complete-work.
```

### Step 2: Deep Code Review

Launch the **deep-reviewer agent** to orchestrate pr-review-toolkit:

```
Use Task tool to call deep-reviewer agent with prompt:
"Execute comprehensive code review on git diff (unstaged + staged):
1. Launch all 6 pr-review-toolkit agents sequentially
2. Aggregate findings by severity (critical/important/suggestions)
3. Determine if critical issues block workflow
4. Generate user-friendly report with file:line references

Agent sequence:
- code-reviewer (baseline quality)
- silent-failure-hunter (error handling)
- pr-test-analyzer (test coverage)
- type-design-analyzer (if types changed)
- comment-analyzer (if comments changed)
- code-simplifier (if no critical issues)

Return aggregated report with promise tag."
```

**Expected Output**:
- No critical issues: `<promise>REVIEW_COMPLETE</promise>` → Continue
- Critical issues found: `<promise>REVIEW_ISSUES_FOUND</promise>` → STOP

**On REVIEW_ISSUES_FOUND**:

The Stop Hook (`stop-workflow-handler.sh`) will BLOCK the workflow and present:

```markdown
🚨 Critical Issues Detected

The deep review found issues that need attention:

Critical Issues:
- silent-failure-hunter: Empty catch block (api/client.ts:42)
- pr-test-analyzer: No error handling tests (services/payment.ts)

Important Issues:
- type-design-analyzer: Weak encapsulation (types/user.ts:12)

What would you like to do?
1. Abort workflow and fix issues manually
2. View full review report
3. Continue anyway (not recommended)

[Workflow is BLOCKED until user responds]
```

**User Options**:

- **Option 1: Abort**
  ```markdown
  Workflow aborted.

  What was completed:
  ✅ Memory updated (.claude/memory/)
  ⏹️ Review complete (issues found)
  ⊙ Cleanup skipped
  ⊙ Commit skipped

  Next steps:
  1. Fix critical issues in:
     - api/client.ts:42 (empty catch)
     - services/payment.ts (add error tests)
  2. Re-run /complete-work when ready

  <promise>WORKFLOW_ABORTED</promise>
  ```

- **Option 2: View Report**
  - Display full review report
  - Return to decision prompt

- **Option 3: Continue Anyway**
  ```markdown
  ⚠️ Continuing with critical issues (not recommended)

  You chose to proceed despite critical review findings.
  These issues will be committed to the repository.

  Proceeding to Step 3 (cleanup)...
  ```

**On REVIEW_COMPLETE** (no critical issues):
```markdown
✅ Deep review passed

Summary:
- No critical issues found
- 1 important issue (non-blocking)
- 2 suggestions for future improvement

Proceeding to Step 3 (cleanup)...
```

### Step 3: File Cleanup

Launch the **file-cleaner agent** for smart pattern-based cleanup:

```
Use Task tool to call file-cleaner agent with prompt:
"Execute smart file cleanup with pattern learning:
1. Run 4-layer detection:
   - Layer 1: Universal patterns (test artifacts, debug logs)
   - Layer 2: Git analysis (files not modified in 60+ days)
   - Layer 3: Project context (Node.js, Python, etc.)
   - Layer 4: User preferences (.claude/cleanup-patterns.local.md)

2. If pattern file exists:
   - Auto-apply learned patterns
   - Only ask about NEW patterns

3. If first run (no pattern file):
   - Present all findings to user
   - Teach patterns with y/n/always option
   - Save 'always' selections to pattern file

4. Create organized archive:
   - .archive/YYYY-MM-DD-HH-MM/
   - Categorized subdirectories
   - Comprehensive MANIFEST.md with 2-year retention

5. Safety checks:
   - Never archive uncommitted changes
   - Never archive files modified < 7 days (unless temp)
   - Never archive config files (.env, etc.)
   - Never archive files in never_archive list

Return cleanup summary with promise tag."
```

**Expected Output**:
- User approved: `<promise>CLEANUP_APPROVED</promise>` → Continue
- User skipped: `<promise>CLEANUP_SKIPPED</promise>` → Continue

**First Run Example**:
```markdown
File Cleanup - Pattern Learning

Found 15 cleanup candidates using multi-layer detection:

Temporary Files (3 files, 48 MB):
- firebase-debug.log (34 MB)
- coverage/ (12 MB)
- .nyc_output/ (2 MB)

Old Scripts (2 files, 45 KB):
- scripts/old-migration-2024-01.sql (modified 180 days ago)
- scripts/temp-fix.sh (modified 240 days ago)

What should I do?
1. Archive all (15 files)
2. Teach me which patterns to remember
3. Skip cleanup

Your choice (1/2/3):
```

**User selects #2 (Pattern Learning)**:
```markdown
Pattern Learning Session

Pattern: "firebase-debug.log"
  Archive this? (y/n/always): always

Pattern: "scripts/migration-*.sql" (if > 180 days)
  Archive this? (y/n/always): always

Pattern: "coverage/"
  Archive this? (y/n/always): always

✅ Learned 3 patterns, saved to .claude/cleanup-patterns.local.md

Archiving files...
✓ 4 files moved to .archive/2026-01-23-11-45/ (48 MB freed)
✓ MANIFEST.md created with 2-year retention policy

<promise>CLEANUP_APPROVED</promise>
```

**Subsequent Runs** (patterns learned):
```markdown
File Cleanup - Auto-Apply Learned Patterns

Auto-archiving files (learned patterns):
✓ firebase-debug.log (28 MB) → pattern: firebase-debug.log
✓ coverage/ (15 MB) → pattern: coverage/
✓ scripts/old-migration-2024-05.sql (30 KB) → pattern: migration-*.sql

New pattern detected:
- .next/cache/ (50 MB) - Next.js cache
  Archive this? (y/n/always): always

✅ Added .next/cache/ to patterns

Total archived: 4 files (93 MB freed)

<promise>CLEANUP_APPROVED</promise>
```

**On CLEANUP_SKIPPED**:
```markdown
File cleanup skipped by user.

Proceeding to Step 4 (commit)...
```

### Step 4: Git Commit

Launch the **commit-manager agent** to create the final commit:

```
Use Task tool to call commit-manager agent with prompt:
"Create git commit using commit-commands plugin:
1. Invoke commit-commands:commit skill
2. Auto-generate commit message following repo style
3. Include changes:
   - Memory updates (.claude/memory/)
   - Code changes (if any)
   - Cleanup summary (if cleanup occurred)
4. Ensure Claude Code attribution
5. Handle errors (pre-commit hooks, no changes, etc.)

Return commit hash and promise tag."
```

**Expected Output**:
- Success: `<promise>WORKFLOW_COMPLETE</promise>`
- Failure: `<promise>COMMIT_FAILED</promise>`

**On WORKFLOW_COMPLETE**:
```markdown
✅ Work Completion Workflow Finished

Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Step 1] Memory Update ✅
- decisions.md: +1 entry
- issues.md: +1 entry
- progress.md: +1 session

[Step 2] Deep Review ✅
- No critical issues
- 1 important issue (type encapsulation)
- 2 suggestions

[Step 3] File Cleanup ✅
- 4 files archived (93 MB freed)
- 1 new pattern learned
- Archive: .archive/2026-01-23-11-45/

[Step 4] Git Commit ✅
- Commit: abc1234567890def
- Message: "Fix error handling, update memory, cleanup old files"
- 5 files committed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total time: 2 minutes 15 seconds

All work has been completed and committed!

<promise>WORKFLOW_COMPLETE</promise>
```

**On COMMIT_FAILED**:
```markdown
⚠️ Commit Failed

Pre-commit hook blocked the commit (ESLint errors).

What was completed:
✅ Memory updated
✅ Review passed
✅ Files archived

What's pending:
❌ Git commit (blocked by pre-commit)

Next steps:
1. Fix pre-commit issues:
   - src/api/client.ts:42 (ESLint: no-console)
2. Re-run /complete-work (will skip memory/cleanup/review)
3. Or manually commit: git commit (not recommended)

<promise>COMMIT_FAILED</promise>
```

## Error Recovery

### Partial Workflow Completion

If workflow stops mid-execution, track what was completed:

```yaml
State File: .claude/work-completion.local.md
Format:
  ---
  step: 2
  memory_updated: true
  review_complete: false
  cleanup_done: false
  commit_hash: null
  ---
```

On re-run, skip completed steps:
```markdown
Resuming work completion workflow...

Detected partial completion:
✅ Step 1: Memory (already updated)
⊙ Step 2: Review (resuming here)
⊙ Step 3: Cleanup (pending)
⊙ Step 4: Commit (pending)

Continuing from Step 2...
```

### User Interruption

If user interrupts (Ctrl+C) during workflow:

```markdown
⚠️ Workflow interrupted by user

Completed so far:
✅ Memory updated
⏹️ Review in progress (interrupted)

State saved to .claude/work-completion.local.md

To resume: Run /complete-work again
To start fresh: Delete .claude/work-completion.local.md
```

## Stop Hook Integration

The Stop Hook (`hooks/scripts/stop-workflow-handler.sh`) monitors promise tags:

- `REVIEW_ISSUES_FOUND` → **BLOCK** workflow, ask user
- `WORKFLOW_COMPLETE` → Clean up state file, exit
- `WORKFLOW_ABORTED` → Clean up state file, report
- Other tags → Allow continuation

**Blocking Behavior**:
```bash
# stop-workflow-handler.sh
if [ "$PROMISE" == "REVIEW_ISSUES_FOUND" ]; then
  cat <<EOF
{
  "decision": "block",
  "reason": "Critical review issues found",
  "systemMessage": "🚨 Critical Issues\n\nFix issues before continuing."
}
EOF
fi
```

## Usage Examples

### Basic Usage

```
User: /complete-work

Claude:
Starting work completion workflow...

[Step 1/4] Memory Update
Found 3 new .md files to integrate...
[User selects files]
✅ Memory updated (3 files)

[Step 2/4] Deep Review
Launching 6 review agents...
✅ No critical issues

[Step 3/4] File Cleanup
Found 4 cleanup candidates...
[User teaches patterns]
✅ 4 files archived (48 MB)

[Step 4/4] Git Commit
✅ Commit: abc1234

Workflow complete! 🎉
```

### With Critical Issues

```
User: /complete-work

[Steps 1-2 execute...]

[Step 2/4] Deep Review
🚨 Critical Issues Found

- silent-failure-hunter: Empty catch block (api.ts:42)
- pr-test-analyzer: No error tests (payment.ts)

What should I do?
1. Abort and fix manually
2. View full report
3. Continue anyway

User: 1

Workflow aborted.
✅ Memory saved
⏹️ Review complete (issues found)

Fix issues and re-run /complete-work when ready.
```

## Reference Files

Detailed guidance available in `references/`:

- **cleanup-patterns.md** - Pattern detection rules and heuristics
- **review-checklist.md** - Review requirements and severity criteria
- **promise-tags.md** - Complete promise tag reference

## Critical Rules

1. **Sequential Execution**: Launch agents one at a time, wait for results
2. **Promise Tags**: Always look for exactly one promise tag per agent
3. **Stop on Critical**: REVIEW_ISSUES_FOUND blocks workflow immediately
4. **State Cleanup**: Always clean up .claude/work-completion.local.md on finish
5. **User Control**: Never proceed with critical issues without explicit approval
6. **Pattern Persistence**: Ensure cleanup patterns are saved and reused

## Additional Resources

### Example Files

Working examples in `examples/`:

- **workflow-example.md** - Complete workflow execution with all 4 steps

These references provide detailed content while keeping this skill file focused on orchestration logic.