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

**Critical**: In Claude Code 2.1.0, simply mentioning agent names in this skill body
will cause Claude to automatically use the Task tool to invoke them. No explicit
tool calls needed in skill YAML.

## Validation Workflow (Agent Orchestration)

**Critical Pattern:** This skill orchestrates multiple agents in sequence. Each step uses the Task tool to launch the appropriate agent.

### Step 1: Detect Project Type

Launch the **project-detector agent** to identify the project:

```
Use Task tool to call project-detector agent with prompt:
"Scan the current project and identify:
- Project type (nodejs/python/rust/go)
- Available validation commands (test/lint/typecheck/build)
- Return structured JSON with findings"
```

Expected output: JSON with project info

### Step 2: Execute Validations

Launch the **validator agent** with project context:

```
Use Task tool to call validator agent with prompt:
"Execute validation for [project_type] project:
- Run available commands: [commands_list]
- Capture full output (stdout/stderr)
- Extract file:line locations
- Analyze Expected vs Received patterns
- Identify root causes
- Generate fix suggestions

Project info: [JSON from step 1]"
```

**Important**: The validator implements Boris principle #13 by providing exact validation results, enabling self-correction.

Expected output: Structured validation results with failures

### Step 3: Generate User Report

Launch the **report-generator agent** with validation results:

```
Use Task tool to call report-generator agent with prompt:
"Create user-friendly validation report:
- Summary with ✅/❌ status
- Detailed failure information with locations
- Actionable fix suggestions
- Next steps and re-validation commands

Validation data: [JSON from step 2]"
```

Expected output: Formatted markdown report

**Pattern Notes:**
- Each agent launch is explicit via Task tool
- Agents don't call each other - skill orchestrates
- Data flows through skill (project info → validator → report generator)
- Similar to feature-dev's "Launch 2-3 agents in parallel" pattern, but sequential

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

- **`references/project-types.md`** - Comprehensive guide to detecting different project types (Node.js, Python, Rust, Go) with specific configuration file patterns and validation command extraction methods

- **`references/validation-commands.md`** - Complete reference of validation commands across ecosystems: test runners (Jest, pytest, cargo test), linters (ESLint, Ruff, clippy), type checkers (tsc, mypy), and build tools with their common configurations and flags

- **`references/failure-patterns.md`** - Catalog of common validation failure patterns with Expected vs Received examples, root cause analysis techniques, file:line:column extraction methods, and fix suggestion templates for different error types

### Example Files

Working validation examples in `examples/`:

- **`nodejs-validation.md`** - Complete validation workflow for a TypeScript/Node.js project showing npm test, eslint, tsc --noEmit, and npm run build with real error output and analysis

- **`python-validation.md`** - Complete validation workflow for a Python project showing pytest, ruff check, and mypy with real error output and analysis

These references provide detailed content while keeping this skill file lean and focused.
