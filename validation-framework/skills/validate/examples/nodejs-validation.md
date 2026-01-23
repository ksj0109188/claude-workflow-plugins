# Node.js/TypeScript Validation Example

실제 Node.js/TypeScript 프로젝트 검증 워크플로우 예시

## Project Structure

```
calculator-app/
├── package.json
├── tsconfig.json
├── src/
│   ├── calculator.ts
│   └── index.ts
└── tests/
    └── calculator.test.ts
```

## Step 1: Project Detection

**Command**: Scan package.json

**Output**:
```json
{
  "projectType": "nodejs",
  "language": "typescript",
  "validationCommands": {
    "test": "npm test",
    "lint": "npm run lint",
    "typecheck": "tsc --noEmit",
    "build": "npm run build"
  },
  "hasTests": true,
  "hasLint": true,
  "hasTypeCheck": true,
  "hasBuild": true
}
```

## Step 2: Run Validations

### Test Execution

**Command**: `npm test`

**Output (Failed)**:
```
FAIL tests/calculator.test.ts
  ● Calculator › multiply

    expect(received).toBe(expected)

    Expected: 12
    Received: 7

      13 | test('multiplies two numbers', () => {
      14 |   const result = calc.multiply(3, 4);
    > 15 |   expect(result).toBe(12);
         |                  ^
      16 | });

      at Object.<anonymous> (tests/calculator.test.ts:15:18)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 8 passed, 9 total
```

**Analysis**:
- File: `tests/calculator.test.ts`
- Line: 15
- Expected: 12
- Received: 7
- Root Cause: multiply() function implementation bug

### Lint Execution

**Command**: `npm run lint`

**Output (Passed)**:
```
✔ 42 files linted with no errors found
```

### Typecheck Execution

**Command**: `tsc --noEmit`

**Output (Passed)**:
```
(No output - success)
```

### Build Execution

**Command**: `npm run build`

**Output (Passed)**:
```
vite v5.0.0 building for production...
✓ 15 modules transformed.
dist/index.js  2.45 kB │ gzip: 1.23 kB
✓ built in 342ms
```

## Step 3: Failure Analysis

**Read context**: src/calculator.ts

```typescript
export class Calculator {
  multiply(a: number, b: number): number {
    return a + b; // BUG: Should be a * b
  }
}
```

**Root Cause**: multiply() function returns sum instead of product

**Fix Suggestion**:
```typescript
// In src/calculator.ts:10
multiply(a: number, b: number): number {
  return a * b; // FIXED: Changed from a + b
}
```

## Step 4: Report Generation

```markdown
## 검증 결과

### 요약
- ❌ 테스트: 8/9 통과 (1개 실패)
- ✅ 린트: 통과
- ✅ 타입 체크: 통과
- ✅ 빌드: 성공

### 실패 상세

#### 1. tests/calculator.test.ts:15
- **문제**: multiply(3, 4): Expected 12, Received 7
- **원인**: multiply() function returns sum instead of product
- **수정**: In src/calculator.ts:10, change `return a + b` to `return a * b`
- **위치**: src/calculator.ts:10

### 다음 단계
1. src/calculator.ts:10 수정 (multiply 함수)
2. 재검증 실행: /validate test
3. 모든 테스트 통과 확인
```

## Step 5: Re-validation (After Fix)

**Command**: `npm test`

**Output (Success)**:
```
PASS tests/calculator.test.ts
  Calculator
    ✓ adds two numbers (2 ms)
    ✓ subtracts two numbers (1 ms)
    ✓ multiplies two numbers (1 ms)  ← FIXED
    ✓ divides two numbers (1 ms)
    ...

Test Suites: 1 passed, 1 total
Tests:       9 passed, 9 total
```

**Promise Tag**: `<promise>VALIDATION_COMPLETE</promise>`

## Summary

- Initial: 8/9 tests passing (89%)
- Root cause: Logic bug in multiply()
- Fix: 1 line change
- Final: 9/9 tests passing (100%)
- Time: ~5 minutes (automated)
