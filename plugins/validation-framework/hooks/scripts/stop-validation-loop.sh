#!/bin/bash
set -euo pipefail

# === 설정 ===
STATE_FILE="$HOME/.claude/validation-loop.local.md"
LOG_FILE="$HOME/.claude/logs/validation-framework.log"
TEMP_DIR="$HOME/.claude/tmp/validation-$$"
MAX_ITERATIONS=10

# === 로그 함수 ⭐ ===
log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Stop Hook triggered ==="

# === 상태 파일 확인 ===
if [ ! -f "$STATE_FILE" ]; then
    log "First run - checking for failure"
    PROMISE=$(echo "$TRANSCRIPT" | grep -oP '<promise>\K[^<]+' | tail -1)

    if [ "$PROMISE" == "VALIDATION_FAILED" ]; then
        log "Validation failed on first run. Starting loop."
        mkdir -p "$TEMP_DIR"

        # 상태 파일 생성
        cat > "$STATE_FILE" <<EOF
---
iteration: 1
max_iterations: $MAX_ITERATIONS
temp_dir: $TEMP_DIR
log_file: $LOG_FILE
---
EOF

        # 환경 변수 설정
        export VALIDATION_IN_PROGRESS=true
        export VALIDATION_ITERATION=1

        log "State file created. Blocking for retry."

        # 세션 차단
        cat <<EOF
{
    "decision": "block",
    "reason": "Validation failed. Initiating retry loop.",
    "systemMessage": "🔄 Re-validation attempt 2/$MAX_ITERATIONS\n\nLogs: $LOG_FILE"
}
EOF
        exit 0
    fi

    log "First run succeeded or no promise. Exiting normally."
    exit 0
fi

# === 루프 중 ===
ITERATION=$(awk '/^iteration:/ {print $2}' "$STATE_FILE")
PROMISE=$(echo "$TRANSCRIPT" | grep -oP '<promise>\K[^<]+' | tail -1)

log "Loop iteration: $ITERATION, Promise: $PROMISE"

# === 성공 조건 ===
if [ "$PROMISE" == "VALIDATION_COMPLETE" ]; then
    log "✅ Validation succeeded after $((ITERATION + 1)) attempts!"

    # 정리 작업 ⭐
    rm -f "$STATE_FILE"
    log "State file deleted"

    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log "Temp directory deleted: $TEMP_DIR"
    fi

    # 환경 변수 정리 ⭐
    unset VALIDATION_IN_PROGRESS
    unset VALIDATION_ITERATION
    unset VALIDATION_TEMP_DIR

    log "All cleanup complete. Exiting normally."
    exit 0
fi

# === 최대 반복 확인 ===
if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    log "❌ Max iterations ($MAX_ITERATIONS) reached. Stopping."

    # 정리
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

# === 다음 반복 ===
NEXT_ITERATION=$((ITERATION + 1))
log "Continuing to iteration $NEXT_ITERATION"

# 상태 파일 업데이트
cat > "$STATE_FILE" <<EOF
---
iteration: $NEXT_ITERATION
max_iterations: $MAX_ITERATIONS
temp_dir: $TEMP_DIR
log_file: $LOG_FILE
---
EOF

# 환경 변수 업데이트
export VALIDATION_ITERATION=$NEXT_ITERATION

log "Blocking for retry $NEXT_ITERATION"

# 세션 차단
cat <<EOF
{
    "decision": "block",
    "reason": "Validation still failing. Continuing retry loop.",
    "systemMessage": "🔄 Re-validation attempt $((NEXT_ITERATION + 1))/$MAX_ITERATIONS\n\nLogs: $LOG_FILE"
}
EOF
