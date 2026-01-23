# Validation Commands Reference

검증 명령어 전체 참조 가이드

## Node.js/TypeScript

### Test Runners

**Jest**:
```bash
# 기본 실행
npm test
jest

# Watch 모드
jest --watch

# 커버리지
jest --coverage
```

**Vitest**:
```bash
# 기본 실행
npm test
vitest run

# Watch 모드
vitest

# UI 모드
vitest --ui
```

### Linters

**ESLint**:
```bash
# 기본 실행
npm run lint
eslint .

# 자동 수정
eslint --fix .

# 특정 파일
eslint src/**/*.ts
```

### Type Checkers

**TypeScript**:
```bash
# 타입 체크만 (빌드 없음)
tsc --noEmit

# Watch 모드
tsc --noEmit --watch

# 특정 프로젝트
tsc --project tsconfig.json --noEmit
```

### Build Tools

**Vite**:
```bash
npm run build
vite build
```

**Webpack**:
```bash
npm run build
webpack
```

## Python

### Test Runners

**pytest**:
```bash
# 기본 실행
pytest

# Verbose 모드
pytest -v

# 커버리지
pytest --cov=src tests/
```

### Linters

**Ruff**:
```bash
# Lint 체크
ruff check .

# 자동 수정
ruff check --fix .

# Format 체크
ruff format --check .
```

### Type Checkers

**mypy**:
```bash
# 기본 실행
mypy .

# Strict 모드
mypy --strict src/

# 특정 파일
mypy src/main.py
```

## Rust

### Test

```bash
# 모든 테스트
cargo test

# 특정 테스트
cargo test test_name

# Doc 테스트 포함
cargo test --all-targets
```

### Lint

```bash
# Clippy 실행
cargo clippy

# 경고를 오류로 처리
cargo clippy -- -D warnings
```

### Check

```bash
# 컴파일 체크만
cargo check

# 모든 타겟 체크
cargo check --all-targets
```

## Go

### Test

```bash
# 모든 테스트
go test ./...

# Verbose 모드
go test -v ./...

# 커버리지
go test -cover ./...
```

### Lint

```bash
# golangci-lint
golangci-lint run

# 특정 linter
golangci-lint run --enable-only=errcheck
```

### Vet

```bash
# 기본 실행
go vet ./...

# 특정 패키지
go vet ./pkg/...
```

## Exit Codes

- `0`: 성공
- `1`: 실패 (테스트 실패, lint 오류 등)
- `2`: 명령어 오류 (잘못된 플래그 등)

## Output Capture

모든 출력 캡처:
```bash
command 2>&1 | tee output.log
```

Exit code 보존:
```bash
command 2>&1 | tee output.log; exit ${PIPESTATUS[0]}
```
