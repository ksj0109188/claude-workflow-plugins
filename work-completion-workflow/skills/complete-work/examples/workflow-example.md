# Complete Workflow Example

Real-world example of the complete work workflow from start to finish.

## Scenario

Developer has been working on a session to:
1. Fix error handling bugs
2. Improve type design
3. Update documentation

Now ready to complete work and commit changes.

## Execution Trace

### User Initiates Workflow

```
User: /complete-work
```

### Orchestrator Starts

```markdown
Starting work completion workflow...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This workflow will:
1. Update project memory (.claude/memory/)
2. Run deep code review (6 agents)
3. Clean up old files with pattern learning
4. Create git commit

Let's begin!
```

---

## Step 1: Memory Update

### Agent Launches

```markdown
[Step 1/4] Memory Update

Launching memory-updater agent...
```

### Memory Updater Executes

```markdown
Executing /update-memory workflow...

Scanning git-tracked .md files...
✓ Found 3 new/modified files:
  - docs/ERROR_HANDLING_GUIDE.md (created 2 hours ago)
  - docs/TYPE_DESIGN_NOTES.md (modified 1 hour ago)
  - IMPLEMENTATION_LOG.md (modified 30 minutes ago)

Which files should I integrate into memory?

Options:
1. decisions.md ← docs/ERROR_HANDLING_GUIDE.md
2. decisions.md ← docs/TYPE_DESIGN_NOTES.md
3. progress.md ← IMPLEMENTATION_LOG.md
4. Skip all
```

### User Selects

```
User: 1,2,3
```

### Memory Updated

```markdown
Integrating selected files...

✓ decisions.md updated
  + Added: "Error Handling Best Practices" (from ERROR_HANDLING_GUIDE.md)
  + Current: 45/160 lines (28% capacity)

✓ decisions.md updated
  + Added: "Type Design Patterns" (from TYPE_DESIGN_NOTES.md)
  + Current: 52/160 lines (33% capacity)

✓ progress.md updated
  + Added session summary (from IMPLEMENTATION_LOG.md)
  + Current: 78/120 lines (65% capacity)

All memory files within limits ✓

<promise>MEMORY_UPDATED</promise>
```

### Orchestrator Continues

```markdown
[Step 1/4] ✅ Memory Update Complete

- 2 decisions documented
- 1 progress entry added
- 3 .md files integrated

Proceeding to Step 2...
```

---

## Step 2: Deep Code Review

### Agent Launches

```markdown
[Step 2/4] Deep Code Review

Launching deep-reviewer agent...

Analyzing git diff (unstaged + staged changes)...
```

### Deep Reviewer Executes

```markdown
Executing comprehensive code review...

Changes detected:
- 5 files modified
- 15 functions changed
- 3 new types added

Launching review agents sequentially...
```

#### Agent 1: code-reviewer

```markdown
[1/6] code-reviewer

✓ Analyzed 5 changed files
✓ Checked CLAUDE.md compliance

Findings (confidence ≥ 80%):
- 2 medium-severity issues (code style)
- No critical issues

Example:
- api/client.ts:42 - Consider more descriptive variable name (conf: 85%)
```

#### Agent 2: silent-failure-hunter

```markdown
[2/6] silent-failure-hunter

Analyzing error handling in git diff...

✓ Scanned 12 try-catch blocks
✓ Checked error propagation

Findings:
- 1 CRITICAL issue found
- 2 MEDIUM issues found

CRITICAL:
- api/client.ts:156 - Empty catch block in payment processing

MEDIUM:
- utils/validator.ts:23 - Generic error handling
- services/auth.ts:45 - Inadequate error logging
```

#### Agent 3: pr-test-analyzer

```markdown
[3/6] pr-test-analyzer

Analyzing test coverage for changes...

✓ Checked tests for 5 modified files
✓ Identified gaps in coverage

Findings:
- 1 critical gap (rating: 9/10)
- 2 minor gaps (rating: 5-6/10)

CRITICAL (rating 9):
- services/payment.ts:128 - No error handling tests
  Missing: network failures, invalid cards, API errors

MINOR (rating 5):
- utils/format.ts - Missing edge case tests
```

#### Agent 4: type-design-analyzer

```markdown
[4/6] type-design-analyzer

Checking for new/modified types...

$ git diff --unified=0 | grep -E "^\+.*\b(type|interface|class)\s"

Found 3 new types:
- types/user.ts:12 - UserAccount (interface)
- types/payment.ts:45 - PaymentResult (type alias)
- models/order.ts:78 - Order (class)

Analyzing type design quality...

UserAccount (types/user.ts:12):
- Encapsulation: 3/10 (all fields public)
- Invariant Expression: 7/10 (good)
- Usefulness: 8/10 (good)
- Enforcement: 6/10 (decent)

Issue: Weak encapsulation - passwordHash field exposed

PaymentResult (types/payment.ts:45):
- All dimensions: 8-10/10 (well-designed)

Order (models/order.ts:78):
- All dimensions: 9-10/10 (excellent)

Findings:
- 1 important issue (UserAccount encapsulation)
```

#### Agent 5: comment-analyzer

```markdown
[5/6] comment-analyzer

Checking for modified comments...

$ git diff --unified=0 | grep -E "^\+.*(//|/\*)"

Found 8 new/modified comments

Analyzing comment accuracy...

✓ 6 comments accurate
⚠️ 2 potential issues

Issues:
- api/client.ts:42 - Comment mentions ID, function uses email
- utils/validator.ts:78 - Comment says "validates all", only validates format

Findings:
- 2 comment accuracy issues (important)
```

#### Agent 6: code-simplifier

```markdown
[6/6] code-simplifier

Checking for critical issues before suggesting refactoring...

Critical issues detected:
- silent-failure-hunter: 1 CRITICAL
- pr-test-analyzer: 1 gap (rating 9)

⊙ Skipping code-simplifier (unsafe to suggest refactoring with critical issues)
```

### Aggregation & Decision

```markdown
Aggregating findings from all agents...

Critical Issues (2):
1. silent-failure-hunter: Empty catch in payment processing (api/client.ts:156)
2. pr-test-analyzer: No error tests for payment service (rating 9/10)

Important Issues (3):
1. type-design-analyzer: UserAccount weak encapsulation (3/10)
2. comment-analyzer: Misleading comment (api/client.ts:42)
3. comment-analyzer: Inaccurate comment (utils/validator.ts:78)

Suggestions (0):
- code-simplifier skipped due to critical issues

Decision: CRITICAL ISSUES FOUND → BLOCK WORKFLOW

<promise>REVIEW_ISSUES_FOUND</promise>
```

### Stop Hook Blocks

```json
{
  "decision": "block",
  "reason": "Critical review issues detected",
  "systemMessage": "🚨 Critical Issues Detected\n\nThe deep review found 2 critical issues:\n\n1. Empty catch block in payment processing\n2. No error handling tests for payment service\n\nThese must be addressed before committing.\n\nWhat would you like to do?\n1. Abort workflow and fix manually\n2. View full review report\n3. Continue anyway (not recommended)"
}
```

### User Decides

```markdown
User: 2 (View full report)
```

### Full Report Displayed

```markdown
# Deep Review Report

## Critical Issues (2 found) 🚨

### Issue 1: Empty catch block in payment processing
- **Agent**: silent-failure-hunter
- **File**: api/client.ts:156
- **Severity**: CRITICAL
- **Confidence**: 100%
- **Issue**: Error swallowed with no logging or recovery in payment-critical code
- **Code**:
  ```typescript
  try {
    const charge = await stripe.charges.create({
      amount: amount * 100,
      currency: 'usd',
      source: cardToken
    });
  } catch (err) {
    // TODO: handle error
  }
  return { success: true };  // Returns success even if failed!
  ```
- **Fix**: Add proper error handling and propagation
  ```typescript
  try {
    const charge = await stripe.charges.create({...});
    return { success: true, chargeId: charge.id };
  } catch (err) {
    logger.error('Payment failed:', {
      error: err,
      amount,
      cardToken: cardToken.slice(0, 8) + '...'
    });
    throw new PaymentError('Failed to process payment', { cause: err });
  }
  ```

### Issue 2: Missing error handling tests for payment service
- **Agent**: pr-test-analyzer
- **File**: services/payment.ts:128
- **Gap Rating**: 9/10 (CRITICAL)
- **Issue**: Payment processing has comprehensive happy-path tests but zero error scenario coverage
- **Current Coverage**:
  - ✅ Successful charge
  - ✅ Successful refund
  - ❌ Network failures (0 tests)
  - ❌ Invalid card data (0 tests)
  - ❌ Insufficient funds (0 tests)
  - ❌ Stripe API errors (0 tests)
- **Risk**: Production payment failures not tested
- **Fix**: Add comprehensive error tests
  ```typescript
  describe('PaymentService - Error Handling', () => {
    it('should handle network failures gracefully', async () => {
      stripe.charges.create.mockRejectedValue(new NetworkError());
      await expect(paymentService.charge(100, 'tok_123'))
        .rejects.toThrow(PaymentError);
    });

    it('should handle invalid card data', async () => {
      stripe.charges.create.mockRejectedValue({ type: 'card_error' });
      const result = await paymentService.charge(100, 'tok_invalid');
      expect(result.success).toBe(false);
      expect(result.error).toContain('Invalid card');
    });

    // ... more error tests
  });
  ```

---

## Important Issues (3 found) ⚠️

### Issue 1: Weak type encapsulation
- **Agent**: type-design-analyzer
- **File**: types/user.ts:12
- **Dimension**: Encapsulation
- **Rating**: 3/10
- **Issue**: UserAccount interface exposes sensitive fields publicly
- **Code**:
  ```typescript
  interface UserAccount {
    id: string;
    email: string;
    passwordHash: string;  // ❌ Sensitive data exposed!
    createdAt: Date;
  }
  ```
- **Recommendation**: Use class with private fields
  ```typescript
  class UserAccount {
    private passwordHash: string;

    constructor(
      public readonly id: string,
      private email: string,
      passwordHash: string,
      public readonly createdAt: Date
    ) {
      this.passwordHash = passwordHash;
    }

    getEmail(): string {
      return this.email;
    }

    verifyPassword(password: string): Promise<boolean> {
      return bcrypt.compare(password, this.passwordHash);
    }
  }
  ```

### Issue 2 & 3: Comment accuracy issues
[Detailed breakdown of comment issues...]

---

## Suggestions (0 found) 💡

code-simplifier was skipped due to critical issues.
Fix critical problems first, then run review again for refactoring suggestions.

---

## Decision

**WORKFLOW BLOCKED** - Critical issues require attention.

What would you like to do?
1. Abort workflow and fix manually
2. Continue anyway (not recommended)
```

### User Chooses to Abort

```
User: 1
```

### Workflow Aborted

```markdown
Workflow aborted by user.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What was completed:
✅ Memory updated (.claude/memory/)
⏹️ Review complete (issues found)

What was skipped:
⊙ File cleanup (not started)
⊙ Git commit (not started)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
1. Fix critical issues:
   - api/client.ts:156 (add error handling to payment catch block)
   - services/payment.ts (add error scenario tests)

2. Address important issues (optional):
   - types/user.ts:12 (improve UserAccount encapsulation)
   - Comment accuracy fixes

3. Re-run /complete-work when ready

Detailed review saved to: .claude/review-report-2026-01-23.md

<promise>WORKFLOW_ABORTED</promise>
```

---

## User Fixes Issues

### Fixes Critical Issues

```typescript
// api/client.ts:156 - FIXED
try {
  const charge = await stripe.charges.create({...});
  return { success: true, chargeId: charge.id };
} catch (err) {
  logger.error('Payment failed:', { error: err, amount });
  throw new PaymentError('Failed to process payment', { cause: err });
}

// services/payment.test.ts - ADDED
describe('PaymentService - Error Handling', () => {
  it('should handle network failures', async () => {
    // Test implementation...
  });
  it('should handle invalid cards', async () => {
    // Test implementation...
  });
  // ... more error tests
});
```

### Re-runs Workflow

```
User: /complete-work
```

---

## Retry: Steps 1-2

```markdown
Starting work completion workflow...

Checking for previous state...
✓ Previous run aborted, starting fresh

[Step 1/4] Memory Update

Checking memory status...
✓ Memory already up-to-date from previous run
⊙ Skipping memory update (no new .md files)

<promise>MEMORY_UPDATED</promise>

[Step 1/4] ✅ Skipped (already done)

[Step 2/4] Deep Code Review

Launching deep-reviewer agent...

[1/6] code-reviewer: ✓ No issues
[2/6] silent-failure-hunter: ✓ CRITICAL issue fixed!
[3/6] pr-test-analyzer: ✓ Error tests added (gap closed)
[4/6] type-design-analyzer: ⚠️ 1 important (UserAccount encapsulation)
[5/6] comment-analyzer: ✓ No issues
[6/6] code-simplifier: Running (no critical issues)...
  💡 2 refactoring suggestions

Aggregation:
- Critical: 0 (all fixed!)
- Important: 1 (type encapsulation - non-blocking)
- Suggestions: 2 (refactoring ideas)

Decision: NO CRITICAL ISSUES → CONTINUE

<promise>REVIEW_COMPLETE</promise>
```

```markdown
[Step 2/4] ✅ Deep Review Complete

Summary:
- ✅ No critical issues
- ⚠️ 1 important issue (non-blocking)
- 💡 2 suggestions

Proceeding to Step 3...
```

---

## Step 3: File Cleanup

### Agent Launches

```markdown
[Step 3/4] File Cleanup

Launching file-cleaner agent...
```

### File Cleaner Executes (First Run)

```markdown
Running multi-layer pattern detection...

Layer 1 (Universal Patterns):
✓ Found 3 temp files:
  - firebase-debug.log (34 MB)
  - coverage/ (12 MB)
  - .nyc_output/ (2 MB)

Layer 2 (Git Analysis):
✓ Found 2 old files (not modified in 180+ days):
  - scripts/old-migration-2024-01.sql (30 KB, 210 days old)
  - docs/old-architecture-2023.md (15 KB, 365 days old)

Layer 3 (Project Context):
Detected: Node.js project (has package.json)
✓ Found 1 build artifact:
  - dist/ (120 MB)

Layer 4 (User Preferences):
⊙ No pattern file found (.claude/cleanup-patterns.local.md)
⊙ This is your first cleanup - pattern learning available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total: 6 cleanup candidates (168 MB)

Categorized:
- Temporary Files (3 files, 48 MB)
- Old Scripts/Docs (2 files, 45 KB)
- Build Artifacts (1 directory, 120 MB)

What should I do?
1. Archive all (6 items)
2. Let me teach you patterns to remember
3. Skip cleanup

Your choice:
```

### User Chooses Pattern Learning

```
User: 2
```

### Pattern Learning Session

```markdown
Pattern Learning Session

I'll ask about each cleanup pattern.
Choose "always" to remember your preference for future runs.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: "firebase-debug.log"
  Matches: firebase-debug.log (34 MB)
  Category: Debug logs
  Archive this? (y/n/always):

User: always

✅ Learned: Always archive "firebase-debug.log"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: "coverage/"
  Matches: coverage/ (12 MB)
  Category: Test artifacts
  Archive this? (y/n/always):

User: always

✅ Learned: Always archive "coverage/"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: ".nyc_output/"
  Matches: .nyc_output/ (2 MB)
  Category: Test cache
  Archive this? (y/n/always):

User: y

✓ Will archive this time only

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: "scripts/*-migration-*.sql" (if > 180 days old)
  Matches: scripts/old-migration-2024-01.sql (210 days old)
  Category: Old migration scripts
  Archive this? (y/n/always):

User: always

✅ Learned: Always archive old migration scripts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: "docs/*-old-*.md"
  Matches: docs/old-architecture-2023.md (365 days old)
  Category: Old documentation
  Archive this? (y/n/always):

User: n

✗ Skipped: Will keep docs/old-architecture-2023.md
Added to never_archive list

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern: "dist/"
  Matches: dist/ (120 MB)
  Category: Build output
  Note: This can be regenerated with npm run build
  Archive this? (y/n/always):

User: n

✗ Skipped: Build artifacts often regenerated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pattern Learning Complete!

Learned 3 "always archive" patterns:
- firebase-debug.log
- coverage/
- scripts/*-migration-*.sql (if > 180 days)

Added 1 "never archive" pattern:
- docs/*-old-*.md

Saved to: .claude/cleanup-patterns.local.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Cleanup Execution

```markdown
Executing cleanup...

Creating archive directory: .archive/2026-01-23-14-35/

Moving files:
✓ temp-files/firebase-debug.log (34 MB)
✓ temp-files/coverage/ (12 MB)
✓ temp-files/.nyc_output/ (2 MB)
✓ old-scripts/old-migration-2024-01.sql (30 KB)

Generating MANIFEST.md...
✓ Created comprehensive manifest with:
  - File list and metadata
  - Applied patterns
  - Recovery instructions
  - 2-year retention policy (delete after 2028-01-23)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cleanup Summary:
- 4 files archived
- 48.03 MB freed
- 3 patterns learned
- Archive: .archive/2026-01-23-14-35/

<promise>CLEANUP_APPROVED</promise>
```

```markdown
[Step 3/4] ✅ File Cleanup Complete

- 4 files archived (48 MB freed)
- 3 patterns learned for future automation
- MANIFEST: .archive/2026-01-23-14-35/MANIFEST.md

Proceeding to Step 4...
```

---

## Step 4: Git Commit

### Agent Launches

```markdown
[Step 4/4] Git Commit

Launching commit-manager agent...
```

### Commit Manager Executes

```markdown
Creating git commit using commit-commands...

Invoking /commit workflow...

[commit-commands executing...]

Analyzing changes:
✓ git status: 8 files modified, 3 untracked
✓ git diff: 256 lines changed

Analyzing recent commits for message style...
✓ Detected style: Conventional Commits

Generating commit message...
✓ Message generated

Staging files:
✓ .claude/memory/decisions.md
✓ .claude/memory/progress.md
✓ api/client.ts
✓ services/payment.ts
✓ services/payment.test.ts
✓ types/user.ts
✓ .claude/cleanup-patterns.local.md
✓ .archive/2026-01-23-14-35/MANIFEST.md

Creating commit...
✓ Commit created: abc1234567890def

Commit message:
```
fix: improve error handling and add payment error tests

- Fix empty catch block in payment processing (api/client.ts:156)
- Add comprehensive error scenario tests for payment service
- Update memory with error handling and type design decisions
- Archive old temp files and migration scripts (48 MB freed)
- Learn cleanup patterns for future automation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

<promise>WORKFLOW_COMPLETE</promise>
```

---

## Workflow Complete

```markdown
[Step 4/4] ✅ Git Commit Complete

Commit: abc1234567890def

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Work Completion Workflow Finished

Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Step 1] Memory Update ✅
- decisions.md: +2 entries
- progress.md: +1 session
- 3 .md files integrated

[Step 2] Deep Review ✅ (Retry after fixes)
- Initially: 2 critical issues found
- User fixed issues
- Final: 0 critical, 1 important, 2 suggestions

[Step 3] File Cleanup ✅
- 4 files archived (48 MB freed)
- 3 patterns learned (firebase-debug.log, coverage/, migration scripts)
- Archive: .archive/2026-01-23-14-35/

[Step 4] Git Commit ✅
- Commit: abc1234567890def
- 8 files committed
- Conventional commit format

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total time: 8 minutes 45 seconds
(including user interaction and fixes)

All work has been completed and committed! 🎉

Next time:
- Cleanup will be faster (patterns learned)
- /complete-work will auto-apply learned patterns
```

---

## Future Run Example (With Learned Patterns)

```markdown
User: /complete-work

[Step 3/4] File Cleanup

Loading learned patterns from .claude/cleanup-patterns.local.md...
✓ Loaded 3 "archive_always" patterns
✓ Loaded 1 "never_archive" pattern

Running detection with learned patterns...

Auto-Archive (learned patterns, no prompt needed):
✓ firebase-debug.log (28 MB) → matches "firebase-debug.log" pattern
✓ coverage/ (15 MB) → matches "coverage/" pattern
✓ scripts/old-migration-2024-05.sql (25 KB, 195 days) → matches "migration-*.sql" pattern

New Candidates (not in learned patterns):
- .next/cache/ (50 MB) - Next.js build cache

Pattern: ".next/cache/"
  Archive this? (y/n/always):

User: always

✅ Added ".next/cache/" to archive_always patterns

Executing cleanup...
✓ 4 files archived automatically (93 MB freed)
✓ 1 new pattern learned

<promise>CLEANUP_APPROVED</promise>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Much faster - only asked about 1 NEW pattern!]
```

---

## Key Takeaways

1. **Critical Issues Block Workflow** - User must fix or explicitly override
2. **Pattern Learning Reduces Friction** - First run teaches, future runs automate
3. **Memory Preserved on Abort** - Can resume after fixing issues
4. **Comprehensive Reporting** - Clear, actionable feedback at each step
5. **User Control Throughout** - Can abort, skip, or override at any point

This example demonstrates the complete workflow from start to finish, including error handling, pattern learning, and successful completion.
