#!/usr/bin/env python3
"""
Injects validation history into validator agent context.
Enables learning from previous failures (Boris #13 feedback loop).
"""

import json
import sys
from pathlib import Path

MAX_CONTEXT_CHARS = 2000
STATE_FILE = Path.home() / ".claude" / "validation-loop.local.md"
LOG_FILE = Path.home() / ".claude" / "logs" / "validation-framework.log"

def read_state_file():
    """Read validation loop state"""
    if not STATE_FILE.exists():
        return None

    content = STATE_FILE.read_text()
    lines = content.split('\n')

    # Extract frontmatter
    if lines[0] != '---':
        return None

    frontmatter = {}
    for line in lines[1:]:
        if line == '---':
            break
        if ':' in line:
            key, value = line.split(':', 1)
            frontmatter[key.strip()] = value.strip()

    return frontmatter

def read_recent_logs(max_lines=20):
    """Read recent log entries"""
    if not LOG_FILE.exists():
        return ""

    lines = LOG_FILE.read_text().splitlines()
    recent = lines[-max_lines:] if len(lines) > max_lines else lines

    return '\n'.join(recent)

def build_context():
    """Build validation context"""
    parts = []

    # State file
    state = read_state_file()
    if state:
        parts.append(f"## Validation Loop State\n")
        parts.append(f"Iteration: {state.get('iteration', '?')}/{state.get('max_iterations', '?')}\n")
        parts.append(f"Temp Dir: {state.get('temp_dir', 'N/A')}\n")

    # Recent logs
    logs = read_recent_logs()
    if logs:
        parts.append(f"\n## Recent Activity\n```\n{logs}\n```")

    full_context = '\n'.join(parts)

    # Truncate if needed
    if len(full_context) > MAX_CONTEXT_CHARS:
        full_context = full_context[:MAX_CONTEXT_CHARS] + "\n... (truncated)"

    return full_context

def should_inject(tool_data):
    """Check if this is a validator call"""
    if tool_data.get('toolName') != 'Task':
        return False

    prompt = tool_data.get('prompt', '').lower()
    return 'validator' in prompt or 'validate' in prompt or STATE_FILE.exists()

def main():
    tool_data = json.loads(sys.stdin.read())

    if not should_inject(tool_data):
        print(json.dumps({}))
        return

    context = build_context()

    if not context:
        print(json.dumps({}))
        return

    result = {"additionalContext": context}
    print(json.dumps(result))

    # Debug log
    print(f"[Validation Hook] Injected {len(context)} chars", file=sys.stderr)

if __name__ == "__main__":
    main()
