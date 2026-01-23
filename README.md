# Claude Workflow Plugins

[![Validate Plugins](https://github.com/ksj0109188/claude-workflow-plugins/actions/workflows/validate-plugins.yml/badge.svg)](https://github.com/ksj0109188/claude-workflow-plugins/actions/workflows/validate-plugins.yml)

프로덕션급 워크플로우 자동화를 위한 Claude Code 플러그인 컬렉션

## 📦 포함된 플러그인

### 1. Work Completion Workflow
**4-stage workflow for completing work sessions: Memory → Review → Cleanup → Commit**

- ✅ 자동 메모리 업데이트 (`.claude/memory/`)
- ✅ 6개 agent 딥 코드 리뷰 (pr-review-toolkit 통합)
- ✅ 스마트 파일 클린업 (패턴 학습)
- ✅ Git 자동 커밋 (commit-commands 통합)
- ✅ Critical 이슈 자동 차단 (Stop Hook)

**설치:**
```bash
cd ~/claude-workflow-plugins
ln -s "$(pwd)/work-completion-workflow" ~/.claude/plugins/
```

**사용:**
```
/complete-work
```

**문서:** [work-completion-workflow/README.md](./work-completion-workflow/README.md)

---

### 2. Validation Framework
**Universal validation framework implementing Boris Cherny's principles #12 & #13**

- ✅ 자동 프로젝트 감지 (Node.js, Python, Rust, Go)
- ✅ 다단계 검증 (테스트, 린트, 타입체크, 빌드)
- ✅ 지능형 실패 분석 (파일:라인 위치)
- ✅ 자동 재시도 루프 (최대 10회)
- ✅ 상태 관리 및 로깅

**설치:**
```bash
cd ~/claude-workflow-plugins
ln -s "$(pwd)/validation-framework" ~/.claude/plugins/
```

**문서:** [validation-framework/README.md](./validation-framework/README.md)

---

## 🚀 빠른 시작

### 방법 1: Marketplace를 통한 설치 (권장)

**1단계: Marketplace 추가**
```bash
/plugin marketplace add ksj0109188/claude-workflow-plugins
```

**2단계: 플러그인 설치**
```bash
# Work Completion Workflow 설치
/plugin install work-completion-workflow@claude-workflow-plugins

# Validation Framework 설치
/plugin install validation-framework@claude-workflow-plugins
```

**3단계: 사용**
```
/complete-work
/validate
```

---

### 방법 2: 수동 설치

**전체 저장소 클론**
```bash
git clone https://github.com/ksj0109188/claude-workflow-plugins.git
cd claude-workflow-plugins

# Work Completion Workflow 설치
ln -s "$(pwd)/work-completion-workflow" ~/.claude/plugins/

# Validation Framework 설치
ln -s "$(pwd)/validation-framework" ~/.claude/plugins/
```

**특정 플러그인만 로드**
```bash
cc --plugin-dir ~/claude-workflow-plugins/work-completion-workflow
```

**로컬 개발 모드**
```bash
# 특정 플러그인 테스트
cc --plugin-dir ./work-completion-workflow

# 여러 플러그인 동시 로드
cc --plugin-dir ./work-completion-workflow \
   --plugin-dir ./validation-framework
```

---

## 📚 플러그인 개발 가이드

### 새 플러그인 추가하기

1. **플러그인 디렉토리 생성**
```bash
mkdir -p your-plugin/{.claude-plugin,commands,agents,skills,hooks}
```

2. **필수 파일 작성**
- `.claude-plugin/plugin.json` - 플러그인 메타데이터
- `README.md` - 플러그인 문서
- `commands/` - 슬래시 커맨드
- `skills/` - 스킬 정의
- `agents/` - 전문 에이전트
- `hooks/` - 이벤트 훅

3. **테스트**
```bash
cc --plugin-dir ./your-plugin
```

4. **커밋 & Push**
```bash
git add your-plugin/
git commit -m "Add your-plugin"
git push
```

### 플러그인 구조 예시

```
claude-workflow-plugins/
└── plugins/                    # ← 필수 디렉토리
    └── validation-framework/
        ├── .claude-plugin/
        │   └── plugin.json     # 메타데이터
        ├── README.md           # 플러그인 문서
        ├── commands/
        │   └── validate.md     # /validate 커맨드
        ├── agents/
        │   ├── project-detector.md
        │   ├── validator.md
        │   └── report-generator.md
        ├── skills/
        │   └── validate/
        │       └── SKILL.md
        └── hooks/
            ├── hooks.json
            └── scripts/
```

---

## 🧪 테스트

### 로컬 검증

```bash
# 구조 검증
bash tests/validate.sh

# 통합 테스트
bash tests/integration-test.sh
```

### CI/CD

모든 push와 PR은 자동으로 검증됩니다:
- ✅ 플러그인 구조 검증
- ✅ Agent/Skill/Hook 통합 테스트
- ✅ Stop Hook promise tag 파싱 테스트

---

## 🔧 요구사항

- **Claude Code**: 2.1.0 이상
- **Node.js**: 18+ (Node.js 프로젝트 검증 시)
- **Python**: 3.8+ (Python 프로젝트 검증 시)
- **jq**: JSON 파싱 (테스트 시 권장)

---

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능

---

## 🤝 기여하기

이슈 및 PR 환영합니다!

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/amazing-plugin`)
3. Commit your changes (`git commit -m 'Add amazing plugin'`)
4. Push to the branch (`git push origin feature/amazing-plugin`)
5. Open a Pull Request

---

## 🌐 Marketplace

이 저장소는 Claude Code Marketplace로 사용할 수 있습니다.

### 자체 호스팅 Marketplace
```bash
# Marketplace 추가
/plugin marketplace add ksj0109188/claude-workflow-plugins

# 플러그인 설치
/plugin install work-completion-workflow@claude-workflow-plugins
/plugin install validation-framework@claude-workflow-plugins
```

### 공식 Marketplace 제출
공식 Anthropic Marketplace에 제출하려면:
- [Plugin Directory Submission Form](https://clau.de/plugin-directory-submission)
- 품질 및 보안 기준 충족 필요
- 승인 후 `/plugin search` 에서 검색 가능

---

## 📮 문의

- **GitHub Issues**: https://github.com/ksj0109188/claude-workflow-plugins/issues
- **Author**: ksj0109188

---

**Made with ❤️ for Claude Code automation**
