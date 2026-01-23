# Project Types Detection Guide

프로젝트 타입을 감지하는 방법 및 패턴 가이드

## Node.js/TypeScript

**감지 파일**:
- `package.json` (필수)
- `tsconfig.json` (TypeScript 프로젝트)
- `node_modules/` 디렉토리

**Scripts 추출**:
```bash
# package.json에서 scripts 추출
jq '.scripts' package.json

# 또는 grep 사용
grep -A 20 '"scripts"' package.json
```

**일반적인 명령어**:
- test: `npm test`, `jest`, `vitest`
- lint: `eslint`, `npm run lint`
- typecheck: `tsc --noEmit`
- build: `npm run build`, `vite build`

## Python

**감지 파일**:
- `pyproject.toml` (Poetry, modern Python)
- `requirements.txt` (pip)
- `setup.py` (legacy)
- `Pipfile` (pipenv)

**도구 감지**:
```bash
# pytest 확인
grep -r "pytest" pyproject.toml

# ruff 확인
grep -r "ruff" pyproject.toml

# mypy 확인
grep -r "mypy" pyproject.toml
```

**일반적인 명령어**:
- test: `pytest`
- lint: `ruff check .`
- typecheck: `mypy .`
- format: `ruff format .`

## Rust

**감지 파일**:
- `Cargo.toml`
- `src/` 디렉토리

**일반적인 명령어**:
- test: `cargo test`
- lint: `cargo clippy`
- check: `cargo check`
- build: `cargo build`

## Go

**감지 파일**:
- `go.mod`
- `go.sum`

**일반적인 명령어**:
- test: `go test ./...`
- lint: `golangci-lint run`
- vet: `go vet ./...`
- build: `go build ./...`

## Detection Priority

1. Node.js/TypeScript (가장 흔함)
2. Python
3. Rust
4. Go
5. Multi-language (둘 이상 감지 시)

## Multi-Language Projects

여러 언어가 혼재된 프로젝트:
- 각 언어별로 별도 검증 실행
- 우선순위: package.json > pyproject.toml > Cargo.toml > go.mod
