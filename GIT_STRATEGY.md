# BITOO Git Strategy & Branching Model

---

##  Branching Model: Trunk-Based Development with Feature Flags

We use **Trunk-Based Development** (not GitFlow) for faster CI/CD, fewer merge
conflicts, and simpler rollbacks. Feature flags provide isolation without
long-lived branches.

```
main ───●──────────●──────────●──────────●──────────●──
         \        / \        / \        / \        /
feat/   ──●──●──●   ──●──●──●   ──●──●──●   ──●──●──●
```

### Branch Types

| Branch | Source | Target | Lifetime | Naming |
|--------|--------|--------|----------|--------|
| `main` | — | — | Permanent | `main` |
| `feat/` | `main` | `main` | Days | `feat/BT-123-login-biometric` |
| `fix/` | `main` | `main` | Hours | `fix/BT-456-crash-on-null` |
| `chore/` | `main` | `main` | Hours | `chore/BT-789-update-deps` |
| `refactor/` | `main` | `main` | Hours | `refactor/BT-321-migrate-provider` |
| `release/` | `main` | `main` | Tagged | `release/v1.2.3` |
| `hotfix/` | `main` | `main` | Hours | `hotfix/BT-999-critical-crash` |

### Commit Message Convention (Conventional Commits)

```
<type>(<scope>): <short summary>

[optional body]

[optional footer]
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `chore` — Maintenance (deps, config, scripts)
- `refactor` — Code change (no behavior change)
- `perf` — Performance improvement
- `test` — Adding/fixing tests
- `docs` — Documentation
- `style` — Formatting (no logic change)
- `ci` — CI/CD changes
- `revert` — Revert a previous commit

**Scopes:**
- `player`, `auth`, `home`, `search`, `library`, `playlist`, `album`,
  `artist`, `explore`, `settings`, `downloads`, `equalizer`, `notifications`,
  `social`, `onboarding`, `splash`, `audio_service`, `core`, `router`, `theme`,
  `cache`, `analytics`, `security`, `ci`, `deps`, `docs`

**Examples:**
```
feat(auth): add biometric authentication

fix(player): prevent crash when queue is empty

feat(core): implement tiered cache with LRU eviction

refactor(search): migrate to Riverpod code generation

chore(deps): update dio to 5.4.0

test(playlist): add unit tests for reorder use case

docs(ARCHITECTURE.md): update data flow diagram
```

### Pull Request Standards

- **Title:** Same as conventional commit format
- **Description template:**

```markdown
## Description
[Brief description of changes]

## Ticket
BT-123

## Type
- [ ] feat
- [ ] fix
- [ ] refactor
- [ ] chore
- [ ] test
- [ ] docs

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing performed

## Checklist
- [ ] Code follows BITOO coding standards
- [ ] No lint errors
- [ ] No analysis warnings
- [ ] All tests pass
- [ ] Code coverage maintained or improved
- [ ] Documentation updated if needed
- [ ] Feature flag added for new features
```

### Code Review Rules

1. Every PR requires **at least 1 approval**
2. No self-approval
3. Maximum PR size: **400 lines changed** (exclude generated code)
4. Max PR lifetime: **48 hours**
5. Squash-merge with conventional commit message
6. Delete branch after merge

### CI/CD Pipeline (GitHub Actions)

```
┌──────────┐   ┌───────────┐   ┌────────────┐   ┌──────────┐
│   Lint   │ → │  Analyze  │ → │    Test     │ → │   Build  │
│ dart fix │   │ dart_code │   │ unit/widget │   │   APK    │
│  --dry-run│   │ _metrics  │   │  + coverage │   │          │
└──────────┘   └───────────┘   └────────────┘   └──────────┘
                                     │
                               ┌─────▼─────┐
                               │  Report   │
                               │ Coverage  │
                               └───────────┘
```

### Versioning (SemVer)

```
vMAJOR.MINOR.PATCH

MAJOR: Breaking changes (UI redesign, DB migration, API contract break)
MINOR: New features (non-breaking)
PATCH: Bug fixes (non-breaking)
```

Format: `v1.2.3+456` where `456` is the build number (GitHub run number).
