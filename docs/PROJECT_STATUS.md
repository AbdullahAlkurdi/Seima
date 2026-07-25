# Project Status

> **Last updated:** 2026-07-25

---

## Current Phase

**Phase 7 — Advanced Knowledge Workspace + Production Hardening** (Complete)
Canvas productivity improved with node types (text/task/question/idea), curved bezier connections, connection selection, and JSON import/export. Comprehensive production-readiness hardening audit completed: undo/redo drag isolation, fromJson safety for unknown/missing node types, import connection validation, debounced autosave lifecycle guard, generateId collision reduction, dead code removal, AICubit service layer fix, model download integrity (temp file + size verification), bidirectional duplicate connection check, AI content/tag length limits, and privacy/security audits. 219 tests pass, 0 analyzer issues.

---

## Completed Work

### Phase 0 — Foundation
- [x] Flutter project initialized
- [x] Cross-platform scaffold (Android, iOS, Web, Windows, macOS, Linux)
- [x] Centralized theme system (colors, typography, spacing, app_theme)
- [x] Light and dark theme support with Material 3
- [x] Theme mode switching (ThemeController + MindoraTheme InheritedWidget)
- [x] ThemeController.toggle() method

### Phase 1 — App Architecture
- [x] Feature-first project organization
- [x] State management (flutter_bloc 9.x Cubit)
- [x] Routing (go_router 14.x)
- [x] Dependency injection (get_it 8.x)
- [x] Error handling foundation (AppException + Failure)
- [x] App configuration and shell
- [x] Test foundation

### Phase 2 — Core Mindora Experience
- [x] Domain models — Mind, MindNode, MindConnection, NodeType
- [x] JSON serialization — toJson/fromJson for all models
- [x] Local persistence — shared_preferences-based MindRepository
- [x] State management — MindCubit with full CRUD for nodes/connections
- [x] Infinite canvas — InteractiveViewer with pan/zoom
- [x] Node rendering — Positioned card nodes with content display
- [x] Node selection — Tap to select, selection indicator
- [x] Node editing — Dialog-based content editing
- [x] Node movement — Drag with onPanUpdate
- [x] Node deletion — Delete via action buttons
- [x] Connection rendering — CustomPainter with arrowheads
- [x] Connection creation — Two-tap connect mode
- [x] Connection deletion — Delete via action buttons
- [x] Canvas deselection — Tap background to deselect
- [x] Node creation — FAB button
- [x] Auto-save — Save on create/delete operations
- [x] Mind routing — `/` loads most recent mind, `/mind/:id` loads specific
- [x] Connect mode indicator — Visual badge in app bar
- [x] Error state — Loading and error UI in mind page

### Phase 3 — Knowledge System + Workspace Management
- [x] Phase 2 hardening — lastAccessedAt, tags, versioned storage, selection clearing
- [x] Mind Library — List view of all minds with create/rename/delete/duplicate
- [x] Multiple Minds — Full lifecycle: create, load, rename, duplicate, delete
- [x] Mind metadata — title, description, timestamps, lastAccessedAt
- [x] Node tags — Optional tags on nodes for organization
- [x] Search — Case-insensitive search across mind titles and node content
- [x] Undo/redo — In-memory history stack for node/connection/title operations
- [x] Keyboard shortcuts — Ctrl+Z (undo), Ctrl+Y (redo), Delete/Backspace
- [x] Navigation — `/` library, `/mind/:id` workspace, `/search` search
- [x] MindLibraryCubit — Separate cubit for library operations
- [x] SearchCubit — Separate cubit for search with results navigation
- [x] MindState undo/redo — History stacks with 50-item cap
- [x] Versioned storage — Storage format versioning for future migrations
- [x] Repository.duplicate — Deep copy minds with new IDs

### Phase 4 — Knowledge Workspace & Data Foundation
- [x] **Multi-selection** — Replace single `selectedNodeId` with `Set<String> selectedNodeIds`
- [x] **Select All / Clear** — Ctrl+A selects all nodes, Escape clears selection
- [x] **Toggle Selection** — Ctrl/Cmd+click toggles node in/out of selection set
- [x] **Batch Delete** — Delete/Backspace deletes all selected nodes
- [x] **Batch Move** — Dragging a selected node when multiple are selected moves all
- [x] **Tag UI** — Node editor dialog shows tag input, chips, and delete buttons
- [x] **Tag Display** — Tags shown as small colored containers on canvas nodes
- [x] **Tag Search** — SearchCubit finds nodes whose tags match the query
- [x] **Tag Results** — Search page displays matching tags in results
- [x] **Debounced Auto-Save** — 300ms Timer-based debounce replaces fire-and-forget
- [x] **MindState Equality** — Removed Equatable from MindState (identity-based comparison)
- [x] **Empty Canvas** — Helpful message when mind has no nodes
- [x] **Persistence Audit** — Confirmed shared_preferences appropriate for current scale
- [x] **Selection Count Badge** — App bar shows count when >1 nodes selected
- [x] **Documentation** — Updated ADRs, architecture, roadmap, and status

### Phase 5 — AI Knowledge Intelligence (Local-First)
- [x] **AI Domain Models** — AIConfig, AIContext (with AIContextNode, AIContextConnection), AIResponse, sealed AIProposal (NewNodeProposal, ConnectionProposal), AIFailure
- [x] **AIService Interface** — Abstract provider-agnostic AIService with analyze() method
- [x] **LocalAIService** — Deterministic heuristic analysis (themes, isolated nodes, content overlap)
- [x] **MindContextBuilder** — Converts Mind → AIContext (structured, deterministic, no data leaves device)
- [x] **AICubit + AIState** — Separate cubit for AI state management (initial/loading/success/failure, panel open/close, proposals)
- [x] **AIPanel UI** — DraggableScrollableSheet overlay in MindPage with analysis display
- [x] **ProposalCard** — Proposal review widgets with apply/cancel actions
- [x] **MindPage Integration** — AI button in app bar, MultiBlocProvider, proposal application through MindCubit
- [x] **DI Registration** — AIService (singleton), AICubit (factory)
- [x] **http Removed** — No external API dependencies
- [x] **Privacy Architecture** — 100% on-device, no Mind data off-device, offline-capable
- [x] **Decision Records** — ADR-024 (local-first), ADR-025 (separate AI cubit with proposals), ADR-026 (heuristic dev approach)
- [x] **Documentation** — Updated architecture, roadmap, status, decisions, vision
- [x] **AI Tests** — 26 tests (domain models, context builder, local AI service, AICubit)

### Phase 6 — Real On-Device LLM Integration
- [x] **Platform Audit** — Flutter 3.44.2, Dart 3.12.2, all 6 platforms configured
- [x] **LLM Research** — Evaluated llama_cpp_dart, llamadart, llm_llamacpp; selected Process-based approach
- [x] **LocalLLMRuntime Interface** — Abstract runtime with status, initialize, generate(stream), dispose
- [x] **ProcessLLMRuntime** — dart:io Process spawning llama.cpp CLI, streaming tokens via stdout
- [x] **LLMAIService** — AIService using LLM runtime with heuristic fallback when model unavailable
- [x] **ModelManager** — GGUF model detection, optional download from HuggingFace (Qwen2.5-1.5B Q4_K_M, ~1GB)
- [x] **LLMResponseParser** — Parse LLM output into analysis text + structured JSON proposals
- [x] **AIConfig Extended** — modelPath, llamaExecutablePath, temperature, maxContextTokens, useLLM
- [x] **AIState Extended** — ModelState enum (unknown, notAvailable, downloading, ready, error), downloadProgress
- [x] **AICubit Extended** — model status check, download with progress, streaming token emission, analyzeStreaming()
- [x] **AIPanel Updated** — Model status bar (local AI ready / offline analysis), download button, progress bar
- [x] **MindContextBuilder Improved** — Content truncation (200 chars/node), node prioritization for large minds (50 node limit), buildTruncated()
- [x] **Fallback** — Heuristic LocalAIService remains for mobile/web/unsupported platforms
- [x] **Privacy** — 100% on-device, no data off-device, model download is network-only for public model
- [x] **Decision Records** — ADR-027 (Process-based LLM), ADR-028 (Qwen2.5-1.5B model), ADR-029 (optional download)
- [x] **Documentation** — Updated architecture, roadmap, status, decisions, development guide
- [x] **LLM Tests** — 44 new tests (response parser, LLM AI service, model manager, process runtime, AICubit model states)

### Phase 7 — Advanced Knowledge Workspace + Production Hardening
- [x] **Node Types** — Four node types (text/task/question/idea) with type-specific colors, icons, and labels
- [x] **Curved Connections** — Bezier curve rendering with source/target side detection
- [x] **Connection Selection** — Tap to select a connection (highlighted in accent color), delete via keyboard
- [x] **Import/Export** — JSON format export of full mind; import with connection validation
- [x] **Drag Undo Grouping** — `beginNodeDrag()`/`endNodeDrag()` + `_preDragMind` capture; single undo per drag operation
- [x] **Auto-Save Lifecycle Guard** — `_saveInProgress` flag prevents concurrent saves; timer cancelled on close
- [x] **fromJson Safety** — Unknown/missing node type falls back to `NodeType.text`
- [x] **Import Validation** — Connections referencing non-existent nodes are rejected
- [x] **Dead Code Removal** — `ai_request.dart` deleted
- [x] **AICubit Fix** — Uses `AIService.analyzeStreaming()` instead of `llmRuntime.generate()` directly
- [x] **isClosed Guards** — Stream callbacks check `isClosed` before emit
- [x] **generateId Improvement** — Stronger random ID generation
- [x] **Model Download Integrity** — Temp file (`part`), size verification, atomic rename
- [x] **Bidirectional Duplicate Check** — Both `A->B` and `B->A` connections treated as duplicates
- [x] **Content Length Limits** — AI proposals capped at 2000 chars content, 50 chars per tag, max 10 tags
- [x] **Privacy Audit** — Verified 100% on-device; no Mind data leaves device
- [x] **AI/LLM Safety Audit** — Proposals require confirmation; undo/redo works for AI mutations
- [x] **Architecture Audit** — Feature-first, layer boundaries, dead code, duplicate detection
- [x] **Documentation Sync** — All docs updated to match implementation
- [x] **Phase 7 Tests** — 27 new tests (fromJson safety, drag grouping, import validation, connection selection, parser limits)
- [x] **Decision Records** — ADR-030 (Phase 7 hardening), ADR-031 (content/tag limits), ADR-032 (partial download protection)

---

## Current Implementation Status

| Area | Status | Details |
|---|---|---|
| Theme system | **Implemented** | Colors, typography, spacing, light/dark, M3, toggle() |
| State management | **Implemented** | MindCubit, MindLibraryCubit, SearchCubit |
| Routing | **Implemented** | `/` library, `/mind/:id` workspace, `/search` search |
| Dependency injection | **Implemented** | AIService, AICubit, ThemeController, GoRouter, MindRepository, MindCubit, MindLibraryCubit, SearchCubit |
| Error handling | **Implemented** | AppException + Failure types |
| App configuration | **Implemented** | AppConfig constants |
| Data layer | **Implemented** | MindRepository with versioned storage (shared_preferences) |
| Domain models | **Implemented** | Mind (with lastAccessedAt), MindNode (with tags), MindConnection, NodeType |
| Canvas | **Implemented** | InteractiveViewer + CustomPaint connections + keyboard shortcuts |
| Node interactions | **Implemented** | Create, select (single/multi), edit, move (single/batch), delete (single/batch), change type |
| Connection interactions | **Implemented** | Create (connect mode), select (single), delete, curved bezier rendering |
| Undo/redo | **Implemented** | In-memory 50-item stack, Ctrl+Z/Y, multi-operation support |
| Search | **Implemented** | Case-insensitive across minds, nodes, and tags |
| Tag management | **Implemented** | Add/remove in node editor, display on canvas, search by tag |
| Mind Library | **Implemented** | List with create, rename, delete, duplicate |
| Auto-save | **Implemented** | 300ms debounced on all mutations |
| Import/Export | **Implemented** | JSON export/import with connection validation |
| Drag undo grouping | **Implemented** | Single undo entry per drag operation |
| Undo/redo with persistence | **Implemented** | Auto-saves after undo/redo |
| Multi-selection | **Implemented** | Toggle, select all, clear, batch move/delete |
| AI integration | **Implemented** | LLM-based on desktop, heuristic fallback on mobile/web |
| AI architecture | **Provider-agnostic** | AIService → LLMAIService (LLM) / LocalAIService (heuristic) |
| AI LLM runtime | **Process-based (desktop)** | dart:io Process → llama.cpp CLI → GGUF model |
| AI model | **Qwen2.5-1.5B Q4_K_M (optional)** | ~1GB download, optional, detect automatically |
| AI privacy | **100% on-device** | No external API, no HTTP for inference, model download only |
| AI streaming | **Implemented** | Token streaming via stdout, AIStatus.streaming state |
| Accessibility | **Not started** | No explicit accessibility work done |
| Testing coverage | **Expanded** | 219 tests (unit) across all layers |

---

## Known Limitations

- Canvas has a fixed virtual size (5000×5000) rather than truly infinite
- Node height is content-dependent, may overlap in tight spaces
- Undo/redo stacks are in-memory only (lost on page close)
- Search is local-only with no fuzzy matching
- No keyboard shortcut customization
- Multi-selection via rect/drag-select not implemented
- Canvas performance may degrade with 100+ visible nodes
- shared_preferences serializes full dataset on each save (acceptable at current scale)
- AI on mobile/web uses heuristic fallback (no LLM available on those platforms)
- LLM requires user to download a ~1GB model file and have a llama.cpp executable
- ProcessLLMRuntime is desktop-only (mobile/web cannot spawn subprocesses)
- No GPU acceleration for LLM inference (CPU-only subprocess)
- No model quantization selection UI (defaults to Q4_K_M)
- AI panel may cover canvas content (DraggableScrollableSheet overlay)
- LLM process has no concurrent generate guard (single analysis at a time is enforced by AICubit state)
- Single "Apply" for new node proposals creates 3 undo entries (create + tags + content)

---

## Active Priorities

1. Keyboard shortcut customization
2. Rect/drag-select for multi-selection
3. Undo/redo persistence across sessions
4. FFI-based LLM runtime for mobile platforms (Android/iOS)
5. Export to image/PDF/markdown
6. Accessibility audit (WCAG 2.1 AA)
7. Performance profiling with 500+ node maps

---

## Next Recommended Milestone

**Phase 8 — Advanced Features + Platform Expansion**

Primary objectives:
- Keyboard shortcut customization
- Rect/drag-select for multi-selection
- Undo/redo persistence across sessions
- FFI-based LLM runtime for mobile (Android/iOS)
- Export (image, PDF, markdown)
- Rich media nodes (images, links, code blocks)
- Accessibility audit and fixes
- Performance optimization for 500+ nodes

---

## Verification Status

| Check | Result | Date |
|---|---|---|
| `flutter analyze` | No issues found | 2026-07-25 |
| `flutter test` | All 219 tests passed | 2026-07-25 |
| `dart format .` | No formatting issues | 2026-07-25 |
| Architecture | Feature-first + clean separation + AI layers + LLM runtime | Verified |
| Theme system | Light + Dark, M3, seed-based | Verified |
| Routing | Library, workspace, search routes | Verified |
| DI | 12 registrations, proper lifetimes | Verified |
| AI privacy | 100% on-device, no external API calls | Verified |
| AI architecture | AIService → LLMAIService (LLM) / LocalAIService (heuristic fallback) | Verified |
| AI LLM runtime | ProcessLLMRuntime (llama.cpp subprocess, streaming) | Verified |
| AI model management | ModelManager (detect, download, delete GGUF models, temp file + size verify) | Verified |
| AI streaming | Token streaming via AICubit.analyzeStreaming() | Verified |
| No new external deps | Uses only dart:io (built into SDK) | Verified |
| Node types | text, task, question, idea with colors/icons | Verified |
| Connection selection | Tap to select, highlight, delete | Verified |
| Import/Export | JSON format with validation | Verified |
| Drag undo grouping | Single undo per drag, not 50+ entries | Verified |
| Bidirectional duplicates | Both directions rejected | Verified |
| Content length limits | 2000 chars / 50 per tag / 10 tags max | Verified |
| Model download integrity | Temp file, size verify, atomic rename | Verified |
| fromJson safety | Unknown type falls back to text | Verified |
