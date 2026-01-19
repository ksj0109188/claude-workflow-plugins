# Node.js/TypeScript Validation Example

Complete validation workflow for a TypeScript Node.js project.

## Project Structure

```
my-app/
├── package.json
├── tsconfig.json
├── src/
│   └── calculator.ts
└── tests/
    └── calculator.test.ts
```

## Step 1: Project Detection

**Command**:
```bash
cat package.json
```

**Output**:
```json
{
  "name": "my-app",
  "scripts": {
    "test": "jest",
    "lint": "eslint . --ext .ts",
    "typecheck": "tsc --noEmit",
    "build": "tsc"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "typescript": "^5.0.0"
  }
}
```

**Detected**:
- Project type: nodejs
- Language: typescript
- Test: npm test (jest)
- Lint: npm run lint (eslint)
- Typecheck: npm run typecheck (tsc)
- Build: npm run build (tsc)

## Step 2: Run Validations

### Test Execution

**Command**:
```bash
npm test 2>&1
```

**Output (Failure)**:
```
FAIL tests/calculator.test.ts
  Calculator
    ✓ adds two numbers (3 ms)
    ✓ subtracts two numbers (1 ms)
    ✕ multiplies two numbers (4 ms)
    ✓ divides two numbers (2 ms)
    ✕ calculates power (3 ms)

  ● Calculator › multiplies two numbers

    expect(received).toBe(expected) // Object.is equality

    Expected: 12
    Received: 7

      13 |   test('multiplies two numbers', () => {
      14 |     const result = calculator.multiply(3, 4);
    > 15 |     expect(result).toBe(12);
         |                    ^
      16 |   });

      at Object.<anonymous> (tests/calculator.test.ts:15:20)

  ● Calculator › calculates power

    expect(received).toBe(expected) // Object.is equality

    Expected: 8
    Received: 0

      28 |   test('calculates power', () => {
      29 |     const result = calculator.power(2, 3);
    > 30 |     expect(result).toBe(8);
         |                    ^
      31 |   });

      at Object.<anonymous> (tests/calculator.test.ts:30:20)

Test Suites: 1 failed, 1 total
Tests:       2 failed, 3 passed, 5 total
Time:        1.256 s
```

### Lint Execution

**Command**:
```bash
npm run lint 2>&1
```

**Output (Success)**:
```
> my-app@1.0.0 lint
> eslint . --ext .ts

(no output - all checks passed)
```

**Exit code**: 0 (success)

### Typecheck Execution

**Command**:
```bash
npm run typecheck 2>&1
```

**Output (Success)**:
```
> my-app@1.0.0 typecheck
> tsc --noEmit

(no output - type checking passed)
```

**Exit code**: 0 (success)

### Build Execution

**Command**:
```bash
npm run build 2>&1
```

**Output (Success)**:
```
> my-app@1.0.0 build
> tsc

(no output - build successful)
```

**Exit code**: 0 (success)

## Step 3: Failure Analysis

### Failure 1: multiply() test

**Location**: tests/calculator.test.ts:15
**Message**: Expected 12, Received 7
**Test**: `calculator.multiply(3, 4)`

**Read source**:
```typescript
// src/calculator.ts:10
multiply(a: number, b: number): number {
  return a + b;  // BUG: addition instead of multiplication
}
```

**Root cause**: Logic error - function performs addition instead of multiplication
**Fix**: Change `return a + b;` to `return a * b;`

### Failure 2: power() test

**Location**: tests/calculator.test.ts:30
**Message**: Expected 8, Received 0
**Test**: `calculator.power(2, 3)`

**Read source**:
```typescript
// src/calculator.ts:29
power(base: number, exponent: number): number {
  return 0;  // BUG: unimplemented, returns placeholder
}
```

**Root cause**: Unimplemented function
**Fix**: Change `return 0;` to `return Math.pow(base, exponent);`

## Step 4: Structured Results

```json
{
  "summary": {
    "test": {
      "status": "failed",
      "passed": 3,
      "failed": 2,
      "total": 5
    },
    "lint": {
      "status": "passed",
      "errors": 0
    },
    "typecheck": {
      "status": "passed",
      "errors": 0
    },
    "build": {
      "status": "passed"
    }
  },
  "failures": [
    {
      "file": "tests/calculator.test.ts",
      "line": 15,
      "sourceFile": "src/calculator.ts",
      "sourceLine": 10,
      "message": "Expected 12, Received 7",
      "cause": "multiply() performs addition instead of multiplication",
      "fix": "Change 'return a + b;' to 'return a * b;'",
      "recurring": false
    },
    {
      "file": "tests/calculator.test.ts",
      "line": 30,
      "sourceFile": "src/calculator.ts",
      "sourceLine": 29,
      "message": "Expected 8, Received 0",
      "cause": "power() function is unimplemented",
      "fix": "Implement: return Math.pow(base, exponent);",
      "recurring": false
    }
  ]
}
```

## Step 5: User Report

```markdown
# 검증 리포트

## 요약
- ❌ 테스트: 3/5 통과 (2개 실패)
- ✅ 린트: 통과
- ✅ 타입 체크: 통과
- ✅ 빌드: 성공

## 테스트 실패

### 1. tests/calculator.test.ts:15
- **테스트**: multiply(3, 4)
- **문제**: Expected 12, Received 7
- **원인**: multiply() 함수가 곱셈 대신 덧셈 수행
- **위치**: src/calculator.ts:10
- **수정**: `return a + b;` → `return a * b;`

### 2. tests/calculator.test.ts:30
- **테스트**: power(2, 3)
- **문제**: Expected 8, Received 0
- **원인**: power() 함수 미구현
- **위치**: src/calculator.ts:29
- **수정**: `return 0;` → `return Math.pow(base, exponent);`

## 다음 단계
1. src/calculator.ts:10 수정 (multiply 함수)
2. src/calculator.ts:29 구현 (power 함수)
3. 재검증 실행: /validate test
4. 모든 테스트 통과 확인
```

## Step 6: Re-validation After Fixes

**After applying fixes**, run validation again:

```bash
npm test 2>&1
```

**Output (Success)**:
```
PASS tests/calculator.test.ts
  Calculator
    ✓ adds two numbers (2 ms)
    ✓ subtracts two numbers (1 ms)
    ✓ multiplies two numbers (1 ms)
    ✓ divides two numbers (1 ms)
    ✓ calculates power (2 ms)

Test Suites: 1 passed, 1 total
Tests:       5 passed, 5 total
Time:        0.856 s
```

**Result**: All validations pass ✅
**Promise**: `<promise>VALIDATION_COMPLETE</promise>`
