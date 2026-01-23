---
name: validate
description: Run validation framework with Boris principles #12 & #13 for 2-3x quality improvement
examples:
  - "/validate"
  - "/validate test"
  - "validate code"
  - "check for errors"
---

You are executing the `/validate` command. Your task is to invoke the `validate` skill using the Skill tool.

Use the Skill tool with:
- skill: "validation-framework:validate"

The skill will coordinate project-detector, validator, and report-generator agents to execute Boris Cherny's validation feedback loop.

Do NOT provide any explanation or introduction - immediately invoke the skill.

---

# Validate Command (Documentation)

Implements Boris Cherny's principle #13: Validation feedback loops for 2-3x quality improvement.

## Usage

```
/validate          # Auto-detect and run all validations
/validate test     # Run only test suite
/validate lint     # Run only linter
/validate type     # Run only type checker
```

## What This Does

This command triggers the `validate` skill which:

1. **Project Detection** (project-detector agent)
   - Scans project for validation tools
   - Detects: pytest, jest, eslint, mypy, tsc, etc.
   - Identifies test frameworks and configurations

2. **Validation Execution** (validator agent)
   - Runs detected validation tools
   - Captures output and exit codes
   - Tracks validation history

3. **Report Generation** (report-generator agent)
   - Aggregates results by severity
   - Generates user-friendly report
   - Compares with previous runs (improvement tracking)

## Validation Feedback Loop

**Boris Principle #13**: Validation should create a feedback loop:

```
Code → Validate → Fix Issues → Validate Again
  ↑                                      ↓
  └────────── Quality Improves 2-3x ─────┘
```

**Stop Hook Integration**:
- On validation failures: Prompts retry after fixes
- Tracks retry count and improvement
- Exits loop on success or user abort

## Example Output

**First Run**:
```
🔍 Detecting validation tools...
✓ Found: pytest, mypy, ruff

Running validations...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[pytest] ❌ 3 failed, 45 passed
  - test_api.py::test_auth_token FAILED
  - test_db.py::test_connection FAILED
  - test_util.py::test_parser FAILED

[mypy] ❌ 5 errors
  - src/api.py:42: Incompatible return type
  - src/db.py:15: Missing type annotation

[ruff] ✅ No issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary: 2 tools failed, 1 passed

Would you like to retry after fixing? (y/n)
```

**After Fixes**:
```
Running validations...

[pytest] ✅ All 48 tests passed (+3 fixed)
[mypy] ✅ No type errors (+5 fixed)
[ruff] ✅ No issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All validations passed!

Quality improved:
- Test coverage: 87% → 92% (+5%)
- Type safety: 5 errors → 0 (-100%)
- Retry count: 2 attempts

<promise>VALIDATION_SUCCESS</promise>
```

## Validation History

Tracked in: `.claude/validation-history.local.md`

```yaml
---
last_run: 2026-01-24T00:15:00Z
retry_count: 2
tools:
  pytest:
    status: passed
    improvement: +3 tests
  mypy:
    status: passed
    improvement: -5 errors
---
```

## Troubleshooting

**Validation tools not detected**:
- Ensure tools are installed and in PATH
- Check project root has config files (pytest.ini, .eslintrc, etc.)

**Retry loop stuck**:
```bash
# Force exit retry loop
rm ~/.claude/validation-loop.local.md
```

**False positives**:
- Configure tool-specific ignore rules
- Add to project's validation config files

## See Also

- Boris Cherny's Programming TypeScript (Principle #13)
- `/complete-work` - Includes validation as Step 2
