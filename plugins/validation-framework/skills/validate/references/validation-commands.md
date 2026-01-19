# Validation Commands Reference

Complete guide to validation commands across different ecosystems.

## Test Runners

### Jest (Node.js/TypeScript)

**Basic command**:
```bash
npm test
# or
jest
```

**With coverage**:
```bash
npm test -- --coverage
```

**Watch mode**:
```bash
npm test -- --watch
```

**Specific file**:
```bash
npm test -- calculator.test.ts
```

**Output format**: TAB-formatted with PASS/FAIL, test names, and error messages

### Vitest (Node.js/TypeScript)

**Basic command**:
```bash
npm test
# or
vitest run
```

**Watch mode**:
```bash
vitest
```

**UI mode**:
```bash
vitest --ui
```

### pytest (Python)

**Basic command**:
```bash
pytest
```

**Verbose output**:
```bash
pytest -v
```

**Specific file**:
```bash
pytest tests/test_calculator.py
```

**With coverage**:
```bash
pytest --cov=src
```

### cargo test (Rust)

**Basic command**:
```bash
cargo test
```

**Specific test**:
```bash
cargo test test_multiply
```

**Release mode**:
```bash
cargo test --release
```

### go test (Go)

**Basic command**:
```bash
go test ./...
```

**Verbose**:
```bash
go test -v ./...
```

**With coverage**:
```bash
go test -cover ./...
```

## Linters

### ESLint (Node.js/TypeScript)

**Basic command**:
```bash
npm run lint
# or
eslint .
```

**With TypeScript**:
```bash
eslint . --ext .ts,.tsx
```

**Fix automatically**:
```bash
eslint . --fix
```

**Specific files**:
```bash
eslint src/**/*.ts
```

**Output format**: file:line:column with rule names

### Ruff (Python)

**Basic command**:
```bash
ruff check .
```

**Fix automatically**:
```bash
ruff check . --fix
```

**Specific rules**:
```bash
ruff check . --select E,F
```

**Output format**: file:line:column with rule codes

### clippy (Rust)

**Basic command**:
```bash
cargo clippy
```

**Warnings as errors**:
```bash
cargo clippy -- -D warnings
```

**Output format**: file:line:column with lint names

### golangci-lint (Go)

**Basic command**:
```bash
golangci-lint run
```

**Specific linters**:
```bash
golangci-lint run --enable-all
```

## Type Checkers

### TypeScript (tsc)

**Basic command**:
```bash
tsc --noEmit
```

**Watch mode**:
```bash
tsc --noEmit --watch
```

**Specific project**:
```bash
tsc --noEmit -p tsconfig.json
```

**Output format**: file(line,column): error TS#### message

### mypy (Python)

**Basic command**:
```bash
mypy .
```

**Strict mode**:
```bash
mypy . --strict
```

**Specific files**:
```bash
mypy src/calculator.py
```

**Output format**: file:line: error: message

### Go vet (Go)

**Basic command**:
```bash
go vet ./...
```

**Output format**: file:line:column: message

## Build Tools

### Vite (Node.js/TypeScript)

**Basic command**:
```bash
npm run build
# or
vite build
```

**Watch mode**:
```bash
vite build --watch
```

### Webpack (Node.js/TypeScript)

**Basic command**:
```bash
npm run build
# or
webpack
```

**Production mode**:
```bash
webpack --mode production
```

### cargo build (Rust)

**Basic command**:
```bash
cargo build
```

**Release mode**:
```bash
cargo build --release
```

### go build (Go)

**Basic command**:
```bash
go build
```

**All packages**:
```bash
go build ./...
```

## Output Parsing Patterns

### Common Error Formats

**Node.js/TypeScript**:
```
  FAIL  src/calculator.test.ts
    ● multiply › should multiply two numbers
      Expected: 12
      Received: 7
      15 |     const result = calc.multiply(3, 4);
      16 |     expect(result).toBe(12);
         |                    ^
```

**Python**:
```
tests/test_calculator.py::test_multiply FAILED
E       AssertionError: assert 7 == 12
E        +  where 7 = multiply(3, 4)
tests/test_calculator.py:15: AssertionError
```

**Rust**:
```
---- tests::test_multiply stdout ----
thread 'tests::test_multiply' panicked at 'assertion failed: `(left == right)`
  left: `7`,
 right: `12`', src/lib.rs:15:5
```

### Extracting file:line

**Regex patterns**:
- Node.js: `(\S+\.(?:ts|js)):(\d+):(\d+)`
- Python: `(\S+\.py):(\d+)`
- Rust: `(\S+\.rs):(\d+):(\d+)`
- Go: `(\S+\.go):(\d+):(\d+)`

## Best Practices

1. **Always capture stderr**: Use `2>&1` to capture all output
2. **Check exit codes**: 0 = success, non-zero = failure
3. **Timeout commands**: Prevent hanging tests
4. **Save to temp files**: For detailed analysis
5. **Parse incrementally**: Don't load entire output into memory
