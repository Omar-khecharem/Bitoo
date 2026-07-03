# Contributing to BITOO

Thank you for your interest in contributing to BITOO! We ask that you please adhere to the following guidelines.

---

## 📋 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

---

## 🚀 Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Bitoo.git
   cd Bitoo
   ```
3. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feat/my-feature    # or fix/issue-123
   ```
4. **Make your changes** following our [coding standards](CODING_STANDARDS.md).
5. **Test** your changes:
   ```bash
   flutter analyze
   flutter test
   ```
6. **Commit** using conventional commits (see below).
7. **Push** and open a Pull Request.

---

## ✅ Pull Request Checklist

- [ ] Code follows [CODING_STANDARDS.md](CODING_STANDARDS.md)
- [ ] `flutter analyze` passes with no new warnings or errors
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated (README, dartdoc, etc.)
- [ ] CHANGELOG.md updated under `[Unreleased]`
- [ ] Branch name follows convention: `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`

---

## 🧪 Testing Requirements

- All new features must include unit/widget tests.
- Bug fixes must include a test that reproduces the issue.
- Run `flutter test --coverage` and ensure coverage does not decrease.

---

## 📝 Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

[optional body]

[optional footer(s)]
```

| Type       | Usage                      |
|------------|----------------------------|
| `feat`     | New feature                |
| `fix`      | Bug fix                    |
| `refactor` | Code change with no fix/feature |
| `docs`     | Documentation only         |
| `test`     | Adding or fixing tests     |
| `chore`    | Build, CI, dependencies    |
| `perf`     | Performance improvement    |

**Examples:**
```
feat(player): add sleep timer with configurable duration
fix(scanner): handle files with no extension gracefully
refactor(audio_engine): extract preset serialization
docs(api): update repository method docs
```

---

## 🔄 Branch Naming

| Branch Pattern  | Purpose              |
|-----------------|----------------------|
| `main`          | Stable, release-ready |
| `feat/*`        | New features         |
| `fix/*`         | Bug fixes            |
| `refactor/*`    | Code refactoring     |
| `docs/*`        | Documentation        |
| `chore/*`       | Maintenance          |

---

## 🐛 Reporting Bugs

Open an issue at [github.com/Omar-khecharem/Bitoo/issues](https://github.com/Omar-khecharem/Bitoo/issues) with:

- A clear, descriptive title
- Steps to reproduce
- Expected vs actual behavior
- Device model, Android version, BITOO version
- Screenshots or screen recordings if applicable

---

## 💡 Feature Requests

Open an issue with the label `enhancement` describing:

- The problem you're trying to solve
- Your proposed solution
- Any alternatives you've considered

---

## 🔒 Security Vulnerabilities

Please **do not** open a public issue for security vulnerabilities. Send details to **khcharem.omar@gmail.com**.
