# Architecture

> **Status:** Phase 7 Complete — Canvas Productivity + Production Readiness Hardening.

---

## Architecture Principles

1. **Clarity over cleverness** — Code should be easy to read and understand.
2. **Separation of concerns** — Each layer has a clear responsibility.
3. **Dependency direction** — Dependencies point inward (UI → Logic → Data).
4. **Testability** — Architecture should make testing straightforward.
5. **Consistency** — Follow established patterns for all new code.
6. **No premature abstraction** — Abstract when a pattern proves itself, not before.
7. **Feature-first organization** — Features are self-contained modules under `lib/features/`.

---

## Architecture Layers

```
Presentation (Widgets, Pages, Cubits, CustomPainters)
    ↓ (depends on)
Domain (Entities: Mind, MindNode, MindConnection)
    ↓ (depends on)
Data (Repositories: MindRepository)
    ↓ (depends on)
Application (App shell, DI, Router, Config)
    ↓ (depends on)
Core (Shared errors, utilities, constants)
```

- **Presentation** — Widgets, pages, Cubits, and custom painters for each feature.
- **Domain** — Business entities and value objects. Independent of Flutter.
- **Data** — Repository implementations for persistence.
- **Application** — App shell, dependency injection, routing, configuration, theme system.
- **Core** — Shared foundational types (errors, constants, utilities).

---

## Current Project Structure

```
lib/
├── main.dart                          # Entry point, bootstraps DI, renders MindoraApp
├── app/                               # Application infrastructure
│   ├── app.dart                       # MindoraApp widget (MaterialApp.router)
│   ├── di.dart                        # GetIt registration (sl instance)
│   ├── config/
│   │   └── app_config.dart            # App constants (name, version, phase)
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   └── theme/                         # Centralized design system
│       ├── app_theme.dart             # AppTheme factory, ThemeController, MindoraTheme
│       ├── colors.dart                # Color tokens (seed, semantic)
│       ├── spacing.dart               # Spacing, radius, elevation tokens
│       └── typography.dart            # TextTheme (light + dark)
├── core/                              # Shared foundations
│   └── errors/
│       ├── app_exception.dart         # Base AppException class
│       └── failures.dart              # Failure representation with factories
└── features/                          # Feature modules
    ├── home/                          # Home screen (placeholder)
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── home_cubit.dart
    │       │   └── home_state.dart
    │       └── pages/
    │           └── home_page.dart
    ├── ai/                            # AI intelligence feature
    │   ├── data/
    │   │   ├── ai_service.dart         # Abstract AIService interface
    │   │   ├── llm_ai_service.dart     # LLM-based AIService with heuristic fallback
    │   │   ├── llm_runtime.dart        # Abstract LocalLLMRuntime interface + ModelStatus
    │   │   ├── llm_response_parser.dart # Parse LLM output (text + JSON proposals)
    │   │   ├── local_ai_service.dart   # Deterministic heuristic implementation
    │   │   ├── mind_context_builder.dart # Mind → AIContext extraction (with truncation)
    │   │   ├── model_info.dart         # ModelInfo data class
    │   │   ├── model_manager.dart      # Model detect/download/delete management
    │   │   └── process_llm_runtime.dart # dart:io Process-based llama.cpp runtime
    │   ├── domain/
    │   │   ├── ai_config.dart          # AI configuration (model path, temperature, etc.)
    │   │   ├── ai_context.dart         # Structured Mind context for AI
    │   │   ├── ai_failure.dart         # AI-specific failure types (incl. model)
    │   │   ├── ai_proposal.dart        # NewNodeProposal, ConnectionProposal
    │   │   └── ai_response.dart        # Analysis text + proposals
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── ai_cubit.dart       # AICubit (AI + model state management)
    │       │   └── ai_state.dart       # AIStatus, ModelState, download progress
    │       └── widgets/
    │           ├── ai_panel.dart       # AI analysis panel (model status, download, streaming)
    │           └── proposal_card.dart  # Proposal review with apply
    └── mind/                          # Mind workspace feature
        ├── data/
        │   ├── id_provider.dart       # Simple ID generation
        │   └── mind_repository.dart   # shared_preferences persistence
        ├── domain/
        │   ├── mind.dart              # Mind aggregate root
        │   ├── mind_node.dart         # Node entity
        │   ├── mind_connection.dart   # Connection entity
        │   └── node_type.dart         # NodeType enum
        └── presentation/
            ├── cubit/
            │   ├── mind_cubit.dart        # MindCubit (canvas state + undo/redo)
            │   ├── mind_state.dart        # MindState (immutable, undo/redo history)
            │   ├── mind_library_cubit.dart # MindLibraryCubit (library operations)
            │   ├── mind_library_state.dart # MindLibraryState
            │   ├── search_cubit.dart      # SearchCubit (search across minds)
            │   └── search_state.dart      # SearchState + SearchResult
            ├── pages/
            │   ├── mind_library_page.dart # Library list with create/rename/delete/duplicate
            │   ├── mind_page.dart         # Main workspace page with keyboard shortcuts
            │   └── search_page.dart       # Search page with results
            └── widgets/
                ├── mind_canvas.dart       # Stack-based canvas with positioned nodes
                ├── canvas_node.dart       # Individual node widget with selection/actions
                ├── connection_painter.dart # CustomPainter for connection lines
                └── node_editor.dart       # Dialog for editing node content
```

### Layer Responsibilities

| Directory | Responsibility |
|---|---|
| `lib/main.dart` | Entry point, DI bootstrap, app launch |
| `lib/app/` | Application infrastructure (shell, config, router, theme, DI) |
| `lib/app/startup/` | Startup screen with Mindora icon animation |
| `lib/app/widgets/` | App-wide reusable widgets (MindoraLoadingView) |
| `lib/core/` | Shared foundational types used across features |
| `lib/features/` | Feature modules — each feature owns its presentation, domain, and data layers |
| `test/` | Tests mirroring `lib/` structure |

---

## AI Architecture

**Approach:** Local-first, privacy-first. All AI processing runs 100% on-device. No Mind data leaves the user's device.

**Status:** Phase 7 Architecture — Real on-device LLM via llama.cpp subprocess (desktop). Heuristic fallback (mobile/web). Hardened for production.

### Architecture Layers

```
Presentation (AIPanel, ProposalCard)
    ↓
AI Cubit (AICubit + AIState)
    ↓
AI Service Interface (AIService - abstract)
    ├── LLMAIService (REAL LLM — desktop)
    │       └── LocalLLMRuntime (abstract)
    │               └── ProcessLLMRuntime (llama.cpp subprocess)
    └── LocalAIService (HEURISTIC FALLBACK — mobile/web)
    ↓
Mind Context Builder (AIContext from Mind)
    ↓
Mind Domain Model
```

### LLM Runtime Architecture

```
LLMAIService
  │  Checks runtime status
  │  Builds prompt via MindContextBuilder.toPrompt()
  │  Streams tokens via runtime.generate() or analyzeStreaming()
  │  Parses output via LLMResponseParser
  │  Falls back to heuristic if LLM unavailable
  ▼
LocalLLMRuntime (abstract interface)
  │  status → ModelStatus enum
  │  initialize(modelPath) → void
  │  generate(prompt) → Stream<String>
  │  analyzeStreaming(prompt) → Stream<String>
  │  dispose() → void
  ▼
ProcessLLMRuntime (concrete implementation)
  │  Spawns llama-cli as subprocess
  │  Writes prompt, reads stdout tokens
  │  Manages process lifecycle (guards against concurrent generate)
  ▼
llama.cpp CLI (external binary)
  │  Loads GGUF model
  │  Runs inference
  ▼
GGUF Model File (user-downloaded)
```

### Model Management

```
ModelManager
  ├── isModelDownloaded() → bool
  ├── getModelPath() → String?
  ├── downloadModel(onProgress) → String (temp file + size verification + rename)
  ├── deleteModel() → void
  ├── getModelSize() → int
  └── Default: Qwen2.5-1.5B-Instruct-Q4_K_M (~987MB)
```

### LLM Output Parsing

```
LLM Output (raw text)
  → LLMResponseParser
      → _extractAnalysisText() — text before JSON block
      → _extractProposals() — parse JSON block
          → NewNodeProposal (type: "new_node", content, tags, reason) — max 2000 chars, max 10 tags @ 50 chars each
          → ConnectionProposal (type: "connection", source_id, target_id, reason)
          → Validated: no empty content, no self-connections, no missing fields, content/tag length limits
  → AIResponse (analysisText + validated proposals)
```

### Platform Support

| Platform | LLM Support | Runtime |
|---|---|---|
| Windows | ✅ Full | ProcessLLMRuntime (llama-cli.exe) |
| macOS | ✅ Full | ProcessLLMRuntime (llama-cli) |
| Linux | ✅ Full | ProcessLLMRuntime (llama-cli) |
| Android | ❌ Fallback | LocalAIService (heuristic) |
| iOS | ❌ Fallback | LocalAIService (heuristic) |
| Web | ❌ Fallback | LocalAIService (heuristic) |

### Data Flow (Privacy-Safe — Phase 7)

```
Mind
  → MindContextBuilder extracts structured AIContext
  → AIContext converted to prompt (toPrompt)
  → ProcessLLMRuntime spawns llama.cpp subprocess locally
  → Model runs inference ON-DEVICE — no network
  → LLM output parsed into analysis text + proposals
  → User reviews in AIPanel
  → User taps Apply → MindCubit methods called
  → Operations enter undo/redo stack
  → Auto-save persists
  → NO data leaves the device at any point
  → Model download is the only network operation (public model only)
```

### Key Design Decisions

1. **AIService is abstract** — The interface can be implemented by any AI provider (heuristic, llama.cpp, MLX, Core ML, etc.) without changing the rest of the application.
2. **AICubit is separate from MindCubit** — AI state (loading, analysis, proposals, model status) lives independently from mind state (nodes, connections, undo/redo).
3. **AI proposals require user confirmation** — The AI cannot directly mutate the Mind. All AI-generated changes go through a review-and-apply flow.
4. **Applied changes use existing MindCubit** — Proposals are converted to standard MindCubit method calls, which means they automatically get undo/redo support.
5. **LLMAIService wraps runtime + fallback** — It checks runtime availability and falls back to heuristic when LLM is not available, ensuring the app never breaks.
6. **Process-based over FFI** — The Process approach avoids FFI complexity (no CMake, no NDK, no cross-compilation) while still providing real LLM inference. A future `FFILLMRuntime` can replace `ProcessLLMRuntime` for mobile.
7. **Optional model download** — The model is NOT bundled. Users download it on-demand via the AI panel UI. The app is fully functional without it.
8. **Drag undo grouping** — `beginNodeDrag()`/`endNodeDrag()` isolate drag mutations into a single undo entry (Phase 7 hardening).
9. **Connection validation** — Import validates source/target node references; opposite-direction duplicates rejected (Phase 7 hardening).
10. **Content length limits** — AI proposals capped at 2000 chars content, 50 chars per tag, max 10 tags (Phase 7 hardening).
11. **Partial download protection** — Model downloads use temp file + size verification before rename (Phase 7 hardening).

### Current AI Capabilities (Phase 7)

- **LLM-based analysis** — Real LLM inference via llama.cpp (desktop only)
- **Theme extraction** — Genuine semantic theme identification (not word frequency)
- **Summarization** — Meaningful mind map summary
- **Expansion suggestions** — Context-aware node suggestions
- **Connection suggestions** — Semantic relationship detection
- **Questions to explore** — Generated questions based on map content
- **Structured JSON output** — Parseable proposal extraction
- **Token streaming** — Progressive output display during generation
- **Heuristic fallback** — Same capabilities as Phase 5 when LLM unavailable
- **Model download integrity** — Temp file, size verification, atomic rename
- **Safe LLM runtime** — Concurrent generate() guarded, process lifecycle managed

## State Management

**Approach:** BLoC/Cubit via `flutter_bloc` 9.x.

| State Domain | Implementation | Status |
|---|---|---|
| Theme mode | `ValueNotifier<ThemeMode>` via `ThemeController` | **Implemented** (Phase 0) |
| Home screen | `HomeCubit` | **Implemented** (Phase 1) |
| Mind workspace | `MindCubit` | **Implemented** (Phase 2) |
| Mind library | `MindLibraryCubit` | **Implemented** (Phase 3) |
| Search | `SearchCubit` | **Implemented** (Phase 3) |
| AI interactions | `AICubit` + `AIService` (LLMAIService + LocalAIService) | **Implemented** (Phase 5/6 — heuristic + optional real LLM) |

### MindCubit

The `MindCubit` manages all state for the mind workspace:

- **Loading**: Loads specific mind or most recent mind on init
- **Nodes**: Create, update content, move, delete, change node type
- **Node Tags**: Add/remove tags on nodes
- **Connections**: Create (with connect mode), delete, select (single connection)
- **Connection selection**: `selectedConnectionId` for highlight/delete
- **Selection**: Single-select, multi-select (toggle), select all, clear selection
- **Multi-Node Operations**: Move selected nodes, delete selected nodes
- **Drag undo grouping**: `beginNodeDrag()`/`endNodeDrag()` — moves during drag don't flood undo; single undo entry on drag end
- **Saving**: Debounced auto-save (300ms) on mutations, explicit save action; `_saveInProgress` guard prevents concurrent saves
- **Undo/Redo**: In-memory history stack (50 items max)
- **Import/Export**: JSON export of full mind; import with connection validation (rejects references to non-existent nodes)
- **Error**: Failure state with retry

### MindLibraryCubit

The `MindLibraryCubit` manages the mind library:

- **Loading**: Load all minds sorted by lastAccessedAt
- **Create**: Create new mind with default title
- **Rename**: Update mind title
- **Delete**: Remove mind with confirmation
- **Duplicate**: Deep copy mind with new IDs

### SearchCubit

The `SearchCubit` manages search:

- **Search**: Case-insensitive across mind titles, node content, and node tags
- **Results**: Mind-level results (title match) and node-level results (content or tag match)
- **Tag Matching**: Results include matching tags for display
- **Clear**: Reset search state

### Cubit Conventions

- Cubits are created per-feature and provided via `BlocProvider` at the page level.
- Cubits are registered in DI with `registerFactory` so each page visit creates a fresh instance.
- State classes are immutable. Neither MindState nor MindLibraryState use Equatable (identity-based equality is preferred since every `copyWith` creates a new instance).
- Use `copyWith` for state transitions.
- Use `Timer`-based debouncing for auto-save to avoid race conditions.

---

## Routing

**Approach:** `go_router` 14.x with `MaterialApp.router`.

**Status:** Implemented

| Route | Path | Widget |
|---|---|---|
| Mind Library | `/` | `MindLibraryPage` |
| Mind Workspace | `/mind/:id` | `MindPage` |
| Search | `/search` | `SearchPage` |
| Not Found | (any unmatched path) | Inline fallback page |

---

## Dependency Injection

**Approach:** `get_it` 8.x with a central `sl` instance.

**Status:** Implemented

### Registrations

| Service | Lifetime | Registration |
|---|---|---|
| `ThemeController` | Singleton | `registerLazySingleton` |
| `GoRouter` | Singleton | `registerLazySingleton` |
| `MindRepository` | Singleton | `registerLazySingleton` |
| `MindCubit` | Factory (per-use) | `registerFactory` |
| `MindLibraryCubit` | Factory (per-use) | `registerFactory` |
| `SearchCubit` | Factory (per-use) | `registerFactory` |
| `LocalLLMRuntime` | Singleton | `registerLazySingleton` (ProcessLLMRuntime) |
| `ModelManager` | Singleton | `registerLazySingleton` |
| `AIService` | Singleton | `registerLazySingleton` (LLMAIService → ProcessLLMRuntime) |
| `AICubit` | Factory (per-use) | `registerFactory` |
| `HomeCubit` | Factory (per-use) | `registerFactory` |

---

## Domain Models

### Mind (Aggregate Root)

```dart
class Mind {
  final String id;
  final String title;
  final String? description;
  final List<MindNode> nodes;
  final List<MindConnection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastAccessedAt;
}
```

### MindNode

```dart
class MindNode {
  final String id;
  final String mindId;
  final NodeType type;       // text, task, question, idea
  final String content;
  final List<String> tags;
  final double x;            // Canvas position
  final double y;
  final double width;
  final double height;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### MindConnection

```dart
class MindConnection {
  final String id;
  final String mindId;
  final String sourceNodeId;
  final String targetNodeId;
  final DateTime createdAt;
}
```

---

## Persistence

**Approach:** `shared_preferences` with JSON serialization.

**Status:** Implemented (v1 storage format)

The `MindRepository` stores all minds as a single JSON array under the `minds` key. Each mind's nodes and connections are embedded in the JSON. Storage format is versioned (`mindora_storage_version` key) for future migration.

Operations:
- `loadAll()` — Load all minds
- `load(id)` — Load specific mind (updates lastAccessedAt)
- `save(mind)` — Create or update a mind
- `delete(id)` — Delete a mind
- `duplicate(id)` — Deep-copy a mind with new IDs for all entities

The repository wraps errors in `AppException`.

---

## Canvas Architecture

The infinite canvas is built using Flutter-native widgets:

1. **InteractiveViewer** — Provides pan and zoom with `boundaryMargin: EdgeInsets.all(double.infinity)` for unbounded scrolling
2. **Stack + Positioned** — Nodes are positioned widgets within a large virtual SizedBox (5000×5000)
3. **CustomPainter (ConnectionPainter)** — Draws connection lines and arrowheads between node centers
4. **GestureDetector (per node)** — Handles tap (select), double-tap (edit), and pan (move)
5. **Listener (page level)** — Raw pointer listener for canvas deselection

### User Interactions

| Action | Implementation |
|---|---|
| Pan canvas | InteractiveViewer (drag empty space) |
| Zoom canvas | InteractiveViewer (pinch/ctrl+scroll) |
| Select node | Tap on node (replaces selection) |
| Multi-select toggle | Ctrl/Cmd+click on node |
| Select all nodes | Ctrl+A |
| Deselect | Tap on empty canvas, or Escape |
| Edit node | Double-tap on node, or select → tap edit icon |
| Move node (single) | Drag node (with drag undo grouping) |
| Move multiple nodes | Drag any selected node when >1 selected (drag undo grouping) |
| Delete node(s) | Select → tap delete icon, or press Delete/Backspace |
| Create node | Tap FAB |
| Change node type | Node editor dialog (toggle between text/task/question/idea) |
| Create connection | Select node → tap link icon → tap target node |
| Cancel connection | Tap cancel FAB, or Escape |
| Select connection | Tap on connection line (highlights in accent color) |
| Delete connection | Select connection → press Delete, or editor action |
| Undo | Ctrl+Z or undo button in app bar |
| Redo | Ctrl+Y or redo button in app bar |
| Edit tags | Double-tap node → tag editor in dialog |
| Import mind | Library page → import JSON file |
| Export mind | Workspace toolbar → export as JSON |
| Navigate back | Back arrow in app bar → library |

---

## Data Flow

```
User Interaction
    → GestureDetector/Shortcut callback
    → Cubit method (e.g., createNode, undo)
    → State update (pushUndo, emit new state)
    → BlocBuilder rebuilds UI
    → Auto-save (MindRepository.save)
    → shared_preferences update
```

---

## Error Handling

| Layer | Error Type | Direction |
|---|---|---|
| Data sources | `AppException` | Thrown |
| Repositories | `AppException` | Thrown |
| Cubit | `Failure` | State field |
| Presentation | `Failure.message` → User display | BlocBuilder |

---

## Testing Architecture

**Status:** 219 tests across all layers.

### Test Structure

```
test/
├── core/
│   └── errors/
│       ├── app_exception_test.dart
│       └── failures_test.dart
├── features/
│   ├── ai/
│   │   ├── data/
│   │   │   ├── llm_ai_service_test.dart      # LLMAIService + fallback
│   │   │   ├── llm_response_parser_test.dart  # JSON parsing, validation
│   │   │   ├── local_ai_service_test.dart
│   │   │   ├── mind_context_builder_test.dart
│   │   │   ├── model_manager_test.dart        # Model detect, size, delete
│   │   │   └── process_llm_runtime_test.dart  # Lifecycle, error states
│   │   ├── domain/
│   │   │   ├── ai_context_test.dart
│   │   │   └── ai_proposal_test.dart
│   │   └── presentation/
│   │       └── cubit/
│   │           └── ai_cubit_test.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── cubit/home_cubit_test.dart
│   │       └── pages/home_page_test.dart
│   └── mind/
│       ├── data/mind_repository_test.dart
│       ├── domain/
│       │   ├── mind_test.dart
│       │   ├── mind_node_test.dart
│       │   ├── mind_connection_test.dart
│       │   └── node_type_test.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── mind_cubit_test.dart
│           │   ├── mind_state_test.dart
│           │   ├── mind_library_cubit_test.dart
│           │   └── search_cubit_test.dart
│           └── widgets/
│               └── mind_canvas_test.dart
```

### Test Coverage Areas

- Domain model creation, equality, serialization round-trip
- Cubit operations (create, read, update, delete nodes and connections)
- Cubit undo/redo (push, restore, clear on new mutation)
- Cubit error states and edge cases
- Repository save/load/update/delete/duplicate
- Repository persistence across reload
- Widget rendering (nodes on canvas)
- State transitions and selection management
- MindLibraryCubit (load, create, rename, delete, duplicate, sort, error)
- SearchCubit (search, case-insensitive, tag search, cross-mind, clear)
- MindState (undo/redo history, cap, canUndo/canRedo)
- Multi-selection (toggleNodeSelection, selectAll, clearSelection)
- Multi-node operations (deleteSelectedNodes, moveSelectedNodes with undo/redo)
- Tag operations (updateNodeTags with undo)
- Empty canvas state
- AI domain model creation (AIContext, AIProposal types, AIResponse)
- AI context extraction (Mind → AIContext, deterministic, empty mind)
- Local AI service (analysis for non-empty, empty, isolated nodes, themes, proposals)
- AICubit (open/close panel, analyze, success, failure, retry, clear, model states)
- LLM AI service (LLM analysis, heuristic fallback for all non-ready states)
- LLM response parser (JSON parsing, proposal validation, malformed input)
- Model manager (detect, size, delete, default config)
- Process LLM runtime (lifecycle, init with non-existent model, error states)
- Streaming analysis (token collection, fallback on unavailable runtime)
- Provider-agnostic AI service interface

---

## Naming Conventions

| Category | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `app_theme.dart` |
| Classes | `PascalCase` | `AppTheme`, `MindCubit` |
| Functions/Methods | `camelCase` | `light()`, `createNode()` |
| Variables | `camelCase` | `controller`, `phaseName` |
| Private members | `_` prefix | `_counter`, `_MindBody` |
| Directories | `snake_case/` | `theme/`, `domain/`, `cubit/` |
| Tests | `_test.dart` suffix | `mind_cubit_test.dart` |
| State classes | `*State` | `MindState` |
| Cubit classes | `*Cubit` | `MindCubit` |

---

## Rules for Adding New Features

### Structure

1. Create a new directory under `lib/features/<feature_name>/`.
2. Organize layers as:
   - `data/` — Repository implementations
   - `domain/` — Business entities and value objects
   - `presentation/cubit/` — Cubit and State
   - `presentation/pages/` — Page widgets
   - `presentation/widgets/` — Feature-specific widgets
3. Register new routes in `lib/app/router/app_router.dart`.
4. Register new services and Cubits in `lib/app/di.dart`.
5. Add tests mirroring the feature structure under `test/`.

### Conventions

- Cubits call `load()` or async init method on creation.
- Pages use `BlocProvider` to create Cubits and `BlocBuilder` to react to state.
- Use existing design tokens (`AppColors`, `AppSpacing`, `AppTypography`).
- Do not hardcode design values.
- State classes should avoid Equatable when identity-based equality conflicts with value-based comparison.

### Verification

- Run `dart format .` after changes.
- Run `flutter analyze` — must pass with no issues.
- Run `flutter test` — must pass with no failures.
