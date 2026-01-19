# Validation Failure Patterns

Catalog of common validation failures with analysis and fix templates.

## Test Failures

### Pattern 1: Logic Error (Expected vs Received)

**Example**:
```
Expected: 12
Received: 7

test('multiply should return product', () => {
  expect(multiply(3, 4)).toBe(12);  // Line 15
});
```

**Analysis Steps**:
1. Extract expected value: `12`
2. Extract received value: `7`
3. Identify operation: `multiply(3, 4)`
4. Calculate correct result: `3 * 4 = 12`
5. Hypothesize: Function returns sum (3+4=7) instead of product

**Fix Template**:
```
File: src/calculator.ts:10
Current: return a + b;
Fix: return a * b;
Reason: multiply() should perform multiplication, not addition
```

### Pattern 2: Unimplemented Function

**Example**:
```
Expected: 8
Received: 0

test('power should calculate exponent', () => {
  expect(power(2, 3)).toBe(8);  // Line 28
});
```

**Analysis Steps**:
1. Extract expected value: `8`
2. Extract received value: `0` (default/placeholder)
3. Identify operation: `power(2, 3)`
4. Determine: Function returns default value, not implemented

**Fix Template**:
```
File: src/calculator.ts:29
Current: return 0;
Fix: return Math.pow(base, exponent);
Reason: power() function is unimplemented, returns placeholder
```

### Pattern 3: Off-by-One Error

**Example**:
```
Expected: 10
Received: 9

test('sum array', () => {
  expect(sum([1,2,3,4])).toBe(10);  // Line 42
});
```

**Analysis Steps**:
1. Missing last element: `1+2+3=6` but need `1+2+3+4=10`
2. Check loop condition: `i < arr.length` vs `i <= arr.length`
3. Or: Array indexing starts at 1 instead of 0

**Fix Template**:
```
File: src/calculator.ts:45
Current: for (let i = 0; i < arr.length - 1; i++)
Fix: for (let i = 0; i < arr.length; i++)
Reason: Loop stops one element early
```

### Pattern 4: Type Coercion

**Example**:
```
Expected: 5
Received: "32"

test('add numbers', () => {
  expect(add(3, 2)).toBe(5);
});
```

**Analysis Steps**:
1. Result is string concatenation: `"3" + "2" = "32"`
2. Arguments not properly parsed to numbers
3. Type coercion issue

**Fix Template**:
```
File: src/calculator.ts:7
Current: return a + b;
Fix: return Number(a) + Number(b);
Reason: String concatenation instead of numeric addition
```

## Lint Failures

### Pattern 1: Unused Variable

**Example**:
```
src/calculator.ts:15
  'result' is defined but never used  @typescript-eslint/no-unused-vars
```

**Analysis**:
- Variable declared but not returned or used
- Likely: Forgot to return, or debug variable

**Fix Template**:
```
File: src/calculator.ts:15
Option 1: Remove unused variable
Option 2: Return the variable
Option 3: Use the variable in computation
```

### Pattern 2: Missing Return Type

**Example**:
```
src/calculator.ts:29
  Missing return type annotation  @typescript-eslint/explicit-function-return-type
```

**Analysis**:
- Function lacks explicit return type
- TypeScript best practice violation

**Fix Template**:
```
File: src/calculator.ts:29
Current: function multiply(a: number, b: number) {
Fix: function multiply(a: number, b: number): number {
Reason: Explicit return types improve type safety
```

### Pattern 3: Console Statement

**Example**:
```
src/calculator.ts:12
  Unexpected console statement  no-console
```

**Analysis**:
- Debug statement left in code
- Should use proper logging or remove

**Fix Template**:
```
File: src/calculator.ts:12
Current: console.log('result:', result);
Option 1: Remove debug statement
Option 2: Replace with proper logger: logger.debug('result:', result);
```

## Type Check Failures

### Pattern 1: Type Mismatch

**Example**:
```
src/calculator.ts:15:5
  Argument of type 'string' is not assignable to parameter of type 'number'
```

**Analysis**:
- Function expects number, receives string
- Need type conversion or parameter type change

**Fix Template**:
```
File: src/calculator.ts:15
Option 1: Convert input: Number(input)
Option 2: Change parameter type: (a: string | number)
Option 3: Parse earlier in call chain
```

### Pattern 2: Possibly Undefined

**Example**:
```
src/calculator.ts:20:3
  Object is possibly 'undefined'  TS2532
```

**Analysis**:
- Accessing property on potentially undefined object
- Need null check or optional chaining

**Fix Template**:
```
File: src/calculator.ts:20
Current: const value = obj.property;
Option 1: obj?.property
Option 2: if (obj) { const value = obj.property; }
Option 3: const value = obj!.property; (only if 100% sure)
```

### Pattern 3: Missing Property

**Example**:
```
src/calculator.ts:25:10
  Property 'result' does not exist on type 'Calculation'  TS2339
```

**Analysis**:
- Interface missing expected property
- Property name typo, or need to add to interface

**Fix Template**:
```
Option 1: Add to interface: result: number;
Option 2: Fix typo: results → result
Option 3: Use correct property name
```

## Build Failures

### Pattern 1: Module Not Found

**Example**:
```
Error: Cannot find module 'lodash'
```

**Analysis**:
- Missing dependency in package.json
- Need to install package

**Fix Template**:
```
Run: npm install lodash
Or: npm install --save lodash
Add to package.json dependencies
```

### Pattern 2: Syntax Error

**Example**:
```
Unexpected token '}'
  at Module._compile (internal/modules/cjs/loader.js:895:18)
```

**Analysis**:
- Unclosed brace, parenthesis, or bracket
- Parse error in source code

**Fix Template**:
```
Check file for:
1. Matching braces { }
2. Matching parentheses ( )
3. Matching brackets [ ]
4. Properly closed strings
```

### Pattern 3: Import/Export Error

**Example**:
```
SyntaxError: The requested module does not provide an export named 'multiply'
```

**Analysis**:
- Named export doesn't exist
- Typo in import statement
- Default vs named export mismatch

**Fix Template**:
```
Option 1: Fix import: import { multiply } from './calculator'
Option 2: Add export: export function multiply() { }
Option 3: Change to default: import calculator from './calculator'
```

## Extraction Patterns

### File:Line:Column

**Regex**: `([^:]+):(\d+):(\d+)`

**Examples**:
- `src/calculator.ts:15:24` → file: src/calculator.ts, line: 15, col: 24
- `tests/calc.test.py:42:5` → file: tests/calc.test.py, line: 42, col: 5

### Expected vs Received

**Patterns**:
```
Expected: <value>
Received: <value>

expect(<received>).toBe(<expected>)

AssertionError: assert <received> == <expected>

assertion failed: `(left == right)`
  left: `<received>`,
  right: `<expected>`
```

### Error Messages

**Key phrases**:
- "is not assignable to"
- "does not exist on type"
- "possibly undefined"
- "cannot find module"
- "unexpected token"
- "is defined but never used"

## Fix Priority

**Critical (must fix)**:
1. Test failures (broken functionality)
2. Type errors (incorrect types)
3. Build failures (cannot deploy)

**High (should fix)**:
4. Lint errors marked as errors
5. Missing return types
6. Unused variables

**Medium (can defer)**:
7. Console statements (if debug)
8. Minor style violations
9. Documentation warnings
