#!/bin/bash
# Plugin Integration Test Script
# Tests actual component behavior and integration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging
log_test() {
    echo -e "\n${YELLOW}▶${NC} Test: $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

log_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "  ${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Plugin Integration Test Suite"
echo "Repository: $REPO_ROOT"
echo ""

# Find plugins
PLUGINS=()
for dir in */; do
    if [ -f "${dir}.claude-plugin/plugin.json" ]; then
        PLUGINS+=("${dir%/}")
    fi
done

echo "Testing ${#PLUGINS[@]} plugin(s): ${PLUGINS[*]}"

# Test each plugin
for PLUGIN in "${PLUGINS[@]}"; do
    log_section "Testing: $PLUGIN"

    cd "$REPO_ROOT/$PLUGIN"

    # ========================================
    # Test: Stop Hook Promise Tag Parsing
    # ========================================
    if [ -f "hooks/scripts/stop-workflow-handler.sh" ]; then
        log_test "Stop Hook: Promise tag parsing"

        # Test REVIEW_ISSUES_FOUND
        RESULT=$(echo "<promise>REVIEW_ISSUES_FOUND</promise>" | \
                 TRANSCRIPT="$(cat)" \
                 bash hooks/scripts/stop-workflow-handler.sh 2>/dev/null || true)

        if echo "$RESULT" | grep -q '"decision": "block"'; then
            log_pass "REVIEW_ISSUES_FOUND blocks workflow"
        else
            log_fail "REVIEW_ISSUES_FOUND should block workflow"
        fi

        # Test WORKFLOW_COMPLETE (should clean up state file)
        log_test "Stop Hook: State cleanup on completion"

        # Create dummy state file
        TEMP_STATE=$(mktemp)
        echo "test state" > "$TEMP_STATE"

        # Modify hook to use temp state file for testing
        RESULT=$(echo "<promise>WORKFLOW_COMPLETE</promise>" | \
                 TRANSCRIPT="$(cat)" \
                 STATE_FILE="$TEMP_STATE" \
                 bash hooks/scripts/stop-workflow-handler.sh 2>/dev/null || true)

        if [ ! -f "$TEMP_STATE" ]; then
            log_pass "WORKFLOW_COMPLETE cleans up state file"
        else
            log_fail "WORKFLOW_COMPLETE should delete state file"
            rm -f "$TEMP_STATE"
        fi

        # Test unknown promise (should allow continuation)
        log_test "Stop Hook: Unknown promise tags allow continuation"

        EXIT_CODE=0
        echo "<promise>UNKNOWN_TAG</promise>" | \
            TRANSCRIPT="$(cat)" \
            bash hooks/scripts/stop-workflow-handler.sh &>/dev/null || EXIT_CODE=$?

        if [ $EXIT_CODE -eq 0 ]; then
            log_pass "Unknown promise allows continuation"
        else
            log_fail "Unknown promise should allow continuation"
        fi
    fi

    # ========================================
    # Test: Agent File Structure
    # ========================================
    if [ -d "agents" ]; then
        for agent_file in agents/*.md; do
            if [ -f "$agent_file" ]; then
                AGENT_NAME=$(basename "$agent_file" .md)

                log_test "Agent: $AGENT_NAME frontmatter parsing"

                # Extract frontmatter
                FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d')

                if echo "$FRONTMATTER" | grep -q "agent_name:"; then
                    log_pass "Has agent_name field"
                else
                    log_fail "Missing agent_name field"
                fi

                if echo "$FRONTMATTER" | grep -q "description:"; then
                    log_pass "Has description field"
                else
                    log_fail "Missing description field"
                fi

                if echo "$FRONTMATTER" | grep -q "tools:"; then
                    log_pass "Has tools field"
                else
                    log_fail "Missing tools field"
                fi

                # Check for system prompt (content after frontmatter)
                CONTENT_LINES=$(tail -n +$(grep -n "^---$" "$agent_file" | tail -1 | cut -d: -f1) "$agent_file" | wc -l)
                if [ "$CONTENT_LINES" -gt 10 ]; then
                    log_pass "Has system prompt content"
                else
                    log_fail "System prompt seems too short"
                fi
            fi
        done
    fi

    # ========================================
    # Test: Skill Structure
    # ========================================
    if [ -d "skills" ]; then
        for skill_dir in skills/*/; do
            if [ -f "${skill_dir}SKILL.md" ]; then
                SKILL_NAME=$(basename "$skill_dir")

                log_test "Skill: $SKILL_NAME structure"

                # Check frontmatter
                if head -n 1 "${skill_dir}SKILL.md" | grep -q "^---$"; then
                    log_pass "Has valid frontmatter"
                else
                    log_fail "Missing or invalid frontmatter"
                fi

                # Check for name and description
                if grep -q "^name:" "${skill_dir}SKILL.md"; then
                    log_pass "Has name field"
                else
                    log_fail "Missing name field"
                fi

                if grep -q "^description:" "${skill_dir}SKILL.md"; then
                    # Extract full description (may be multiline with >)
                    DESCRIPTION=$(sed -n '/^description:/,/^[a-z_]*:/p' "${skill_dir}SKILL.md" | sed '$d')
                    if echo "$DESCRIPTION" | grep -qi "should be used when"; then
                        log_pass "Description includes trigger conditions"
                    else
                        log_fail "Description should include 'should be used when'"
                    fi
                else
                    log_fail "Missing description field"
                fi

                # Check for examples
                if grep -q "^examples:" "${skill_dir}SKILL.md"; then
                    log_pass "Has examples field"
                else
                    log_fail "Missing examples field"
                fi

                # Check references directory
                if [ -d "${skill_dir}references" ]; then
                    REF_COUNT=$(find "${skill_dir}references" -name "*.md" | wc -l)
                    if [ "$REF_COUNT" -gt 0 ]; then
                        log_pass "Has references/ with $REF_COUNT file(s)"
                    else
                        log_fail "references/ exists but is empty"
                    fi
                fi

                # Check examples directory
                if [ -d "${skill_dir}examples" ]; then
                    EX_COUNT=$(find "${skill_dir}examples" -name "*.md" | wc -l)
                    if [ "$EX_COUNT" -gt 0 ]; then
                        log_pass "Has examples/ with $EX_COUNT file(s)"
                    else
                        log_fail "examples/ exists but is empty"
                    fi
                fi
            fi
        done
    fi

    # ========================================
    # Test: Command Structure
    # ========================================
    if [ -d "commands" ]; then
        for cmd_file in commands/*.md; do
            if [ -f "$cmd_file" ]; then
                CMD_NAME=$(basename "$cmd_file" .md)

                log_test "Command: $CMD_NAME structure"

                # Check frontmatter
                if head -n 1 "$cmd_file" | grep -q "^---$"; then
                    log_pass "Has frontmatter"

                    if grep -q "^name:" "$cmd_file"; then
                        log_pass "Has name field"
                    else
                        log_fail "Missing name field"
                    fi

                    if grep -q "^description:" "$cmd_file"; then
                        log_pass "Has description field"
                    else
                        log_fail "Missing description field"
                    fi
                else
                    log_fail "Missing frontmatter"
                fi
            fi
        done
    fi

    # ========================================
    # Test: Hook Configuration
    # ========================================
    if [ -f "hooks/hooks.json" ]; then
        log_test "Hook configuration validity"

        if command -v jq &> /dev/null; then
            # Validate JSON
            if jq empty "hooks/hooks.json" 2>/dev/null; then
                log_pass "Valid JSON syntax"

                # Check hooks array
                HOOK_COUNT=$(jq '.hooks | length' "hooks/hooks.json")
                if [ "$HOOK_COUNT" -gt 0 ]; then
                    log_pass "Has $HOOK_COUNT hook(s) configured"

                    # Validate each hook
                    for i in $(seq 0 $((HOOK_COUNT - 1))); do
                        EVENT=$(jq -r ".hooks[$i].event" "hooks/hooks.json")
                        SCRIPT=$(jq -r ".hooks[$i].script" "hooks/hooks.json")

                        if [ -n "$EVENT" ]; then
                            log_pass "Hook $((i+1)): Has event ($EVENT)"
                        else
                            log_fail "Hook $((i+1)): Missing event field"
                        fi

                        if [ -n "$SCRIPT" ] && [ "$SCRIPT" != "null" ]; then
                            SCRIPT_PATH="hooks/$SCRIPT"
                            if [ -f "$SCRIPT_PATH" ]; then
                                log_pass "Hook $((i+1)): Script exists ($SCRIPT)"

                                if [ -x "$SCRIPT_PATH" ]; then
                                    log_pass "Hook $((i+1)): Script is executable"
                                else
                                    log_fail "Hook $((i+1)): Script not executable"
                                fi
                            else
                                log_fail "Hook $((i+1)): Script not found ($SCRIPT)"
                            fi
                        fi
                    done
                else
                    log_fail "hooks.json exists but has no hooks"
                fi
            else
                log_fail "Invalid JSON syntax"
            fi
        else
            log_fail "jq not installed, cannot validate hooks.json"
        fi
    fi

    echo ""
done

# Summary
cd "$REPO_ROOT"
log_section "Integration Test Summary"
echo "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    PASS_RATE=100
else
    PASS_RATE=$((TESTS_PASSED * 100 / TESTS_RUN))
fi

echo "Pass rate: ${PASS_RATE}%"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All integration tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ $TESTS_FAILED test(s) failed${NC}"
    exit 1
fi
