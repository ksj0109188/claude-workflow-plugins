# Code Review Checklist Reference

Comprehensive guide for the deep-reviewer agent on review requirements and severity criteria.

## Review Agents Overview

The deep-reviewer orchestrates 6 specialized agents from pr-review-toolkit:

| Agent | Purpose | Blocking | Conditional |
|-------|---------|----------|-------------|
| code-reviewer | General quality, bugs, CLAUDE.md compliance | Yes (conf ≥ 90) | No |
| silent-failure-hunter | Error handling, silent failures | Yes (CRITICAL/HIGH) | No |
| pr-test-analyzer | Test coverage gaps | Yes (rating ≥ 8) | No |
| type-design-analyzer | Type design quality (4 dimensions) | No | Yes (if types changed) |
| comment-analyzer | Comment accuracy | No | Yes (if comments changed) |
| code-simplifier | Refactoring suggestions | No | Yes (if no critical issues) |

## Execution Order

### Sequential Execution (Recommended)

```
1. code-reviewer      (baseline - always run first)
2. silent-failure-hunter (critical safety check)
3. pr-test-analyzer   (quality assurance)
4. type-design-analyzer (conditional - if types changed)
5. comment-analyzer   (conditional - if comments changed)
6. code-simplifier    (conditional - if no critical issues)
```

**Rationale**:
- Earlier agents provide context for later ones
- Critical safety checks (silent-failure-hunter) run early
- code-simplifier only runs if safe (no critical issues)

### Conditional Checks

#### type-design-analyzer

**Condition**: New or modified types in git diff

**Check**:
```bash
git diff --unified=0 | grep -E "^\+.*\b(type|interface|class)\s"
```

**Examples**:
```typescript
// MATCH - type definition
+ type UserAccount = { id: string; name: string; }

// MATCH - interface
+ interface Config { apiUrl: string; }

// MATCH - class
+ class DatabaseConnection { }

// NO MATCH - function
+ function getUser() { }

// NO MATCH - variable
+ const user = { id: 1 }
```

#### comment-analyzer

**Condition**: Comments added or modified in git diff

**Check**:
```bash
git diff --unified=0 | grep -E "^\+.*(//|/\*|\*|#)"
```

**Examples**:
```typescript
// MATCH - line comment added
+ // This function validates user input

// MATCH - block comment
+ /* Multi-line
+    comment */

// MATCH - JSDoc
+ /** @param {string} id */

// MATCH - Python comment
+ # Validate input

// NO MATCH - removed comment
- // Old comment

// NO MATCH - unchanged comment
  // Existing comment
```

#### code-simplifier

**Condition**: No critical issues from agents 1-5

**Logic**:
```python
run_simplifier = (
    code_reviewer_critical == 0 and
    silent_failure_critical == 0 and
    pr_test_critical == 0
)
```

**Rationale**:
- Don't suggest refactoring if code has bugs
- Fix critical issues first, then optimize
- Refactoring unsafe code can mask problems

## Severity Classification

### Critical (Blocks Workflow)

Issues that **must** be fixed before committing code.

#### From code-reviewer

**Criteria**: Confidence ≥ 90 AND severity = "critical"

**Examples**:
```typescript
// ❌ CRITICAL: SQL Injection
const query = `SELECT * FROM users WHERE id = ${userId}`;
// Confidence: 95%, Fix: Use parameterized queries

// ❌ CRITICAL: Memory Leak
componentDidMount() {
  setInterval(() => this.setState({...}), 1000);
  // No cleanup in componentWillUnmount
}
// Confidence: 90%, Fix: Clear interval in cleanup

// ❌ CRITICAL: Security Vulnerability
if (password === providedPassword) {  // Plain text comparison
  // ...
}
// Confidence: 100%, Fix: Use bcrypt/argon2
```

**Not Critical** (confidence < 90 or severity < critical):
```typescript
// ⚠️ IMPORTANT: Potential bug (confidence 75%)
if (user.name) {  // Should also check for empty string?
  // ...
}

// 💡 SUGGESTION: Code style (confidence 60%)
const x = 5;  // Variable name could be more descriptive
```

#### From silent-failure-hunter

**Criteria**: Severity = "CRITICAL" or "HIGH"

**CRITICAL Examples**:
```typescript
// ❌ CRITICAL: Empty catch block
try {
  await criticalOperation();
} catch (err) {
  // Silently swallows error
}

// ❌ CRITICAL: Inappropriate fallback
try {
  const data = await fetchUserData();
} catch {
  return { id: 'UNKNOWN', name: 'Guest' };  // Wrong default
}

// ❌ CRITICAL: Missing error propagation
async function processPayment() {
  try {
    await chargeCard();
  } catch (err) {
    console.log(err);  // Logged but not thrown
  }
  // Caller thinks payment succeeded!
}
```

**HIGH Examples** (still blocking):
```typescript
// ❌ HIGH: Inadequate error logging
try {
  await operation();
} catch (err) {
  console.error('Failed');  // No context, no stack trace
}

// ❌ HIGH: Generic error handling
try {
  await specificOperation();
} catch (err) {
  handleGenericError(err);  // Loses specificity
}
```

**MEDIUM Examples** (not blocking):
```typescript
// ⚠️ MEDIUM: Could improve error message
throw new Error('Invalid input');  // What input? What's invalid?

// ⚠️ MEDIUM: Missing error type check
catch (err) {
  // Assumes err is Error instance, might not be
  logger.error(err.message);
}
```

#### From pr-test-analyzer

**Criteria**: Gap rating ≥ 8 (out of 10)

**Rating Scale**:
```
10 = Critical production code with zero test coverage
9  = High-risk code (payments, auth) with no error tests
8  = Core functionality with missing edge case tests
7  = Important code with partial coverage
6  = Secondary features with gaps
5  = Nice-to-have coverage improvements
1-4 = Already well-tested
```

**Rating 9-10 Examples** (CRITICAL - blocking):
```typescript
// ❌ Rating 10: Payment processing, no tests
async function chargeCustomer(amount: number, cardToken: string) {
  const charge = await stripe.charges.create({...});
  return charge;
}
// Gap: No tests for network failures, invalid cards, amount validation

// ❌ Rating 9: Authentication, no error tests
async function login(email: string, password: string) {
  const user = await db.findUser(email);
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (valid) return generateToken(user);
  throw new Error('Invalid credentials');
}
// Gap: No tests for missing user, invalid password, DB errors
```

**Rating 8 Examples** (CRITICAL - blocking):
```typescript
// ❌ Rating 8: Core feature, missing edge cases
function calculateDiscount(price: number, coupon?: Coupon) {
  if (!coupon) return price;
  return price - (price * coupon.discountPercent);
}
// Tests exist for basic case, but missing:
// - expired coupon
// - negative price
// - discount > 100%
```

**Rating 6-7 Examples** (IMPORTANT - not blocking):
```typescript
// ⚠️ Rating 7: Partial coverage
function formatCurrency(amount: number, currency: string) {
  // Has tests for USD, EUR
  // Missing tests for: invalid currency, negative amounts, edge cases
}

// ⚠️ Rating 6: Good coverage, minor gaps
function validateEmail(email: string) {
  // Has tests for most cases
  // Missing: extremely long emails, unicode chars
}
```

### Important (Warns but Continues)

Issues that should be addressed but don't block the commit.

#### From type-design-analyzer

**Criteria**: Any dimension rated ≤ 4 (out of 10)

**4 Dimensions**:
1. **Encapsulation** (1-10)
   - 10 = All fields private, well-designed API
   - 1 = All fields public, no encapsulation

2. **Invariant Expression** (1-10)
   - 10 = Impossible states impossible, strong invariants
   - 1 = Arbitrary states possible, no invariants

3. **Usefulness** (1-10)
   - 10 = Solves real problem, good abstractions
   - 1 = Pointless wrapper, no value

4. **Enforcement** (1-10)
   - 10 = Type system prevents misuse
   - 1 = Easy to misuse, no type safety

**Rating ≤ 4 Examples** (IMPORTANT):
```typescript
// ⚠️ Encapsulation: 3/10
type UserAccount = {
  id: string;
  passwordHash: string;  // Should be private!
  email: string;
  role: string;  // Should be enum
};
// Issue: All fields public, sensitive data exposed

// ⚠️ Invariant Expression: 2/10
type PaymentStatus = {
  paid: boolean;
  pending: boolean;
  failed: boolean;
};
// Issue: Can be {paid: true, failed: true} - impossible state!
// Fix: Use union type: type Status = 'paid' | 'pending' | 'failed'

// ⚠️ Usefulness: 4/10
type StringWrapper = {
  value: string;
};
// Issue: Adds no value, just wraps string

// ⚠️ Enforcement: 3/10
type UserId = string;  // Just an alias, no enforcement
const userId: UserId = "not-a-valid-id";  // Allowed!
// Fix: Use branded type or class with validation
```

#### From comment-analyzer

**Criteria**: Comment accuracy issues detected

**Examples**:
```typescript
// ⚠️ Outdated comment
// Returns user by ID
function getUserByEmail(email: string) {  // Comment says ID!
  return db.findUserByEmail(email);
}

// ⚠️ Misleading comment
// Safe to use with any input
function parseDate(input: string) {
  return new Date(input);  // Can throw! Not safe!
}

// ⚠️ Comment rot (code changed, comment didn't)
// Validates email format and sends confirmation
function validateEmail(email: string) {
  return /\S+@\S+\.\S+/.test(email);
  // No longer sends confirmation!
}
```

### Suggestions (Informational)

Non-blocking improvements for code quality.

#### From code-simplifier

**Examples**:
```typescript
// 💡 SUGGESTION: Extract method
function processOrder(order: Order) {
  // 50 lines of validation logic here
  // ...
  // 30 lines of payment processing
  // ...
  // 20 lines of notification sending
  // ...
}
// Suggestion: Extract into validateOrder(), processPayment(), sendNotifications()

// 💡 SUGGESTION: Reduce duplication
function getUser(id: string) {
  const user = await db.findUser(id);
  if (!user) throw new Error('User not found');
  return user;
}
function getPost(id: string) {
  const post = await db.findPost(id);
  if (!post) throw new Error('Post not found');
  return post;
}
// Suggestion: Generic findOrThrow<T>(finder, id, name) helper

// 💡 SUGGESTION: Use built-in method
function isEmpty(arr: any[]) {
  return arr.length === 0;
}
// Suggestion: Just use arr.length === 0 directly
```

#### From code-reviewer (confidence < 80)

**Examples**:
```typescript
// 💡 SUGGESTION: Variable naming (confidence 60%)
const x = getUserData();
// Suggestion: const userData = getUserData();

// 💡 SUGGESTION: Potential issue (confidence 70%)
if (user) {  // What if user is {} empty object?
  // ...
}
// Suggestion: if (user && Object.keys(user).length)
```

## Issue Aggregation

### Collection Schema

```json
{
  "critical": [
    {
      "agent": "silent-failure-hunter",
      "file": "api/client.ts",
      "line": 42,
      "issue": "Empty catch block - error swallowed",
      "severity": "CRITICAL",
      "confidence": 100,
      "fix": "Add error logging and proper recovery"
    }
  ],
  "important": [
    {
      "agent": "type-design-analyzer",
      "file": "types/user.ts",
      "line": 12,
      "issue": "UserAccount: weak encapsulation (3/10)",
      "dimension": "encapsulation",
      "rating": 3,
      "recommendation": "Use private fields with getter methods"
    }
  ],
  "suggestions": [
    {
      "agent": "code-simplifier",
      "file": "utils/format.ts",
      "line": 50,
      "suggestion": "Extract method to reduce complexity",
      "impact": "Improves readability"
    }
  ]
}
```

### Deduplication

**Problem**: Multiple agents flag same issue

**Example**:
```typescript
// Both code-reviewer AND silent-failure-hunter flag this
try {
  await operation();
} catch (err) {
  // empty
}
```

**Solution**: Deduplicate by file:line, keep highest severity

```python
def deduplicate(issues):
    by_location = {}
    for issue in issues:
        key = f"{issue.file}:{issue.line}"
        if key not in by_location:
            by_location[key] = issue
        elif issue.severity > by_location[key].severity:
            by_location[key] = issue
    return by_location.values()
```

### Prioritization

**Display Order** (most important first):

1. CRITICAL issues (blocking)
   - silent-failure-hunter CRITICAL
   - pr-test-analyzer rating ≥ 8
   - code-reviewer confidence ≥ 90, severity = critical

2. IMPORTANT issues (non-blocking)
   - type-design-analyzer dimension ≤ 4
   - comment-analyzer accuracy issues
   - silent-failure-hunter HIGH

3. SUGGESTIONS (informational)
   - code-simplifier refactoring
   - code-reviewer confidence < 80

## Report Format

### Critical Issues Section

```markdown
## Critical Issues (2 found) 🚨

### Issue 1: Empty catch block
- **Agent**: silent-failure-hunter
- **File**: api/client.ts:42
- **Severity**: CRITICAL
- **Confidence**: 100%
- **Issue**: Error swallowed with no logging or recovery
- **Code**:
  ```typescript
  try {
    await fetchData();
  } catch (err) {
    // Silently fails
  }
  ```
- **Fix**: Add error logging and propagate to caller
  ```typescript
  try {
    await fetchData();
  } catch (err) {
    logger.error('Failed to fetch data:', err);
    throw err;  // or handle appropriately
  }
  ```

### Issue 2: Missing error handling tests
- **Agent**: pr-test-analyzer
- **File**: services/payment.ts:128
- **Gap Rating**: 9/10 (CRITICAL)
- **Issue**: Payment processing has no error scenario tests
- **Missing Coverage**:
  - Network failures
  - Invalid card data
  - Insufficient funds
  - Stripe API errors
- **Fix**: Add comprehensive error tests
```

### Important Issues Section

```markdown
## Important Issues (1 found) ⚠️

### Issue 1: Weak type encapsulation
- **Agent**: type-design-analyzer
- **File**: types/user.ts:12
- **Dimension**: Encapsulation
- **Rating**: 3/10
- **Issue**: UserAccount type exposes all fields publicly
- **Code**:
  ```typescript
  type UserAccount = {
    id: string;
    passwordHash: string;  // Sensitive!
    email: string;
  };
  ```
- **Recommendation**: Use class with private fields
  ```typescript
  class UserAccount {
    private passwordHash: string;

    constructor(
      public readonly id: string,
      private email: string,
      passwordHash: string
    ) {
      this.passwordHash = passwordHash;
    }

    getEmail() { return this.email; }
    setEmail(email: string) { this.email = email; }
  }
  ```
```

### Suggestions Section

```markdown
## Suggestions (2 found) 💡

### Suggestion 1: Extract method
- **Agent**: code-simplifier
- **File**: utils/format.ts:50
- **Complexity**: High (cyclomatic 15)
- **Suggestion**: Extract validation logic into separate method
- **Impact**: Improves readability and testability

### Suggestion 2: Improve variable naming
- **Agent**: code-reviewer
- **File**: handlers/user.ts:23
- **Confidence**: 60%
- **Suggestion**: `const x = ...` → `const userData = ...`
- **Impact**: Minor readability improvement
```

## Decision Logic

```python
def determine_workflow_action(findings):
    critical_count = len(findings['critical'])

    if critical_count > 0:
        return {
            'promise': 'REVIEW_ISSUES_FOUND',
            'action': 'BLOCK',
            'message': f'🚨 {critical_count} critical issue(s) found'
        }
    else:
        important_count = len(findings['important'])
        suggestion_count = len(findings['suggestions'])

        return {
            'promise': 'REVIEW_COMPLETE',
            'action': 'CONTINUE',
            'message': f'✅ No critical issues ({important_count} important, {suggestion_count} suggestions)'
        }
```

## Error Handling

### Agent Failure

**Scenario**: One agent fails to execute

**Handling**:
```markdown
⚠️ type-design-analyzer failed to run
Reason: TypeScript configuration not found
Impact: Type design quality not assessed (non-blocking)

Continuing with remaining agents...
```

**Logic**:
- Log failure
- Continue with other agents
- Report failure in summary
- Only block if silent-failure-hunter fails (critical for safety)

### Timeout

**Scenario**: Agent takes too long (> 60 seconds)

**Handling**:
```markdown
⚠️ code-simplifier timed out after 60 seconds
Reason: Large diff (500+ files)
Impact: No refactoring suggestions available

Skipping code-simplifier, continuing workflow...
```

### No Changes Detected

**Scenario**: `git diff` returns empty

**Handling**:
```markdown
No code changes detected in git diff.

Skipping code review (nothing to review).

<promise>REVIEW_COMPLETE</promise>
```

## Performance Optimization

### Parallel Execution (Future Enhancement)

Currently sequential, but could be parallelized:

```python
# Run independent agents in parallel
async def run_review_parallel():
    results = await asyncio.gather(
        run_code_reviewer(),
        run_silent_failure_hunter(),
        run_pr_test_analyzer()
    )

    # Then run conditional agents based on results
    if types_changed and no_critical_issues(results):
        await run_type_design_analyzer()

    # ...
```

**Benefits**:
- Faster review (2-3x)
- Better for large PRs

**Trade-offs**:
- Less context sharing between agents
- Harder to debug
- Might miss issues that sequential context would catch

## Testing Checklist

- [ ] code-reviewer runs for all diffs
- [ ] silent-failure-hunter correctly flags empty catches
- [ ] pr-test-analyzer rates gaps accurately (8+ = critical)
- [ ] type-design-analyzer only runs when types changed
- [ ] comment-analyzer only runs when comments changed
- [ ] code-simplifier skips when critical issues exist
- [ ] Deduplication works (no duplicate issues)
- [ ] Severity classification is accurate
- [ ] Report format is clear and actionable
- [ ] REVIEW_ISSUES_FOUND blocks workflow correctly
- [ ] REVIEW_COMPLETE allows continuation
