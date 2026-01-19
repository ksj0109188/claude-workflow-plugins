# Python Validation Example

Complete validation workflow for a Python project.

## Project Structure

```
my-app/
├── pyproject.toml
├── src/
│   └── calculator.py
└── tests/
    └── test_calculator.py
```

## Step 1: Project Detection

**Command**:
```bash
cat pyproject.toml
```

**Output**:
```toml
[project]
name = "my-app"
version = "1.0.0"

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
select = ["E", "F", "I"]

[tool.mypy]
strict = true
```

**Detected**:
- Project type: python
- Test: pytest
- Lint: ruff check
- Typecheck: mypy

## Step 2: Run Validations

### Test Execution

**Command**:
```bash
pytest -v 2>&1
```

**Output (Failure)**:
```
============================= test session starts ==============================
platform darwin -- Python 3.11.0, pytest-7.4.0, pluggy-1.0.0
cachedir: .pytest_cache
rootdir: /Users/user/my-app
configfile: pyproject.toml
collected 5 items

tests/test_calculator.py::test_add PASSED                                [ 20%]
tests/test_calculator.py::test_subtract PASSED                           [ 40%]
tests/test_calculator.py::test_multiply FAILED                           [ 60%]
tests/test_calculator.py::test_divide PASSED                             [ 80%]
tests/test_calculator.py::test_power FAILED                              [100%]

=================================== FAILURES ===================================
______________________________ test_multiply ___________________________________

    def test_multiply():
        calc = Calculator()
>       assert calc.multiply(3, 4) == 12
E       AssertionError: assert 7 == 12
E        +  where 7 = <bound method Calculator.multiply of <calculator.Calculator object at 0x104f3e590>>(3, 4)
E        +    where <bound method Calculator.multiply of <calculator.Calculator object at 0x104f3e590>> = <calculator.Calculator object at 0x104f3e590>.multiply

tests/test_calculator.py:15: AssertionError
_________________________________ test_power ___________________________________

    def test_power():
        calc = Calculator()
>       assert calc.power(2, 3) == 8
E       AssertionError: assert 0 == 8
E        +  where 0 = <bound method Calculator.power of <calculator.Calculator object at 0x104f3e710>>(2, 3)
E        +    where <bound method Calculator.power of <calculator.Calculator object at 0x104f3e710>> = <calculator.Calculator object at 0x104f3e710>.power

tests/test_calculator.py:29: AssertionError
=========================== short test summary info ============================
FAILED tests/test_calculator.py::test_multiply - AssertionError: assert 7 == 12
FAILED tests/test_calculator.py::test_power - AssertionError: assert 0 == 8
========================= 2 failed, 3 passed in 0.12s ==========================
```

### Lint Execution

**Command**:
```bash
ruff check . 2>&1
```

**Output (Success)**:
```
All checks passed!
```

**Exit code**: 0 (success)

### Typecheck Execution

**Command**:
```bash
mypy . 2>&1
```

**Output (Success)**:
```
Success: no issues found in 2 source files
```

**Exit code**: 0 (success)

## Step 3: Failure Analysis

### Failure 1: test_multiply

**Location**: tests/test_calculator.py:15
**Message**: AssertionError: assert 7 == 12
**Test**: `calc.multiply(3, 4)`

**Read source**:
```python
# src/calculator.py:10
def multiply(self, a: float, b: float) -> float:
    return a + b  # BUG: addition instead of multiplication
```

**Root cause**: Logic error - function performs addition instead of multiplication
**Fix**: Change `return a + b` to `return a * b`

### Failure 2: test_power

**Location**: tests/test_calculator.py:29
**Message**: AssertionError: assert 0 == 8
**Test**: `calc.power(2, 3)`

**Read source**:
```python
# src/calculator.py:29
def power(self, base: float, exponent: float) -> float:
    return 0  # BUG: unimplemented, returns placeholder
```

**Root cause**: Unimplemented function
**Fix**: Change `return 0` to `return base ** exponent`

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
    }
  },
  "failures": [
    {
      "file": "tests/test_calculator.py",
      "line": 15,
      "sourceFile": "src/calculator.py",
      "sourceLine": 10,
      "message": "AssertionError: assert 7 == 12",
      "cause": "multiply() performs addition instead of multiplication",
      "fix": "Change 'return a + b' to 'return a * b'",
      "recurring": false
    },
    {
      "file": "tests/test_calculator.py",
      "line": 29,
      "sourceFile": "src/calculator.py",
      "sourceLine": 29,
      "message": "AssertionError: assert 0 == 8",
      "cause": "power() function is unimplemented",
      "fix": "Implement: return base ** exponent",
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

## 테스트 실패

### 1. tests/test_calculator.py:15
- **테스트**: calc.multiply(3, 4)
- **문제**: assert 7 == 12
- **원인**: multiply() 함수가 곱셈 대신 덧셈 수행
- **위치**: src/calculator.py:10
- **수정**: `return a + b` → `return a * b`

### 2. tests/test_calculator.py:29
- **테스트**: calc.power(2, 3)
- **문제**: assert 0 == 8
- **원인**: power() 함수 미구현
- **위치**: src/calculator.py:29
- **수정**: `return 0` → `return base ** exponent`

## 다음 단계
1. src/calculator.py:10 수정 (multiply 메서드)
2. src/calculator.py:29 구현 (power 메서드)
3. 재검증 실행: /validate test
4. 모든 테스트 통과 확인
```

## Step 6: Re-validation After Fixes

**After applying fixes**, run validation again:

```bash
pytest -v 2>&1
```

**Output (Success)**:
```
============================= test session starts ==============================
platform darwin -- Python 3.11.0, pytest-7.4.0, pluggy-1.0.0
cachedir: .pytest_cache
rootdir: /Users/user/my-app
configfile: pyproject.toml
collected 5 items

tests/test_calculator.py::test_add PASSED                                [ 20%]
tests/test_calculator.py::test_subtract PASSED                           [ 40%]
tests/test_calculator.py::test_multiply PASSED                           [ 60%]
tests/test_calculator.py::test_divide PASSED                             [ 80%]
tests/test_calculator.py::test_power PASSED                              [100%]

============================== 5 passed in 0.08s ===============================
```

**Result**: All validations pass ✅
**Promise**: `<promise>VALIDATION_COMPLETE</promise>`

## Common Python Testing Patterns

### Using fixtures

```python
@pytest.fixture
def calculator():
    return Calculator()

def test_multiply(calculator):
    assert calculator.multiply(3, 4) == 12
```

### Parametrized tests

```python
@pytest.mark.parametrize("a,b,expected", [
    (3, 4, 12),
    (5, 0, 0),
    (-2, 3, -6),
])
def test_multiply(a, b, expected):
    calc = Calculator()
    assert calc.multiply(a, b) == expected
```

### Testing exceptions

```python
def test_divide_by_zero():
    calc = Calculator()
    with pytest.raises(ZeroDivisionError):
        calc.divide(10, 0)
```
