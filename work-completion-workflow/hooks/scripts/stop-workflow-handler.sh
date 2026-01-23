#!/bin/bash
# Work Completion Workflow - Stop Hook Handler
# Manages workflow state and blocks on critical review issues

set -eo pipefail

# ===== Configuration =====
STATE_FILE="${STATE_FILE:-$HOME/.claude/work-completion.local.md}"
LOG_FILE="${LOG_FILE:-$HOME/.claude/logs/work-completion.log}"

# ===== Logging Function =====
log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Stop Hook triggered ==="

# ===== Extract Promise Tag =====
# Look for <promise>TAG</promise> in transcript
PROMISE=$(echo "$TRANSCRIPT" | sed -n 's/.*<promise>\([^<]*\)<\/promise>.*/\1/p' | tail -1)

if [ -z "$PROMISE" ]; then
    log "No promise tag found, allowing continuation"
    exit 0
fi

log "Promise tag detected: $PROMISE"

# ===== Promise Tag Handling =====

case "$PROMISE" in
    "REVIEW_ISSUES_FOUND")
        # CRITICAL: Block workflow for user decision
        log "BLOCKING: Critical review issues found"

        cat <<EOF
{
  "decision": "block",
  "reason": "Critical review issues detected - user intervention required",
  "systemMessage": "🚨 Critical Issues Detected

The deep review found problems that need your attention before continuing.

Review the issues above and choose:
1. Abort workflow (fix issues manually)
2. View full review report
3. Continue anyway (not recommended)

What would you like to do?"
}
EOF
        ;;

    "WORKFLOW_COMPLETE")
        # SUCCESS: Clean up and exit
        log "✅ Workflow completed successfully"

        if [ -f "$STATE_FILE" ]; then
            rm -f "$STATE_FILE"
            log "State file cleaned up: $STATE_FILE"
        fi

        echo "✅ Work completion workflow finished"
        exit 0
        ;;

    "WORKFLOW_ABORTED")
        # USER ABORT: Clean up and report
        log "⚠️ Workflow aborted by user"

        if [ -f "$STATE_FILE" ]; then
            rm -f "$STATE_FILE"
            log "State file cleaned up: $STATE_FILE"
        fi

        echo "⚠️ Workflow aborted by user"
        exit 0
        ;;

    "MEMORY_UPDATE_FAILED")
        # ERROR: Stop workflow, don't clean up state (for retry)
        log "❌ Memory update failed, stopping workflow"

        cat <<EOF
{
  "decision": "block",
  "reason": "Memory update failed - cannot proceed",
  "systemMessage": "❌ Memory Update Failed

The workflow cannot continue without updating memory.

Please fix the issue (check file permissions, locks, etc.) and re-run /complete-work."
}
EOF
        ;;

    "COMMIT_FAILED")
        # ERROR: Partial completion, preserve state for retry
        log "❌ Commit failed, workflow incomplete"

        cat <<EOF
{
  "decision": "block",
  "reason": "Git commit failed",
  "systemMessage": "❌ Commit Failed

Most of the workflow completed successfully, but the final commit failed.

Check the error above (likely pre-commit hook or merge conflict).
Fix the issue and re-run /complete-work to retry the commit."
}
EOF
        ;;

    "MEMORY_UPDATED"|"REVIEW_COMPLETE"|"CLEANUP_APPROVED"|"CLEANUP_SKIPPED")
        # SUCCESS: Continue to next step
        log "✓ Step completed: $PROMISE, continuing workflow"
        exit 0
        ;;

    *)
        # UNKNOWN: Allow continuation (safety default)
        log "Unknown promise tag: $PROMISE, allowing continuation"
        exit 0
        ;;
esac
