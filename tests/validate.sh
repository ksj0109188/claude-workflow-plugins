#!/bin/bash
# Plugin Structure Validation Script
# Validates plugin.json, directory structure, and file formats

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0

# Logging functions
log_pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASS=$((PASS + 1))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    FAIL=$((FAIL + 1))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Get repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Plugin Validation Script"
echo "Repository: $REPO_ROOT"
echo ""

# Find all plugins (directories with .claude-plugin/plugin.json)
PLUGINS=()
for dir in */; do
    if [ -f "${dir}.claude-plugin/plugin.json" ]; then
        PLUGINS+=("${dir%/}")
    fi
done

if [ ${#PLUGINS[@]} -eq 0 ]; then
    log_fail "No plugins found in repository"
    exit 1
fi

echo "Found ${#PLUGINS[@]} plugin(s): ${PLUGINS[*]}"

# Validate each plugin
for PLUGIN in "${PLUGINS[@]}"; do
    log_section "Validating: $PLUGIN"

    cd "$REPO_ROOT/$PLUGIN"

    # Check plugin.json exists
    if [ ! -f ".claude-plugin/plugin.json" ]; then
        log_fail "Missing .claude-plugin/plugin.json"
        continue
    fi
    log_pass "Found .claude-plugin/plugin.json"

    # Validate JSON syntax
    if command -v jq &> /dev/null; then
        if jq empty ".claude-plugin/plugin.json" 2>/dev/null; then
            log_pass "Valid JSON syntax"
        else
            log_fail "Invalid JSON syntax in plugin.json"
            continue
        fi

        # Check required fields
        NAME=$(jq -r '.name // empty' ".claude-plugin/plugin.json")
        VERSION=$(jq -r '.version // empty' ".claude-plugin/plugin.json")
        DESCRIPTION=$(jq -r '.description // empty' ".claude-plugin/plugin.json")

        if [ -n "$NAME" ]; then
            log_pass "Has 'name' field: $NAME"
        else
            log_fail "Missing 'name' field in plugin.json"
        fi

        if [ -n "$VERSION" ]; then
            log_pass "Has 'version' field: $VERSION"
        else
            log_fail "Missing 'version' field in plugin.json"
        fi

        if [ -n "$DESCRIPTION" ]; then
            log_pass "Has 'description' field"
        else
            log_warn "Missing 'description' field in plugin.json"
        fi
    else
        log_warn "jq not installed, skipping JSON validation"
    fi

    # Check README.md
    if [ -f "README.md" ]; then
        log_pass "Has README.md"

        # Check for essential sections
        if grep -q "## Features" README.md || grep -q "## Usage" README.md; then
            log_pass "README has documentation sections"
        else
            log_warn "README missing standard sections (Features, Usage)"
        fi
    else
        log_warn "Missing README.md"
    fi

    # Validate agents/ directory
    if [ -d "agents" ]; then
        AGENT_COUNT=$(find agents -name "*.md" | wc -l)
        if [ "$AGENT_COUNT" -gt 0 ]; then
            log_pass "Has $AGENT_COUNT agent(s)"

            # Check each agent file
            for agent_file in agents/*.md; do
                if [ -f "$agent_file" ]; then
                    # Check for frontmatter
                    if head -n 1 "$agent_file" | grep -q "^---$"; then
                        log_pass "$(basename "$agent_file"): Has frontmatter"

                        # Extract and validate frontmatter fields
                        if grep -q "^agent_name:" "$agent_file"; then
                            log_pass "$(basename "$agent_file"): Has agent_name"
                        else
                            log_fail "$(basename "$agent_file"): Missing agent_name"
                        fi

                        if grep -q "^description:" "$agent_file"; then
                            log_pass "$(basename "$agent_file"): Has description"
                        else
                            log_fail "$(basename "$agent_file"): Missing description"
                        fi
                    else
                        log_fail "$(basename "$agent_file"): Missing frontmatter"
                    fi
                fi
            done
        else
            log_warn "agents/ directory exists but is empty"
        fi
    fi

    # Validate skills/ directory
    if [ -d "skills" ]; then
        SKILL_COUNT=$(find skills -name "SKILL.md" | wc -l)
        if [ "$SKILL_COUNT" -gt 0 ]; then
            log_pass "Has $SKILL_COUNT skill(s)"

            # Check each SKILL.md
            for skill_file in skills/*/SKILL.md; do
                if [ -f "$skill_file" ]; then
                    SKILL_NAME=$(dirname "$skill_file" | xargs basename)

                    # Check for frontmatter
                    if head -n 1 "$skill_file" | grep -q "^---$"; then
                        log_pass "$SKILL_NAME: Has frontmatter"

                        # Check required fields
                        if grep -q "^name:" "$skill_file"; then
                            log_pass "$SKILL_NAME: Has name field"
                        else
                            log_fail "$SKILL_NAME: Missing name field"
                        fi

                        if grep -q "^description:" "$skill_file"; then
                            log_pass "$SKILL_NAME: Has description field"
                        else
                            log_fail "$SKILL_NAME: Missing description field"
                        fi
                    else
                        log_fail "$SKILL_NAME: Missing frontmatter"
                    fi

                    # Check for references/ and examples/ directories
                    SKILL_DIR=$(dirname "$skill_file")
                    if [ -d "$SKILL_DIR/references" ]; then
                        REF_COUNT=$(find "$SKILL_DIR/references" -name "*.md" | wc -l)
                        log_pass "$SKILL_NAME: Has references/ ($REF_COUNT files)"
                    fi

                    if [ -d "$SKILL_DIR/examples" ]; then
                        EX_COUNT=$(find "$SKILL_DIR/examples" -name "*.md" | wc -l)
                        log_pass "$SKILL_NAME: Has examples/ ($EX_COUNT files)"
                    fi
                fi
            done
        else
            log_warn "skills/ directory exists but has no SKILL.md files"
        fi
    fi

    # Validate commands/ directory
    if [ -d "commands" ]; then
        CMD_COUNT=$(find commands -name "*.md" | wc -l)
        if [ "$CMD_COUNT" -gt 0 ]; then
            log_pass "Has $CMD_COUNT command(s)"

            # Check each command file
            for cmd_file in commands/*.md; do
                if [ -f "$cmd_file" ]; then
                    CMD_NAME=$(basename "$cmd_file" .md)

                    # Check for frontmatter
                    if head -n 1 "$cmd_file" | grep -q "^---$"; then
                        log_pass "$CMD_NAME: Has frontmatter"

                        if grep -q "^name:" "$cmd_file"; then
                            log_pass "$CMD_NAME: Has name field"
                        else
                            log_fail "$CMD_NAME: Missing name field"
                        fi
                    else
                        log_fail "$CMD_NAME: Missing frontmatter"
                    fi
                fi
            done
        else
            log_warn "commands/ directory exists but is empty"
        fi
    fi

    # Validate hooks/ directory
    if [ -d "hooks" ]; then
        if [ -f "hooks/hooks.json" ]; then
            log_pass "Has hooks/hooks.json"

            # Validate JSON
            if command -v jq &> /dev/null; then
                if jq empty "hooks/hooks.json" 2>/dev/null; then
                    log_pass "hooks.json: Valid JSON"
                else
                    log_fail "hooks.json: Invalid JSON syntax"
                fi
            fi

            # Check for hook scripts
            if [ -d "hooks/scripts" ]; then
                SCRIPT_COUNT=$(find hooks/scripts -type f -name "*.sh" -o -name "*.py" | wc -l)
                if [ "$SCRIPT_COUNT" -gt 0 ]; then
                    log_pass "Has $SCRIPT_COUNT hook script(s)"

                    # Check script permissions
                    for script in hooks/scripts/*; do
                        if [ -f "$script" ]; then
                            if [ -x "$script" ]; then
                                log_pass "$(basename "$script"): Executable"
                            else
                                log_fail "$(basename "$script"): Not executable (run: chmod +x $script)"
                            fi
                        fi
                    done
                fi
            fi
        else
            log_warn "hooks/ directory exists but missing hooks.json"
        fi
    fi

    echo ""
done

# Summary
cd "$REPO_ROOT"
log_section "Validation Summary"
echo "Plugins validated: ${#PLUGINS[@]}"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}✓ All validations passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ $FAIL validation(s) failed${NC}"
    exit 1
fi
