# Project Type Detection Guide

Complete reference for detecting project types and extracting validation configurations.

## Detection Method

Scan for configuration files in project root:

1. **Node.js/TypeScript**: `package.json`
2. **Python**: `pyproject.toml`, `requirements.txt`, `setup.py`
3. **Rust**: `Cargo.toml`
4. **Go**: `go.mod`

## Node.js/TypeScript Projects

### Detection Files
- `package.json` (required)
- `tsconfig.json` (indicates TypeScript)
- `.eslintrc.*` (indicates ESLint usage)

### Command Extraction
Read `package.json` scripts section:

```bash
cat package.json | grep -A 30 '"scripts"'
```

**Common script names**:
- `test`: npm test, jest, vitest
- `lint`: eslint, npm run lint
- `typecheck`: tsc --noEmit
- `build`: npm run build, vite build, webpack

**Example package.json**:
```json
{
  "scripts": {
    "test": "jest",
    "lint": "eslint . --ext .ts,.tsx",
    "typecheck": "tsc --noEmit",
    "build": "vite build"
  }
}
```

**Extracted commands**:
```json
{
  "test": "npm test",
  "lint": "npm run lint",
  "typecheck": "npm run typecheck",
  "build": "npm run build"
}
```

## Python Projects

### Detection Files
- `pyproject.toml` (modern Python projects)
- `requirements.txt` (dependency list)
- `setup.py` (legacy projects)

### Command Extraction
Check for tool configurations in `pyproject.toml`:

```bash
grep -A 10 "\[tool.pytest\]" pyproject.toml
grep -A 10 "\[tool.ruff\]" pyproject.toml
grep -A 10 "\[tool.mypy\]" pyproject.toml
```

**Common tools**:
- `pytest` - Testing framework
- `ruff` - Fast Python linter
- `mypy` - Type checker
- `black` - Code formatter

**Example pyproject.toml**:
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100

[tool.mypy]
strict = true
```

**Extracted commands**:
```json
{
  "test": "pytest",
  "lint": "ruff check .",
  "typecheck": "mypy ."
}
```

## Rust Projects

### Detection Files
- `Cargo.toml` (required)

### Command Extraction
Standard Rust commands (no extraction needed):

```json
{
  "test": "cargo test",
  "lint": "cargo clippy",
  "build": "cargo build"
}
```

## Go Projects

### Detection Files
- `go.mod` (required)

### Command Extraction
Standard Go commands (no extraction needed):

```json
{
  "test": "go test ./...",
  "lint": "golangci-lint run",
  "build": "go build"
}
```

## Edge Cases

### Multiple Package Managers

If both `package.json` and `yarn.lock`/`pnpm-lock.yaml` exist:
- Use `yarn test` instead of `npm test`
- Use `pnpm test` instead of `npm test`

Detection:
```bash
if [ -f "yarn.lock" ]; then
  PKG_MANAGER="yarn"
elif [ -f "pnpm-lock.yaml" ]; then
  PKG_MANAGER="pnpm"
else
  PKG_MANAGER="npm"
fi
```

### Monorepos

For workspaces/monorepos:
- Check root `package.json` for workspace configuration
- May need to run commands with workspace flags
- Example: `npm test --workspace=packages/core`

### Missing Scripts

If `package.json` exists but no test script:
- Check for common test files: `*.test.js`, `*.spec.js`
- Infer test runner from dependencies: jest, vitest, mocha
- Suggest adding test script to package.json
