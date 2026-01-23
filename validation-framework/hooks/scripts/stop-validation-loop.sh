#!/bin/bash
# Validation Framework - Stop Hook Handler
# Manages validation loop state and cleanup (Boris principle #12)

set -eo pipefail

# ===== Configuration =====
STATE_FILE="${STATE_FILE:-$HOME/.claude/validation-loop.local.md}"
LOG_FILE="${LOG_FILE:-$HOME/.claude/logs/validation-framework.log}"
TEMP_DIR="${TEMP_DIR:-$HOME/.claude/tmp/validation-$$}"
MAX_ITERATIONS=10

# ===== Logging Function =====
log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Stop Hook triggered ==="

# ===== Extract Promise Tag =====
PROMISE=$(echo "$TRANSCRIPT" | sed -n 's/.*<promise>\([^<]*\)<\/promise>.*/\1/p' | tail -1)

if [ -z "$PROMISE" ]; then
    log "No promise tag found, allowing continuation"
    exit 0
fi

log "Promise tag detected: $PROMISE"

# ===== First Run Check =====
if [ ! -f "$STATE_FILE" ]; then
    log "First run - checking for failure"

    if [ "$PROMISE" == "VALIDATION_FAILED" ]; then
        log "Validation failed on first run. Starting loop."
        mkdir -p "$TEMP_DIR"

        # Create state file
        cat > "$STATE_FILE" <<EOF
---
iteration: 1
max_iterations: $MAX_ITERATIONS
temp_dir: $TEMP_DIR
log_file: $LOG_FILE
---
EOF

        # Set environment variables
        export VALIDATION_IN_PROGRESS=true
        export VALIDATION_ITERATION=1

        log "State file created. Blocking for retry."

        # Block session
        cat <<EOF
{
    "decision": "block",
    "reason": "Validation failed. Initiating retry loop.",
    "systemMessage": "🔄 Re-validation attempt 2/$MAX_ITERATIONS\n\nLogs: $LOG_FILE"
}
EOF
        exit 0
    fi

    log "First run succeeded or no validation promise. Exiting normally."
    exit 0
fi

# ===== Loop In Progress =====
ITERATION=$(awk '/^iteration:/ {print $2}' "$STATE_FILE")

log "Loop iteration: $ITERATION, Promise: $PROMISE"

# ===== Success Condition =====
if [ "$PROMISE" == "VALIDATION_COMPLETE" ]; then
    log "✅ Validation succeeded after $((ITERATION + 1)) attempts!"

    # Cleanup
    rm -f "$STATE_FILE"
    log "State file deleted"

    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log "Temp directory deleted: $TEMP_DIR"
    fi

    # Unset environment variables
    unset VALIDATION_IN_PROGRESS
    unset VALIDATION_ITERATION
    unset VALIDATION_TEMP_DIR

    log "All cleanup complete. Exiting normally."
    exit 0
fi

# ===== Max Iterations Check =====
if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    log "❌ Max iterations ($MAX_ITERATIONS) reached. Stopping."

    # Cleanup
    rm -f "$STATE_FILE"
    rm -rf "$TEMP_DIR"

    log "Loop stopped. Manual intervention required."

    cat <<EOF
{
    "decision": "allow",
    "reason": "Max validation attempts reached.",
    "systemMessage": "⚠️ Validation stopped after $MAX_ITERATIONS attempts.\n\nLogs: $LOG_FILE"
}
EOF
    exit 0
fi

# ===== Continue Loop =====
NEXT_ITERATION=$((ITERATION + 1))
log "Continuing to iteration $NEXT_ITERATION"

# Update state file
cat > "$STATE_FILE" <<EOF
---
iteration: $NEXT_ITERATION
max_iterations: $MAX_ITERATIONS
temp_dir: $TEMP_DIR
log_file: $LOG_FILE
---
EOF

# Update environment variables
export VALIDATION_ITERATION=$NEXT_ITERATION

log "Blocking for retry $NEXT_ITERATION"

# Block session
cat <<EOF
{
    "decision": "block",
    "reason": "Validation still failing. Continuing retry loop.",
    "systemMessage": "🔄 Re-validation attempt $((NEXT_ITERATION + 1))/$MAX_ITERATIONS\n\nLogs: $LOG_FILE"
}
EOF
