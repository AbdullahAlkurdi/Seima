# Architecture Decision Records

This document logs significant decisions made during Seima's development. Each entry records a decision, its context, rationale, and consequences.

New decisions should be added as the project evolves.

---

## ADR-001: Flutter as Application Framework

**Status:** Confirmed

**Date:** 2026-07 (project inception)

**Decision:** Build Seima as a Flutter application using the Dart programming language.

**Context:** Seima needs to run on multiple platforms (desktop, web, mobile) with a single codebase. The application requires high-performance rendering for an interactive mind-map canvas, smooth animations, and the ability to integrate with native platform features.

**Rationale:**
- Flutter provides true cross-platform support from a single codebase.
- Flutter's custom rendering engine enables the high-performance canvas required for mind-mapping.
- Strong ecosystem and community support.
- Dart is well-suited for both UI development and business logic.
- Material 3 is natively supported in Flutter 3.x.

**Consequences:**
- Development is constrained to Flutter's capabilities and ecosystem.
- The project can target Android, iOS, Web, Windows, macOS, and Linux.
- Team must be proficient in Flutter and Dart.

---

## ADR-002: Material 3 Design Language

**Status:** Confirmed

**Date:** 2026-07 (project inception)

**Decision:** Use Material 3 as the foundational design language for Seima.

**Context:** The application needs a consistent, modern, and accessible design system. The design should be platform-appropriate while maintaining a distinct identity.

**Rationale:**
- Material 3 provides a comprehensive, accessible design system out of the box.
- Flutter has first-class Material 3 support (`useMaterial3: true`).
- Dynamic color (`ColorScheme.fromSeed`) provides consistent theming with minimal configuration.
- Material 3's accessibility features (contrast, touch targets, typography scale) align with Seima's quality goals.
- Material 3 allows customization while maintaining platform-appropriate defaults.

**Consequences:**
- UI components follow Material 3 conventions and guidelines.
- Custom themes are built on top of Material 3 rather than replacing it.
- Users familiar with Material Design will find Seima intuitive.

---

## ADR-003: Centralized Theme System

**Status:** Confirmed

**Date:** 2026-07 (initial visual foundation)

**Decision:** Centralize all design tokens (colors, typography, spacing) in dedicated files with a static factory (`AppTheme`) for building `ThemeData`.

**Context:** The application needs a consistent visual identity. Hardcoded values scattered across widgets lead to inconsistency and difficult maintenance.

**Rationale:**
- Centralized tokens ensure a single source of truth for design values.
- Static `AppTheme.light()` and `AppTheme.dark()` factories make theme application simple and testable.
- Separate files for colors, typography, and spacing keep the system organized and extensible.
- Eliminates hardcoded design values in widget code.
- Makes future design changes manageable (update one file, not hundreds of widgets).

**Consequences:**
- All widgets must reference `AppColors`, `AppTypography`, and `AppSpacing` tokens.
- New design tokens should be added to the appropriate file.
- The theme file (`app_theme.dart`) is the single point where `ThemeData` is constructed.

---

## ADR-004: Light and Dark Theme Support

**Status:** Confirmed

**Date:** 2026-07 (initial visual foundation)

**Decision:** Support both light and dark themes from the start, with a `ThemeController` that manages the current `ThemeMode` (light, dark, system).

**Context:** Users expect applications to respect their system theme preference and offer manual light/dark switching.

**Rationale:**
- Implementing both themes from the start prevents dark-themed widgets from being an afterthought.
- Material 3's `ColorScheme.fromSeed` generates both light and dark schemes automatically.
- `ValueNotifier<ThemeMode>` via `ThemeController` is a simple, sufficient approach for the current stage.
- `InheritedWidget` (`SeimaTheme`) allows descendant widgets to access the theme controller without prop drilling.

**Consequences:**
- Every new widget or component must be tested in both light and dark themes.
- Semantic colors need both light and dark variants.
- The `ThemeController` remains in place (not migrated to Cubit) since it works well as a simple ValueNotifier.

---

## ADR-005: InheritedWidget for Theme Propagation

**Status:** Confirmed

**Date:** 2026-07 (initial visual foundation)

**Decision:** Use `InheritedWidget` (`SeimaTheme`) to propagate the `ThemeController` through the widget tree.

**Context:** The theme controller needs to be accessible from any widget without being passed explicitly through constructors.

**Rationale:**
- `InheritedWidget` is a Flutter primitive with no external dependencies.
- It provides efficient O(1) access for descendant widgets.
- It integrates naturally with `ValueListenableBuilder` for reactive theme switching.
- Avoided adding a dependency injection framework before the architecture needed it.

**Consequences:**
- Widgets access the controller via `SeimaTheme.of(context)`.
- The approach remains in place alongside GetIt (theme controller is now also registered in DI).
- `SeimaTheme` still provides convenient type-safe access.

---

## ADR-006: BLoC/Cubit for State Management

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Use BLoC/Cubit pattern via `flutter_bloc` package for application state management.

**Context:** The application needed a consistent, testable, and scalable state management approach as feature development begins.

**Rationale:**
- BLoC/Cubit enforces clear separation between UI and business logic.
- `Cubit` provides a simple API for most state needs without event boilerplate.
- `bloc_test` package provides excellent testing utilities.
- Widely adopted in the Flutter community with strong documentation.
- Scales well from simple (Cubit) to complex (BLoC with events).

**Consequences:**
- All feature state management uses Cubit (or BLoC when event complexity justifies it).
- State classes are immutable and use `Equatable` for value equality.
- Cubits are testable without widget framework.
- Business logic lives in Cubits, not widgets.

---

## ADR-007: GoRouter for Routing

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Use `go_router` for declarative, scalable routing.

**Context:** The application needed a routing solution that supports named routes, deep linking, and future authentication gating. The default `MaterialApp` `home:` property was no longer sufficient.

**Rationale:**
- `go_router` is the most widely adopted declarative router for Flutter.
- Supports named routes, path parameters, redirects, and nested navigation.
- Integrates with `MaterialApp.router` cleanly.
- Well-maintained by the Flutter team.

**Consequences:**
- All route configuration is centralized in `lib/app/router/app_router.dart`.
- Use `context.goNamed('routeName')` for navigation.
- Future auth guards and deep linking are straightforward to add.

---

## ADR-008: GetIt for Dependency Injection

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Use `get_it` as the dependency injection container.

**Context:** The application needed a simple DI solution to manage service lifetimes and decouple widget code from object creation. Manual instantiation and InheritedWidget chains were becoming unwieldy.

**Rationale:**
- `get_it` is a lightweight, well-established service locator for Dart.
- Zero boilerplate (no code generation required).
- Supports different lifetimes (singleton, lazy singleton, factory).
- Simple API with minimal learning curve.
- Easy to reset in tests.

**Consequences:**
- DI registration is centralized in `lib/app/di.dart`.
- Cubits use `registerFactory` so each page visit creates a fresh instance.
- Services use `registerLazySingleton`.
- Tests register dependencies in `setUp` and reset in `tearDown`.
- The exported `sl` shorthand provides convenient access.

---

## ADR-009: Feature-First Project Structure

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Organize application code using a feature-first structure under `lib/features/`, with shared infrastructure under `lib/app/` and `lib/core/`.

**Context:** As the project grows, clear organization is needed to prevent files from scattering across directories. The structure must support independent feature development.

**Rationale:**
- Feature-first grouping keeps related code together, making features easier to understand, develop, and remove.
- Separating app infrastructure (`lib/app/`) from shared core (`lib/core/`) from features (`lib/features/`) provides clear boundaries.
- Prevents tight coupling between unrelated features.
- Makes it easy for multiple developers or AI agents to work on different features.

**Consequences:**
- Each feature is a self-contained module under `lib/features/`.
- Features should not directly depend on other features.
- Shared code belongs in `lib/core/` or `lib/app/`.
- New features follow the established pattern (cubit, pages, etc.).

---

## ADR-010: Error Handling Foundation (AppException + Failure)

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Use a lightweight two-type error representation: `AppException` for technical errors and `Failure` for presentation/domain boundary errors.

**Context:** The application needed a consistent error representation strategy before feature development begins, without overengineering for scenarios that don't exist yet.

**Rationale:**
- Separating technical exceptions from user-facing failure representations follows clean architecture principles.
- `AppException` wraps original errors with context (message, code).
- `Failure` provides a clean interface for UI code to handle errors.
- Named factories (`Failure.unknown()`, `Failure.cache()`) provide convenient construction.
- Lightweight enough to extend as real data sources are added.

**Consequences:**
- Data sources throw `AppException`.
- Repositories/use cases return `Failure`.
- UI maps `Failure` to user messages.
- The pattern is ready for network, storage, and AI errors without structural changes.

---

## ADR-011: Theme System Migrated to lib/app/theme/

**Status:** Confirmed (Phase 1)

**Date:** 2026-07-25

**Decision:** Move the theme system from `lib/app/theme/` to `lib/app/theme/` as part of the architecture reorganization.

**Context:** Phase 1 established a new project structure with clear layer separation. The theme system is application infrastructure and belongs under `lib/app/`.

**Rationale:**
- `lib/app/` contains all application infrastructure — the theme system fits naturally.
- `lib/src/` was a generic namespace with no architectural meaning.
- All existing functionality was preserved; only the file location changed.

**Consequences:**
- Theme files are now at `lib/app/theme/`.
- All imports updated to `package:seima/app/theme/...`.
- No functional changes to the theme system itself.

---

## ADR-012: JSON + shared_preferences for Local Persistence

**Status:** Confirmed (Phase 2)

**Date:** 2026-07-25

**Decision:** Use `shared_preferences` with JSON serialization for local persistence of Mind data.

**Context:** The application needed local persistence for the mind-mapping experience. The data model involves aggregate roots (Mind) containing lists of nodes and connections. The total data volume is small (dozens to hundreds of nodes per mind).

**Rationale:**
- Zero external setup — `shared_preferences` is a standard Flutter package.
- Simple API — no schema migrations, no query language.
- Serialization is straightforward — embed nodes and connections in the Mind JSON.
- Works on all platforms (Android, iOS, Web, Windows, macOS, Linux).
- Easy to replace with a more robust database later (drift, Isar, etc.).
- Sufficient for the prototype and early production phase.

**Consequences:**
- Data is stored as a single JSON array of minds in shared_preferences.
- Not suitable for large-scale data (1000s of nodes with complex queries).
- Future migrations will need to handle data transfer to a more robust database.
- No query capabilities — filtering/search requires loading all minds and filtering in Dart.

---

## ADR-013: Flutter-Native Infinite Canvas (No External Graph Library)

**Status:** Confirmed (Phase 2)

**Date:** 2026-07-25

**Decision:** Build the infinite canvas using Flutter-native widgets (InteractiveViewer, Stack, Positioned, CustomPainter) rather than a third-party graph rendering library.

**Context:** The core experience requires an infinite canvas with nodes and connections. Libraries like GraphView, Titius, or custom graph renderers were considered.

**Rationale:**
- Flutter's built-in widgets (`InteractiveViewer` for pan/zoom, `Stack` + `Positioned` for node layout, `CustomPainter` for connections) provide all needed capabilities.
- Zero additional dependencies — reduces maintenance burden and version conflicts.
- Full control over rendering, interaction, and performance.
- The current requirements (positioned nodes with free-form layout) don't need a graph layout engine.
- `InteractiveViewer` handles pan/zoom with minimal configuration.
- Easy to understand and debug compared to third-party libraries.

**Consequences:**
- Free-form node placement (no auto-layout) — users position nodes manually.
- Future auto-layout features would need custom implementation.
- Performance with large numbers of nodes may require optimization (e.g., viewport culling).
- Connection rendering uses `CustomPainter` with direct line drawing.

---

## ADR-014: Aggregate Root Design (Mind Contains Nodes + Connections)

**Status:** Confirmed (Phase 2)

**Date:** 2026-07-25

**Decision:** Model Mind as an aggregate root containing embedded lists of nodes and connections.

**Context:** The relationship between Mind, Node, and Connection needed to be determined. Options included separate collections (minds, nodes, connections) or embedded documents.

**Rationale:**
- Simpler serialization — one JSON blob per mind.
- Atomic saves — save or load an entire mind in one operation.
- Cubit state management is simpler — one state holds the complete mind.
- Future database migration (e.g., to SQLite) is still possible by decomposing the aggregate.
- Connections reference nodes by ID within the same mind — no cross-mind references.

**Consequences:**
- Loading a mind loads all its nodes and connections into memory.
- Deleting a mind deletes all its nodes and connections.
- All node/connection operations go through the Mind aggregate.

---

## ADR-015: Listener for Canvas Deselection (Not GestureDetector)

**Status:** Confirmed (Phase 2)

**Date:** 2026-07-25

**Decision:** Use `Listener` with `onPointerDown` for canvas deselection instead of `GestureDetector` with `onTap`.

**Context:** The canvas needs to deselect the current node when the user taps on empty space. A `GestureDetector` on the canvas competes with node-level `GestureDetector`s in the gesture arena.

**Rationale:**
- `Listener` fires raw pointer events without participating in the gesture arena.
- Node `GestureDetector.onTap` fires independently (on pointer up) and correctly selects the node.
- The deselection happens on pointer down (before the gesture resolves), and node selection happens on pointer up (after the gesture resolves).
- No gesture arena competition means both deselection and selection work reliably.

**Consequences:**
- Deselection triggers on any pointer down on the canvas, including during drags.
- The order is: pointer down → deselect, pointer up on node → select. So tapping a node briefly deselects then re-selects it (effectively a no-op at the UI level).

---

## ADR-016: Cubit Separation (MindLibraryCubit + SearchCubit)

**Status:** Confirmed (Phase 3)

**Date:** 2026-07-25

**Decision:** Split canvas state (MindCubit) from library state (MindLibraryCubit) and search state (SearchCubit) into separate Cubits.

**Context:** MindCubit was becoming a God Cubit handling both canvas operations and mind management. Additionally, search needed its own state.

**Rationale:**
- Clear separation of concerns — canvas operations, library operations, and search are independent domains.
- MindLibraryCubit handles mind lifecycle (create, rename, delete, duplicate) without canvas state.
- SearchCubit handles local search across all minds without interfering with canvas state.
- Each Cubit can be tested independently.
- No circular dependencies — all Cubits depend only on MindRepository.

**Consequences:**
- Three Cubits in DI: MindCubit, MindLibraryCubit, SearchCubit
- Pages use BlocProvider to create appropriate Cubits
- MindLibraryState does NOT use Equatable (identity-based Mind equality conflicts with value comparison)

---

## ADR-017: In-Memory Undo/Redo Stack

**Status:** Confirmed (Phase 3)

**Date:** 2026-07-25

**Decision:** Implement undo/redo using an in-memory stack of Mind snapshots stored in MindState.

**Context:** The application needed undo/redo for canvas operations (create/edit/move/delete nodes, create/delete connections, rename title). Options included command pattern, state snapshots, and event sourcing.

**Rationale:**
- Snapshot-based undo/redo stores Mind objects directly in undoHistory/redoHistory lists.
- Mind objects are immutable (copyWith creates new instances), so stored references remain valid.
- No deep copy needed — new Mind instances are always created by copyWith when mutations occur.
- Simpler than command pattern for the current complexity level.
- Fast — no serialization overhead during undo/redo.
- 50-item cap prevents unbounded memory growth.

**Consequences:**
- Undo/redo stacks are in-memory only (lost when closing the mind page).
- New mutations after undo clear the redo stack.
- Auto-save runs after undo/redo to persist the restored state.
- SelectedNodeId may point to a deleted node after undo — MindState.updateMind handles this.

---

## ADR-018: Keyboard Shortcuts via CallbackShortcuts

**Status:** Confirmed (Phase 3)

**Date:** 2026-07-25

**Decision:** Use `CallbackShortcuts` + `Focus` for keyboard shortcuts instead of raw KeyboardListener.

**Context:** The canvas page needs keyboard shortcuts for undo (Ctrl+Z), redo (Ctrl+Y), and delete (Delete/Backspace). The initial approach used KeyboardListener with LogicalKeyboardKey but required proper focus management.

**Rationale:**
- `CallbackShortcuts` is the idiomatic Flutter approach for keyboard shortcuts.
- `ShortcutActivator` (SingleActivator) handles modifier keys (Ctrl) cleanly.
- `Focus` widget with `autofocus: true` ensures keyboard focus without user interaction.
- No raw key event parsing needed.
- Separated from the old approach that required manual key event handling.

**Consequences:**
- Keyboard shortcuts only work when the MindPage has focus.
- `FocusNode` is created/disposed with the page.
- Adding new shortcuts is straightforward (add SingleActivator entries).
- No keyboard shortcut customization support yet.

---

## ADR-019: Versioned Storage Format

**Status:** Confirmed (Phase 3)

**Date:** 2026-07-25

**Decision:** Track storage format version with a `seima_storage_version` key in shared_preferences.

**Context:** As the data model evolves (fields added like lastAccessedAt, tags), the storage format changes. A version tracking mechanism enables safe future migrations.

**Rationale:**
- Current format is v1.
- Version is checked (not currently used for migration since v1 is the only format).
- Future versions can handle migration logic in `_ensureVersion()`.
- Missing version defaults to current version (fresh installs).

**Consequences:**
- All load operations check/ensure version.
- Migration logic goes in `_ensureVersion()` when needed.
- Backward-compatible field defaults (nullable, with fallbacks) handle old data.

---

## ADR-020: No Equatable for MindLibraryState

**Status:** Confirmed (Phase 3)

**Date:** 2026-07-25

**Decision:** Do not extend Equatable for MindLibraryState.

**Context:** MindLibraryState contains a List<Mind>. Mind objects use identity-based equality (== compares only id). When a mind's title or content changes, Equatable compares old and new states using Mind's ==, which considers them equal (same id). This prevents state emissions from being detected.

**Rationale:**
- Mind's identity-based equality (correct for domain modeling) conflicts with state comparison needs.
- Without Equatable, MindLibraryState emits on every copyWith call regardless of content equality.
- BlocBuilder rebuilds correctly when state changes.
- MindState continues using Equatable (its props include mind?.title, mind?.nodes which detect changes).

**Consequences:**
- MindLibraryState is a plain (non-Equatable) class.
- BlocBuilder and BlocSelector work correctly without Equatable comparisons.
- Future state classes should be evaluated case-by-case for Equatable vs plain.

---

## ADR-021: No Equatable for MindState (Removed in Phase 4)

**Status:** Confirmed (Phase 4)

**Date:** 2026-07-25

**Decision:** Remove Equatable from MindState, using default identity-based equality instead.

**Context:** MindState originally extended Equatable with `props` including `undoHistory.length` and `redoHistory.length`. This imprecise comparison could miss state changes when undo/redo stack lengths happen to be the same. Additionally, MindState contains mutable-friendly List<Mind> fields where deep value comparison is neither necessary nor performant.

**Rationale:**
- Every `copyWith()` call creates a new instance, so identity-based equality always triggers a rebuild — no emissions are missed.
- The original `props` compared only `undoHistory.length` and `redoHistory.length`, not actual content, offering minimal benefit.
- Removing Equatable eliminates the false precision of comparing only stack lengths.
- Simpler — no need to maintain a `props` list or worry about what fields should trigger equality.

**Consequences:**
- MindState is now a plain Dart class.
- Every `emit()` creates a new state instance (which was already the case).
- No risk of missed state emissions from imprecise equality comparison.

---

## ADR-022: Debounced Auto-Save (300ms Timer)

**Status:** Confirmed (Phase 4)

**Date:** 2026-07-25

**Decision:** Replace fire-and-forget `_autoSave()` with a 300ms debounced timer.

**Context:** The original `_autoSave()` called `save()` directly on every mutation, creating race conditions during rapid operations (like dragging a node, which fires onPanUpdate on every frame). This could queue overlapping save operations, cause unnecessary serialization, and degrade performance.

**Rationale:**
- A `Timer` with 300ms delay cancels the previous timer on each call, ensuring save only fires after mutations settle.
- Eliminates overlapping save operations.
- Reduces serialization frequency during rapid edits (drag, keyboard input).
- Timer is cancelled in `close()` to prevent save attempts after cubit disposal.

**Consequences:**
- Saves are delayed by up to 300ms after the last mutation.
- Users see "saved" indicator slightly later, but performance is improved.
- Manual `save()` is still available for explicit saves (still fires immediately).

---

## ADR-023: Multi-Selection via Set&lt;String&gt; selectedNodeIds

**Status:** Confirmed (Phase 4)

**Date:** 2026-07-25

**Decision:** Replace `selectedNodeId: String?` with `selectedNodeIds: Set<String>` in MindState, supporting single-select and multi-select with a uniform API.

**Context:** The original canvas supported only single-node selection. Phase 4 needed multi-selection for batch operations (move, delete) and improved canvas productivity.

**Rationale:**
- `Set<String>` naturally models a collection of selected node IDs.
- Single-select is simply a set with one element — no special casing needed.
- `Set` operations (contains, add, remove, clear, intersection) map cleanly to UI interactions.
- `toggleNodeSelection()` for Ctrl+click, `selectAll()` for Ctrl+A.
- `clearSelection()` empties the set.
- `updateMind()` filters the set to valid node IDs, handling node deletion gracefully.

**Consequences:**
- Single tap assigns `{nodeId}` (replaces selection).
- Ctrl/Cmd+click toggles node in selection set via `toggleNodeSelection()`.
- Ctrl+A selects all nodes.
- Escape clears selection and cancels connection mode.
- Delete/Backspace deletes all selected nodes.
- Dragging a selected node when multiple are selected moves all selected nodes.
- `selectedNodeIds` is automatically cleaned by `updateMind()` when nodes are deleted.

---

## ADR-024: Local-First, Privacy-First AI Architecture

**Status:** Confirmed (Phase 5)

**Date:** 2026-07-25

**Decision:** All AI processing must run 100% on-device. No Mind data ever leaves the user's device. No external AI APIs, backends, or cloud services are used for Mind data processing.

**Context:** Seima is designed as a local-first, privacy-first knowledge tool. User Mind data — titles, descriptions, nodes, content, tags, connections — is sensitive intellectual property. Sending this data to external AI services would violate user trust and the product's privacy commitment. Additionally, offline functionality is a core requirement.

**Rationale:**
- User data privacy is non-negotiable — Mind data never leaves the device.
- Offline operation — AI features must work without internet connectivity.
- No backend infrastructure — reduces cost, complexity, and attack surface.
- No API keys — reduces configuration burden and security risk.
- Provider-agnostic abstraction — allows future model/runtime changes without affecting the rest of the application.
- Architecture is ready for real on-device model integration (llama.cpp, MLX, etc.) when the runtime is available.

**Consequences:**
- The abstract `AIService` interface is implemented by `LocalAIService` with deterministic/heuristic analysis.
- A real on-device LLM (e.g., via llama.cpp bindings, MLX, or platform-native ML APIs) can replace the heuristic implementation without changing any other layer.
- The heuristic implementation provides useful deterministic analysis (theme extraction, isolated node detection, content overlap) but is NOT real AI — it's a development placeholder.
- No HTTP client dependencies for AI inference are included.
- All AI configuration is empty/no-op (no endpoints, no API keys).
- Documentation explicitly states the mock/local nature of the current AI implementation.

---

## ADR-025: AI as Separate Cubit (AICubit) with Proposal Model

**Status:** Confirmed (Phase 5)

**Date:** 2026-07-25

**Decision:** Maintain AI state management in a separate `AICubit` independent from `MindCubit`. AI-generated modifications are represented as `AIProposal` objects that require explicit user confirmation before being applied through existing MindCubit methods.

**Context:** AI features could have been integrated directly into MindCubit, but that would violate separation of concerns. AI state (loading, analysis text, proposals) is fundamentally different from Mind state (nodes, connections, selection, undo/redo). Additionally, the product requirement is clear: AI must NOT directly mutate the Mind.

**Rationale:**
- `AICubit` manages: panel open/close, analysis loading/success/failure, analysis text, proposals.
- `MindCubit` remains unchanged — it does not know about AI.
- AI proposals (`NewNodeProposal`, `ConnectionProposal`) are sealed types defined in the AI domain.
- Proposals are applied through existing MindCubit methods (`createNode`, `completeConnection`, `updateNodeContent`, `updateNodeTags`).
- Applied proposals automatically enter the undo/redo stack because MindCubit pushes undo on all mutations.
- The UI layer connects AICubit proposals to MindCubit mutations via callbacks.
- AI can be tested independently from Mind operations.

**Consequences:**
- AICubit is registered as a factory in DI, created per MindPage visit.
- MindPage provides both BlocProvider<MindCubit> and BlocProvider<AICubit>.
- AI analysis panel is rendered as an overlay on the Mind workspace (Positioned widget in Stack).
- AI proposals require user tap on "Add to Mind" or "Connect" button to apply.
- Applied operations are fully undoable/redoable via existing undo/redo.

---

## ADR-026: Deterministic Heuristic Analysis as Development AI

**Status:** Confirmed (Phase 5)

**Date:** 2026-07-25

**Decision:** Implement the local AI service as a deterministic heuristic analyzer that extracts themes, detects isolated nodes, finds content overlaps, and generates suggestions based on simple algorithms. This is NOT real AI — it is a development/testing placeholder that validates the architecture.

**Context:** A real on-device LLM (e.g., via llama.cpp or MLX) cannot yet be integrated into this Flutter project within the current milestone. However, the AI architecture, state management, context extraction, proposal model, and UI all need to be built and tested. A deterministic implementation serves this purpose.

**Rationale:**
- The heuristic implementation runs entirely on-device with no model download or runtime dependencies.
- It provides genuinely useful analysis: word frequency themes, isolated node detection, content overlap for connection suggestions.
- It validates the full AI data flow: Mind → MindContextBuilder → AIService → AIResponse → AICubit → UI → proposals → apply → undo.
- It can be replaced by a real model implementation without changing any other layer.
- The `AIService` interface makes the provider fully replaceable.
- All 148 tests pass with the heuristic implementation.

**Consequences:**
- The current `LocalAIService` does NOT use an LLM — it uses word frequency, set operations, and simple heuristics.
- Analysis is deterministic and repeatable (same mind always produces the same output).
- Analysis is limited to pattern matching and cannot understand semantics.
- A real on-device LLM integration (llama.cpp, MLX, etc.) is the next step for production AI.
- Documentation clearly states this is a development implementation, not production AI.

---

## ADR-027: Process-Based On-Device LLM for Desktop Platforms

**Status:** Confirmed (Phase 6)

**Date:** 2026-07-25

**Decision:** Implement the real on-device LLM runtime using `dart:io` Process to spawn a llama.cpp CLI subprocess on desktop platforms (Windows, macOS, Linux). Communication via stdin/stdout with streaming token output.

**Context:** Phase 6 requires a real on-device LLM to replace the heuristic LocalAIService. The target platforms are desktop (Windows, macOS, Linux) where `dart:io` Process is available. Mobile (Android, iOS) and Web do not support subprocess spawning, so they continue using the heuristic fallback. The selected runtime is llama.cpp, the most mature and widely-used local LLM inference engine.

**Rationale:**
- Process-based approach is the simplest reliable path to real LLM inference — no FFI complexity, no CMake builds, no NDK toolchains.
- `dart:io` Process is available on all desktop platforms natively.
- llama.cpp CLI is well-documented, cross-platform (Windows/macOS/Linux), and supports GGUF models.
- Streaming inference is naturally supported via stdout line-by-line reading.
- The separate process ensures UI thread is never blocked by inference.
- Process lifecycle is manageable (spawn, monitor, kill on dispose).
- The architecture is replaceable — a future `FFILLMRuntime` can replace `ProcessLLMRuntime` without changing `LLMAIService`.
- No external Dart packages needed — `dart:io` is built into the SDK.
- Model and executable are user-managed (downloaded, not bundled), keeping app size small.

**Consequences:**
- Desktop platforms (Windows, macOS, Linux) can run real LLM inference when the user provides a llama.cpp executable and a GGUF model.
- Mobile (Android, iOS) and Web fall back to heuristic LocalAIService.
- `ProcessLLMRuntime` implements the abstract `LocalLLMRuntime` interface.
- `LLMAIService` checks runtime availability and falls back automatically.
- Process management requires careful lifecycle handling (dispose, error recovery).
- Test doubles (`MockLLMRuntime`) enable testability without a real model.

---

## ADR-028: Qwen2.5-1.5B-Instruct as Default On-Device Model

**Status:** Confirmed (Phase 6)

**Date:** 2026-07-25

**Decision:** Recommend Qwen2.5-1.5B-Instruct GGUF in Q4_K_M quantization as the default on-device model for Seima.

**Context:** An on-device LLM needs to be small enough to run on consumer CPUs with reasonable performance, yet capable enough to provide meaningful mind map analysis (summarization, theme extraction, expansion suggestions, structured JSON output).

**Rationale:**
- **Model size:** ~987MB (Q4_K_M quantization) — fits within reasonable download size.
- **CPU performance:** 1.5B parameters runs at 15-30 tokens/second on modern CPUs without GPU.
- **RAM usage:** ~2-3GB during inference — acceptable for desktop systems.
- **Context length:** 32K tokens (we use 4K) — more than sufficient for Seima's context.
- **Instruction following:** Strong structured output capability — critical for JSON proposal parsing.
- **License:** Apache 2.0 — permissive for commercial use.
- **GGUF format:** Supported directly by llama.cpp.
- **Ecosystem:** Widely available on HuggingFace, multiple quantization levels.
- **Quality:** Outperforms TinyLlama (1.1B) while being significantly smaller than Phi-3-mini (3.8B).

**Consequences:**
- Default download URL points to HuggingFace GGUF repository.
- `ModelManager.defaultModelUrl` and `defaultModelFileName` use Qwen2.5-1.5B Q4_K_M.
- Users can substitute any GGUF model by placing it in the models directory.
- The `ModelManager.getModelPath()` scans for any `.gguf` file, supporting arbitrary models.
- Documentation recommends Qwen2.5-1.5B as the starting model.
- Future model upgrades (e.g., Qwen3) require only URL changes.

---

## ADR-029: Optional Model Download Strategy

**Status:** Confirmed (Phase 6)

**Date:** 2026-07-25

**Decision:** The on-device LLM model is NOT bundled with the application. Users optionally download it through the AI panel UI. The app remains fully functional without the model, using the heuristic fallback.

**Context:** Bundling a ~1GB GGUF model would increase app size by over 10x, making initial download impractical. Instead, the model should be an optional download initiated by the user.

**Rationale:**
- App size without model: ~10MB. With model: ~1GB. Bundling is not acceptable.
- Model download via HuggingFace: standardized, reliable, free.
- `dart:io` HttpClient handles download with progress tracking.
- The AI panel shows a "Download local AI model (~1GB)" button when the model is not present.
- During download, UI shows LinearProgressIndicator with percentage.
- Model is saved to `~/.seima/models/` (or `%USERPROFILE%\.seima\models\` on Windows).
- Model download is a one-time operation — subsequent app launches detect the existing model.
- Download requires network access (documented, acceptable for model download only).
- Mind data is NEVER sent over the network — only the public model file is downloaded.
- The download is cancellable by the user (app lifecycle handles interruption).
- Model location is configurable via AIConfig.modelPath.

**Consequences:**
- First-time users see "Using offline analysis" in the AI panel status bar.
- The "Download local AI model" button initiates the download process.
- The model file persists across app restarts (auto-detected on panel open).
- Users can delete the model via ModelManager.deleteModel().
- The download progress is exposed in AIState.downloadProgress.
- Model download uses `dart:io` HttpClient (no external HTTP package).
- The download URL is configurable in ModelManager.defaultModelUrl.

---

## ADR-030: Phase 7 Hardening — Drag Undo Grouping, Import Validation, fromJson Safety

**Status:** Confirmed (Phase 7)

**Date:** 2026-07-25

**Decision:** Implement drag undo grouping (single undo entry per drag), connection import validation, fromJson type safety, and production hardening across the entire codebase.

**Context:** Phase 7 combined canvas productivity features (node types, curved connections, connection selection, import/export) with a comprehensive production-readiness hardening audit. Multiple issues were identified and fixed during the audit.

**Rationale:**
- **Drag undo grouping:** Without it, dragging a node floods the undo stack (50+ entries per drag), making undo unusable. `beginNodeDrag()` captures the pre-drag mind; `endNodeDrag()` pushes a single undo entry.
- **fromJson safety:** Unknown/missing `NodeType` in JSON (from future versions or corrupted data) caused crashes. Fallback to `NodeType.text` ensures resilience.
- **Import validation:** Connections referencing non-existent node IDs would corrupt the mind silently. `_validateConnections()` rejects bad imports with a clear error.
- **Bidirectional duplicate check:** The original duplicate check only matched exact source→target direction. `A→B` and `B→A` are semantically duplicate connections.
- **Model download integrity:** Partial downloads from interruption would leave corrupt `.gguf` files that the app treated as valid. Now downloads to `.part` temp file and verifies size before rename.

**Consequences:**
- `MindCubit` now has `beginNodeDrag()`/`endNodeDrag()` lifecycle methods wired through `CanvasNodeWidget` → `MindCanvas` → `MindPage`.
- `MindNode.fromJson` safely handles unknown node types (future-proof).
- `MindConnection.fromJson` rejects references to non-existent nodes during import.
- `completeConnection` checks both directions for duplicates.
- `ModelManager.downloadModel` writes to `.part` file, verifies `contentLength`, renames atomically.
- 219 tests pass, 0 analyzer issues.

---

## ADR-031: Content and Tag Length Limits on AI Proposals

**Status:** Confirmed (Phase 7)

**Date:** 2026-07-25

**Decision:** Enforce maximum character limits on AI-generated node content (2000 chars), individual tags (50 chars), and total tags per node (10 tags) in `LLMResponseParser`.

**Context:** The LLM could theoretically generate arbitrarily long content strings or an unbounded number of tags. This could cause memory pressure, UI rendering issues (contentHeight calculation), serialization bloat, and persistence problems.

**Rationale:**
- 2000 characters provides ample room for meaningful content while preventing abuse.
- 50 characters per tag is consistent with common tag length limits in knowledge tools.
- 10 tags per node prevents tag explosion.
- Overly long content is silently rejected (proposal is dropped) rather than truncated, which could produce misleading results.

**Consequences:**
- `LLMResponseParser.maxContentLength = 2000`, `maxTagLength = 50`, `maxTags = 10`.
- Proposals exceeding limits are discarded (not applied).
- `_parseTags` applies `.take(maxTags)` and `.where((t) => t.length <= maxTagLength)`.
- Existing tests for proposal parsing remain passing.

---

## ADR-032: Partial Model Download Protection

**Status:** Confirmed (Phase 7)

**Date:** 2026-07-25

**Decision:** Protect against partial/corrupt model downloads by writing to a `.part` temporary file, verifying total received bytes match `Content-Length`, and atomically renaming to `.gguf` only on success.

**Context:** The `ModelManager.downloadModel()` method previously wrote directly to the final `.gguf` path. If the download was interrupted (network error, app crash, user cancel), a partial file remained on disk. On next launch, `isModelDownloaded()` returned true (any `.gguf` exists), and `ProcessLLMRuntime` would attempt to load it — likely crashing or hanging llama.cpp.

**Rationale:**
- Temp file (`filename.gguf.part`) prevents partial files from being mistaken for valid models.
- Content-Length verification detects truncated downloads server-side.
- Atomic rename (`File.rename()`) ensures the target path only contains a complete file.
- If size verification fails, the temp file is deleted and an `HttpException` is thrown.
- No hash verification (SHA256) needed at current scale; Content-Length is sufficient for network interruption detection.

**Consequences:**
- `downloadModel()` writes to `<path>.part`, verifies size, then renames to `<path>`.
- Failure at any point before rename leaves no partial `.gguf` file.
- `HttpException` with descriptive message is thrown on size mismatch.
- Existing tests (model_manager_test.dart) remain passing since they test with local files.

---

## ADR-033: Canonical Seima Knowledge Interchange Format

**Status:** Accepted

**Date:** 2026-07-26

**Decision:** Establish `SeimaKnowledgePackage` as the canonical interchange format for all sharing, export, and import operations. Use a JSON-based schema with explicit `schema` and `seima_knowledge_version` fields.

**Context:** Seima previously had only an internal JSON serialization format (`Mind.toJson()`) that was tightly coupled to the app's domain model. There was no:
- Schema identification mechanism
- Versioned interchange format
- Forward/backward compatibility design
- Separation between storage and interchange concerns
- Support for external knowledge ingestion

**Rationale:**
- A separate canonical format allows the internal domain model to evolve independently from the interchange format.
- Explicit `schema` identifier prevents confusion with other JSON formats.
- Version field enables future format evolution without breaking existing data.
- Forward-compatible design (unknown fields preserved) supports seamless upgrades.
- The `PackageMind`/`PackageNode`/`PackageConnection` abstractions are simpler than the full domain model, making the format easier to document and implement in other languages.
- Human-readable JSON is debuggable and testable without special tools.
- The `.seima` extension and `application/vnd.seima.knowledge` MIME type give the format identity.

**Consequences:**
- All export/import operations now use `SeimaKnowledgePackage` as the intermediate representation.
- `ExportService.convertMind()` transforms `Mind` → `SeimaKnowledgePackage`.
- `ImportService` parses `SeimaKnowledgePackage` → `Mind`.
- Old export format (version 1 `{'version': 1, 'mind': ...}`) is still detected by `InputDetector` and converted.
- New code depends on `package:path_provider`, `package:share_plus`, `package:file_picker` for platform I/O.
- Android share intent receiving requires MethodChannel (`com.seima/sharing`) and intent filters.

---

## ADR-034: Import Pipeline with Preview-First Architecture

**Status:** Accepted

**Date:** 2026-07-26

**Decision:** All import operations must show a preview before any data mutation. The `ImportService` produces an `ImportPreview` that is presented to the user before `executeAsNewMind()` or `executeMergeIntoMind()` is called.

**Context:** Previously, `MindCubit.importMind()` directly imported a mind without showing the user what was being imported. This could:
- Overwrite existing minds without warning
- Import corrupted or unexpected data silently
- Confuse users about what content was added

**Rationale:**
- Preview-first is safer than import-first. Users can cancel before any data is written.
- The preview communicates: source type, title, node count, connection count, warnings, and errors.
- Users can choose: create new mind, merge into existing, or cancel.
- This pattern is consistent with Seima's principle that AI proposals must be confirmed.
- The undo stack captures the pre-import state, making merges reversible.

**Consequences:**
- `ImportCubit` manages a 4-step state machine: `initial → loading → preview → executing → success/failure`.
- All import operations flow through preview before execution.
- Integration with `ImportPreviewPage` provides the UI for preview display and action selection.
- `ImportDestinationPicker` dialog lets users choose which mind to merge into.<｜end▁of▁thinking｜>


