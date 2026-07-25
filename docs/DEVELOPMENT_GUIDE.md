# Development Guide

This document describes how to set up, develop, and maintain Mindora.

---

## Environment Setup

### Prerequisites

- **Flutter SDK:** 3.44+ (stable channel)
- **Dart:** 3.12+ (ships with Flutter)
- **Operating System:** Windows, macOS, or Linux
- **Code Editor:** VS Code (recommended), Android Studio, or IntelliJ

### Installing Flutter

Follow the official guide: [Flutter Install](https://docs.flutter.dev/get-started/install)

Verify installation:

```bash
flutter --version
```

### IDE Setup

Recommended VS Code extensions:

- **Flutter** (Dart Code) — official Dart/Flutter support
- **Error Lens** — inline error display
- **GitLens** — git annotations
- **Markdown All in One** — documentation editing

---

## Flutter Version Requirements

- **Channel:** `stable`
- **Flutter:** `>=3.44.0`
- **Dart:** `>=3.12.0 <4.0.0`

Version is pinned in `pubspec.yaml`:

```yaml
environment:
  sdk: ^3.12.2
```

Use `flutter upgrade` to stay on the latest stable.

---

## Development Workflow

### Recommended Workflow

1. **Understand** — Read the task description and relevant documentation.
2. **Inspect** — Examine existing code to understand current state and patterns.
3. **Plan** — Determine the minimal change needed; check for existing solutions.
4. **Implement** — Write code following project conventions.
5. **Verify** — Format, analyze, test.
6. **Document** — Update documentation if architecture or design system changes.
7. **Review** — Check diff for completeness and correctness.

### Branching

- `main` — Stable, production-ready code
- Feature branches: `feature/<short-description>`
- Bug fix branches: `fix/<short-description>`

Branch from `main`, merge back via pull request.

---

## Code Formatting

Always format code before committing:

```bash
dart format .
```

The project uses default Dart formatting conventions. No custom `dartfmt` configuration is defined.

---

## Static Analysis

Run the analyzer to catch issues:

```bash
flutter analyze
```

The project uses `package:flutter_lints` with the `flutter.yaml` rule set. No custom lint rules are currently configured.

The analyzer **must pass with no issues** before any commit.

---

## Testing

Run all tests:

```bash
flutter test
```

### Test Structure

- Tests are in `test/` directory, mirroring `lib/` structure.
- Test file naming: `<feature>_test.dart` for unit tests, `<feature>_test.dart` for widget tests.
- Use `bloc_test` for Cubit behavior testing.
- Each feature should include meaningful tests covering:
  - Normal operation (happy path)
  - Edge cases
  - Error states (where applicable)

### AI Feature Testing

The AI feature (`lib/features/ai/`) has its own test suite:

```bash
flutter test test/features/ai/
```

Covers:
- **Domain models:** AIProposal sealed types, AIContext creation, AIResponse
- **Data layer:** MindContextBuilder (Mind → AIContext), LocalAIService (deterministic analysis)
- **Presentation:** AICubit (open/close panel, analyze, success/failure, retry, clear)

Key testing patterns:
- Create test `Mind` instances directly (no persistence needed for AI).
- `LocalAIService` is deterministic — same input always produces same output.
- Test AI proposals are created with correct types and content.
- Test AICubit transitions through all states (initial → loading → success/failure).

### Testing with GetIt

When testing widgets that depend on GetIt-registered services:

1. Register dependencies in `setUp()`.
2. Reset in `tearDown()` using `sl.reset(dispose: false)`.
3. Unit tests for Cubits should create them directly without GetIt.

### Test Coverage

- No coverage threshold is set yet.
- New features should include reasonable test coverage from the start.

---

## Commit Expectations

- Write clear, concise commit messages.
- Use imperative mood: "Add feature" not "Added feature".
- Reference related documentation if applicable.
- Keep commits focused on a single logical change.
- Ensure `flutter analyze` and `flutter test` pass before committing.

---

## Documentation Expectations

- Update `docs/` files when architecture, design tokens, or product decisions change.
- Do not duplicate large sections across documents — `README.md` summarizes, `docs/` provides detail.
- Mark new capabilities with their implementation status.
- Keep `PROJECT_STATUS.md` up to date with current priorities and limitations.
- When adding new design tokens, update `DESIGN_SYSTEM.md`.
- When making architecture decisions, update `DECISIONS.md`.

---

## Feature Development Workflow

1. Create a feature branch from `main`.
2. Create feature directory under `lib/features/<name>/`.
3. Create Cubit + State in `lib/features/<name>/presentation/cubit/`.
4. Create page widget in `lib/features/<name>/presentation/pages/`.
5. Register route in `lib/app/router/app_router.dart`.
6. Register Cubit in `lib/app/di.dart` using `registerFactory`.
7. Add tests in `test/features/<name>/presentation/cubit/` and `test/features/<name>/presentation/pages/`.
8. Run `dart format .` and `flutter analyze` after each change.
9. Ensure tests pass.
10. Open a pull request to `main`.

### Convention: Cubit Initialization

- Cubits should expose a `load()` method that initializes state.
- Pages call `..load()` when creating the Cubit in `BlocProvider`.

### Convention: Page Structure

```dart
class MyFeaturePage extends StatelessWidget {
  const MyFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyFeatureCubit>()..load(),
      child: const _Body(),
    );
  }
}
```

### AI Feature Development

When adding or modifying AI capabilities:

1. **AIService interface** — Add analysis methods to the abstract service.
2. **LLMAIService** — Implement the method using LLM runtime with heuristic fallback.
3. **LocalLLMRuntime** — Add inference methods to the runtime interface.
4. **AICubit** — Add state transitions for the new analysis type.
5. **AIPanel/ProposalCard** — Add UI for new proposal types.
6. **Tests** — Cover all states (loading, success, failure, model states) and edge cases.

The `AIService` interface is the contract. Any implementation (LLM, heuristic, future) must satisfy it without changing other layers.

### LLM Development

The LLM architecture has three layers:

1. **LocalLLMRuntime (abstract)** — Interface for model inference. Methods: `status`, `initialize()`, `generate()`, `dispose()`.
2. **ProcessLLMRuntime** — Desktop implementation using `dart:io` Process to spawn llama.cpp CLI.
3. **LLMAIService** — Wraps the runtime + heuristic fallback under the `AIService` interface.

#### Testing LLM Code

- Use `_MockLLMRuntime` (or similar) to test `LLMAIService` without a real model.
- Test `LLMResponseParser` with sample LLM output strings.
- Test `ModelManager` with temp directories — no real model needed.
- The `ProcessLLMRuntime` tests verify lifecycle (init, unload, dispose, error states) but don't require a real llama.cpp binary.

#### Setting Up Local LLM for Manual Testing

1. Download a llama.cpp compatible executable (e.g., `llama-cli` from https://github.com/ggerganov/llama.cpp/releases)
2. Download a GGUF model (e.g., Qwen2.5-1.5B-Instruct-Q4_K_M from HuggingFace)
3. Place both in `~/.mindora/models/` (or `%USERPROFILE%\.mindora\models\` on Windows)
4. The AI panel will auto-detect the model on open
5. Or set paths in `AIConfig` (modelPath, llamaExecutablePath)

---

## Refactoring Rules

- **One thing at a time** — Do not refactor unrelated code in the same change as feature work.
- **Prefer renaming over duplicating** — If a name is wrong, rename it. Do not create a "V2".
- **Keep the analyzer clean** — Refactored code must pass `flutter analyze` with no issues.
- **Update callers** — When renaming or moving code, update all references.
- **Test coverage** — Refactoring should not reduce test coverage.

---

## Dependency Management

### Current Dependencies

| Package | Purpose |
|---|---|
| `flutter` | SDK |
| `cupertino_icons` | iOS-style icons |
| `flutter_bloc` | State management (Cubit/BLoC) |
| `go_router` | Declarative routing |
| `get_it` | Dependency injection |
| `equatable` | Immutable state value equality |
| `shared_preferences` | Local persistence (minds) |

### Adding Dependencies

Before adding a new dependency:

1. Check if the functionality is already available in existing dependencies.
2. Prefer well-maintained, popular packages from `pub.dev`.
3. Consider the dependency's size, licensing, and maintenance status.
4. Add only dependencies that are clearly necessary.

```bash
flutter pub add <package_name>
```

### Updating Dependencies

```bash
flutter pub upgrade
```

Check for outdated packages:

```bash
flutter pub outdated
```

Avoid major version upgrades without testing for breaking changes.
