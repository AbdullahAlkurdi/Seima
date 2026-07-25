# Contributing to Mindora

---

## Code Quality Expectations

- All code must pass `flutter analyze` with no issues.
- All code must be formatted with `dart format .`.
- All tests must pass.
- Code should be readable and well-structured — clarity over cleverness.
- Follow the project's naming conventions (see [ARCHITECTURE.md](ARCHITECTURE.md)).
- Avoid dead code, commented-out code, and unnecessary imports.

## Architecture Expectations

- Follow the established architecture and layer separation (see [ARCHITECTURE.md](ARCHITECTURE.md)).
- Do not bypass layer boundaries — presentation code should not directly access data sources.
- Extend existing patterns rather than introducing new ones without discussion.
- New features must integrate with the existing theme system, not bypass it.

## Naming

| Category | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `app_theme.dart` |
| Classes/Enums | `PascalCase` | `AppTheme`, `ThemeMode` |
| Functions/Methods | `camelCase` | `light()`, `incrementCounter()` |
| Variables | `camelCase` | `counter`, `themeMode` |
| Private members | `_` prefix | `_counter` |
| Directories | `snake_case/` | `theme/`, `features/` |
| Test files | `_test.dart` suffix | `widget_test.dart` |

## Testing Requirements

- All new features should include tests.
- Widget tests for UI components.
- Unit tests for business logic.
- Tests should cover normal operation, edge cases, and error states.
- Existing tests must continue to pass.

## Documentation Requirements

- Update relevant `docs/` files when making changes that affect architecture, design tokens, or product decisions.
- Mark implementation status clearly in documentation (`Implemented`, `Planned`, `Future`).
- Keep `PROJECT_STATUS.md` current with work completed and upcoming priorities.
- Do not claim features are implemented unless they are verified in the repository.

## Pull Request Expectations

- PRs should be focused on a single logical change.
- PRs must pass CI checks (analyzer + tests).
- PR description should explain:
  - What the change does
  - Why it's needed
  - How it was tested
  - Any documentation updated
- Squash merge commits to keep history clean.

## Avoiding Duplicate Code

- Before creating a new file, check if similar functionality exists.
- Before creating a new widget, check if a similar widget exists or can be extended.
- Do not create "V2" files when the original can be modified or extended.
- If refactoring is needed before adding new code, do the refactoring as a separate step.

## Avoiding Unnecessary Dependencies

- Before adding a new package, verify that the functionality is not already available:
  - In Flutter SDK
  - In existing project dependencies
  - Implementable with reasonable effort using existing code
- Prefer well-established packages with active maintenance.
- Consider the size and scope of the dependency.

## AI-Assisted Development Rules

When using AI coding agents (including the current agent):

1. **Inspect before acting** — Read existing files before making changes.
2. **Follow the architecture** — Respect existing patterns and layer boundaries.
3. **No V2/V3 files** — Extend what exists rather than creating new versions.
4. **No duplicate implementations** — If code already exists for a purpose, use it.
5. **No unrelated changes** — Change only what the task requires.
6. **Verify before committing** — Run formatter, analyzer, and tests.
7. **Document changes** — Update relevant documentation when architecture or design changes.

## License

By contributing, you agree that your contributions will be licensed under the project's current license (Proprietary — all rights reserved).
