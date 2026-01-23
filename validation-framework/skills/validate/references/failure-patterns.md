# Common Failure Patterns Catalog

자주 발생하는 검증 실패 패턴 및 분석 방법

## Test Failures

### Pattern 1: Expected vs Received Mismatch

**증상**:
```
Expected: 12
Received: 7
```

**분석 절차**:
1. Extract file:line from error
2. Read surrounding context (±5 lines)
3. Identify test input and expected output
4. Trace to source function
5. Identify logic bug

**예시**:
```typescript
// Test: calculator.test.ts:15
test('multiply', () => {
  expect(calc.multiply(3, 4)).toBe(12); // Expected 12, got 7
});

// Source: calculator.ts:10
multiply(a, b) {
  return a + b; // BUG: Should be a * b
}
```

### Pattern 2: Undefined/Null Errors

**증상**:
```
TypeError: Cannot read property 'value' of undefined
```

**분석 절차**:
1. Extract variable name
2. Trace variable initialization
3. Check conditional logic
4. Identify missing null check

### Pattern 3: Async/Promise Errors

**증상**:
```
Error: Timeout - Async callback was not invoked
```

**분석 절차**:
1. Check for missing await
2. Check for unresolved promises
3. Verify async/await consistency

## Lint Errors

### Pattern 1: Unused Variables

**증상**:
```
'temp' is defined but never used
```

**수정**:
- 변수 사용 또는 제거
- `_temp`로 리네임 (intentional unused)

### Pattern 2: Missing Return

**증상**:
```
Expected to return a value in arrow function
```

**수정**:
- Add explicit return
- Or use expression body: `() => value`

## Type Errors

### Pattern 1: Type Mismatch

**증상**:
```
Type 'string' is not assignable to type 'number'
```

**분석 절차**:
1. Extract expected type and actual type
2. Trace variable assignment
3. Identify type conversion need
4. Suggest type cast or conversion

### Pattern 2: Missing Properties

**증상**:
```
Property 'name' does not exist on type 'User'
```

**수정**:
- Add property to interface
- Make property optional: `name?:`
- Add type guard

## Build Errors

### Pattern 1: Module Not Found

**증상**:
```
Cannot find module '@/utils'
```

**분석 절차**:
1. Check import path
2. Verify file existence
3. Check tsconfig.json paths
4. Check package.json dependencies

### Pattern 2: Circular Dependencies

**증상**:
```
Circular dependency detected
```

**수정**:
- Extract shared code to new module
- Use dependency injection
- Restructure imports

## Extraction Patterns

### File:Line:Column Format

**Regex patterns**:
```
(\S+):(\d+):(\d+)              # file.ts:15:10
(\S+)\.(\S+):(\d+)             # file.test.ts:42
at (\S+) \((\S+):(\d+):(\d+)\) # at function (file.ts:15:10)
```

### Expected vs Received

**Patterns**:
```
Expected: (.+)
Received: (.+)

expect\((\w+)\)\.toBe\((.+)\)  # Jest
assert\.equal\((\w+), (.+)\)    # Node assert
```

## Root Cause Analysis

1. **Symptom**: Error message 추출
2. **Location**: file:line:column 추출
3. **Context**: 주변 코드 읽기 (±5 lines)
4. **Pattern**: 실패 패턴 매칭
5. **Cause**: 근본 원인 식별
6. **Fix**: 구체적 수정 제안

## Recurring Issue Detection

3회 이상 동일 위치 실패:
- issues.md에 기록
- 패턴 학습 강화
- 자동 수정 우선순위 상향
