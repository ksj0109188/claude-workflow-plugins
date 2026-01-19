---
description: Run validation checks on the current project (tests, lint, typecheck, build). Implements Boris Cherny's principle #13 for 2-3x quality improvement.
argument-hint: "[test|lint|typecheck|build]"
allowed-tools: ["Skill"]
---

# Validate Command

Run comprehensive validation checks on the current project.

**What this command does:**
- Automatically detects project type (Node.js, Python, Rust, Go)
- Runs available validation commands (tests, lint, typecheck, build)
- Analyzes failures with exact file:line locations
- Provides specific fix suggestions
- Auto-retries up to 10 times on failures (Boris principle #13)

**Usage:**
- `/validate` - Run all available validations
- `/validate test` - Run only tests
- `/validate lint` - Run only linting
- `/validate typecheck` - Run only type checking
- `/validate build` - Run only build

**Workflow:**
When invoked, use the Skill tool to call the "validate" skill. The skill will automatically:
1. Detect project type and available validation commands
2. Execute validations and capture full output
3. Analyze failures (Expected vs Received, file:line)
4. Generate user-friendly report with fix suggestions
5. Trigger automatic retry loop if failures detected (Stop Hook)

**For Claude:** Invoke the validate skill using the Skill tool. Pass any command arguments to the skill. The skill handles the complete validation workflow by orchestrating project-detector, validator, and report-generator agents.

**Example invocation:**
```
Use Skill tool with:
- skill: "validate"
- args: "[user's argument if provided]"
```

The skill will take over and manage the entire validation process.
