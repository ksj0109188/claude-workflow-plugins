# Claude Workflow Plugins

프로덕션급 워크플로우 자동화를 위한 Claude Code 플러그인 컬렉션

## 📦 포함된 플러그인

### 1. Validation Framework
**Universal validation framework implementing Boris Cherny's principles #12 & #13**

- ✅ 자동 프로젝트 감지 (Node.js, Python, Rust, Go)
- ✅ 다단계 검증 (테스트, 린트, 타입체크, 빌드)
- ✅ 지능형 실패 분석 (파일:라인 위치)
- ✅ 자동 재시도 루프 (최대 10회)
- ✅ 상태 관리 및 로깅

**설치:**
```bash
cc --plugin-dir ~/path/to/claude-workflow-plugins/plugins/validation-framework
```

**문서:** [plugins/validation-framework/README.md](./plugins/validation-framework/README.md)

---

## 🚀 빠른 시작

### 전체 저장소 클론

```bash
git clone https://github.com/ksj0109188/claude-workflow-plugins.git
```

### 특정 플러그인만 로드

```bash
# Validation Framework
cc --plugin-dir ~/claude-workflow-plugins/plugins/validation-framework
```

### 로컬 개발 모드

```bash
# 특정 플러그인 테스트
cc --plugin-dir ./claude-workflow-plugins/plugins/validation-framework

# 여러 플러그인 동시 로드
cc --plugin-dir ./claude-workflow-plugins/plugins/validation-framework \
   --plugin-dir ./claude-workflow-plugins/plugins/[other-plugin]
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

## 🔧 요구사항

- **Claude Code**: 2.1.0 이상
- **Node.js**: 18+ (Node.js 프로젝트 검증 시)
- **Python**: 3.8+ (Python 프로젝트 검증 시)

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

## 📮 문의

- **GitHub Issues**: https://github.com/ksj0109188/claude-workflow-plugins/issues
- **Author**: ksj0109188

---

**Made with ❤️ for Claude Code automation**
