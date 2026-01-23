---
name: validate
description: >
  This skill should be used when the user asks to "validate my code", "run tests",
  "check for errors", "run validation", uses the /validate command, or mentions
  code quality verification. Implements Boris Cherny's principle #13 for validation
  feedback loops that improve code quality 2-3x. Coordinates project-detector,
  validator, and report-generator agents.
examples:
  - "/validate"
  - "/validate test"
  - "validate my code"
  - "check for bugs"
  - "run all validations"
version: 1.0.0
---

# Validation Skill

Boris Cherny's 13번 원칙 구현: 검증 피드백 루프를 통한 품질 2~3배 향상

## Overview

This skill orchestrates the complete validation workflow by coordinating specialized agents:
- **project-detector**: Identifies project type and available validation commands
- **validator**: Executes validation and analyzes results
- **report-generator**: Formats results for user presentation

## Validation Workflow (Agent Orchestration)

### Step 1: Detect Project Type

Launch the **project-detector agent** to identify the project:

Use Task tool with:
- subagent_type: validation-framework:project-detector
- prompt: "Scan the current project and identify:
  - Project type (nodejs/python/rust/go)
  - Available validation commands (test/lint/typecheck/build)
  - Return structured JSON with findings"

Expected output: JSON with project info

### Step 2: Execute Validations

Launch the **validator agent** with project context:

Use Task tool with:
- subagent_type: validation-framework:validator
- prompt: "Execute validation for [project_type] project:
  - Run available commands: [commands_list]
  - Capture full output (stdout/stderr)
  - Extract file:line locations
  - Analyze Expected vs Received patterns
  - Identify root causes
  - Generate fix suggestions

  Project info: [JSON from step 1]"

**Important**: The validator implements Boris principle #13 by providing exact validation results, enabling self-correction.

Expected output: Structured validation results with failures

### Step 3: Generate User Report

Launch the **report-generator agent** with validation results:

Use Task tool with:
- subagent_type: validation-framework:report-generator
- prompt: "Create user-friendly validation report:
  - Summary with ✅/❌ status
  - Detailed failure information with locations
  - Actionable fix suggestions
  - Next steps and re-validation commands

  Validation data: [JSON from step 2]"

Expected output: Formatted markdown report

### Step 4: Handle Results

**On Success** (`<promise>VALIDATION_COMPLETE</promise>`):
- Stop Hook cleans up temporary files
- Memory system updates (progress.md)
- User receives success confirmation

**On Failure** (`<promise>VALIDATION_FAILED</promise>`):
- Stop Hook increments iteration counter
- Validation context injected for retry
- Automatic re-validation up to 10 times
- User sees detailed failure report

## Usage Examples

**Full validation**:
```
User: /validate
→ Runs all available validations
```

**Specific validation**:
```
User: /validate test
→ Runs only test suite
```

**After code changes**:
```
User: I just fixed the multiply function, please validate
→ Automatically triggers full validation
```

## Integration with Boris Principles

**Principle #13 Implementation**:
- ✅ Validation METHOD provided (bash commands)
- ✅ EXACT results captured (Expected vs Received)
- ✅ SELF-CORRECTION enabled (Claude sees output)
- ✅ FEEDBACK LOOP created (Stop Hook retry)
- ✅ QUALITY measured (pass rate tracking)

**Principle #12 Implementation**:
- ✅ Background processing with logging
- ✅ Stop Hook manages state and cleanup
- ✅ Temporary files cleaned up
- ✅ Environment variables isolated

## Additional Resources

### Reference Files

For detailed validation guidance, consult:

- **`references/project-types.md`** - Project type detection patterns
- **`references/validation-commands.md`** - Validation commands reference
- **`references/failure-patterns.md`** - Common failure patterns catalog

### Example Files

Working validation examples in `examples/`:

- **`nodejs-validation.md`** - Node.js/TypeScript validation workflow
- **`python-validation.md`** - Python validation workflow
