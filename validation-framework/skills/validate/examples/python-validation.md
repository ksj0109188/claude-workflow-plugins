# Python Validation Example

실제 Python 프로젝트 검증 워크플로우 예시

## Project Structure

```
calculator-app/
├── pyproject.toml
├── src/
│   └── calculator.py
└── tests/
    └── test_calculator.py
```

## Step 1: Project Detection

**Command**: Scan pyproject.toml

**Output**:
```json
{
  "projectType": "python",
  "language": "python",
  "validationCommands": {
    "test": "pytest",
    "lint": "ruff check .",
    "typecheck": "mypy ."
  },
  "hasTests": true,
  "hasLint": true,
  "hasTypeCheck": true
}
```

## Step 2: Run Validations

### Test Execution

**Command**: `pytest`

**Output (Failed)**:
```
================================ FAILURES =================================
_______________________ test_multiply __________________

    def test_multiply():
>       assert calculator.multiply(3, 4) == 12
E       AssertionError: assert 7 == 12
E        +  where 7 = <bound method Calculator.multiply of ...>(3, 4)

tests/test_calculator.py:15: AssertionError
==================== short test summary info ====================
FAILED tests/test_calculator.py::test_multiply - AssertionError: assert 7 == 12
================ 1 failed, 8 passed in 0.42s ================
```

**Analysis**:
- File: `tests/test_calculator.py`
- Line: 15
- Expected: 12
- Received: 7
- Root Cause: multiply() method implementation bug

### Lint Execution

**Command**: `ruff check .`

**Output (Passed)**:
```
All checks passed!
```

### Typecheck Execution

**Command**: `mypy .`

**Output (Passed)**:
```
Success: no issues found in 5 source files
```

## Step 3: Failure Analysis

**Read context**: src/calculator.py

```python
class Calculator:
    def multiply(self, a: int, b: int) -> int:
        return a + b  # BUG: Should be a * b
```

**Root Cause**: multiply() method returns sum instead of product

**Fix Suggestion**:
```python
# In src/calculator.py:10
def multiply(self, a: int, b: int) -> int:
    return a * b  # FIXED: Changed from a + b
```

## Step 4: Report Generation

```markdown
## 검증 결과

### 요약
- ❌ 테스트: 8/9 통과 (1개 실패)
- ✅ 린트: 통과
- ✅ 타입 체크: 통과

### 실패 상세

#### 1. tests/test_calculator.py:15
- **문제**: assert 7 == 12 - multiply(3, 4) returned 7 instead of 12
- **원인**: multiply() method returns sum instead of product
- **수정**: In src/calculator.py:10, change `return a + b` to `return a * b`
- **위치**: src/calculator.py:10

### 다음 단계
1. src/calculator.py:10 수정 (multiply 메서드)
2. 재검증 실행: /validate test
3. 모든 테스트 통과 확인
```

## Step 5: Re-validation (After Fix)

**Command**: `pytest`

**Output (Success)**:
```
================================ test session starts =================================
collected 9 items

tests/test_calculator.py .........                                          [100%]

================================ 9 passed in 0.38s ==================================
```

**Promise Tag**: `<promise>VALIDATION_COMPLETE</promise>`

## Summary

- Initial: 8/9 tests passing (89%)
- Root cause: Logic bug in multiply() method
- Fix: 1 line change
- Final: 9/9 tests passing (100%)
- Time: ~5 minutes (automated)
