# Roadmap

> **Note:** This roadmap is high-level and does not include deadlines. Phase order reflects logical dependencies. Phases may overlap or be reordered as the project evolves.

---

## Phase 0 — Foundation ✓

**Status:** Complete

**Objective:** Establish the project scaffold, theme system, and development foundation.

**Key Work:**
- [x] Flutter project initialization
- [x] Centralized theme system (colors, typography, spacing)
- [x] Light and dark theme support
- [x] Material 3 integration
- [x] ThemeController for theme mode switching
- [x] Initial widget test
- [x] Project documentation foundation

**Dependencies:** None

**Completion Criteria:**
- `flutter analyze` passes with no issues
- `flutter test` passes
- Theme system provides consistent light and dark themes
- Documentation is established

---

## Phase 1 — App Architecture

**Status:** Complete ✓

**Objective:** Establish the application architecture that all feature development builds upon.

**Key Work:**
- State management setup (BLoC/Cubit)
- Routing/navigation (declarative router)
- Project structure reorganization (`src/core/`, `src/data/`, `src/domain/`, `src/presentation/`)
- Dependency injection setup
- Error handling foundation
- Custom app widget (replacing default counter home)

**Dependencies:** Phase 0

**Completion Criteria:**
- State management is functional with at least one demo Cubit
- Navigation can route between pages
- DI is configured for core services
- Default counter page is replaced with placeholder Seima page
- All tests pass

---

## Phase 2 — Core Experience

**Status:** Complete ✓

**Objective:** Build the core mind-mapping experience — the primary interface of the application.

**Key Work:**
- [x] Infinite canvas with pan/zoom
- [x] Node creation, selection, editing, deletion
- [x] Connection creation between nodes
- [x] Local persistence (shared_preferences)
- [x] Auto-save on mutations
- [x] Domain models (Mind, MindNode, MindConnection)
- [x] State management (MindCubit)
- [x] Basic map organization (save, open, list)
- [x] Undo/redo for map operations (implemented in Phase 3)
- [x] Keyboard shortcuts (implemented in Phase 3)

---

## Phase 3 — Knowledge System + Workspace Management

**Status:** Complete ✓

**Objective:** Add workspace management, knowledge organization, and editing productivity.

**Key Work:**
- [x] Phase 2 hardening (lastAccessedAt, selection clearing, versioned storage)
- [x] Mind Library (list, create, rename, delete, duplicate)
- [x] Multiple mind lifecycle
- [x] Mind metadata (title, description, timestamps, lastAccessedAt)
- [x] Node tags
- [x] Undo/redo (Ctrl+Z/Y)
- [x] Keyboard shortcuts (Delete/Backspace for node deletion)
- [x] Search across minds and nodes (case-insensitive)
- [x] Navigation: library, workspace, search
- [x] MindLibraryCubit, SearchCubit separation
- [x] 111 tests (50 new), 0 analyzer issues

---

## Phase 4 — Knowledge Workspace & Data Foundation

**Status:** Complete ✓

**Objective:** Improve canvas productivity, knowledge organization, data persistence hardening, and UX hardening.

**Key Work:**
- [x] Multi-selection (select all, toggle, batch move/delete)
- [x] Canvas productivity (multi-node movement, deletion, keyboard shortcuts)
- [x] Tag management UI (add/remove tags in node editor, display on canvas)
- [x] Tag search and filtering (search by tag, show tags in results)
- [x] Debounced auto-save (300ms timer, no race conditions)
- [x] MindState equality fix (removed Equatable, identity-based comparison)
- [x] Empty canvas state with guidance
- [x] Persistence audit (keep shared_preferences, justified)
- [x] 122 tests (11 new), 0 analyzer issues

**Dependencies:** Phase 3

**Completion Criteria:**
- Multi-node selection and batch operations work correctly
- Tags are editable in node dialog and visible on canvas
- Search finds nodes by tag content
- Auto-save debounces without race conditions
- All tests pass, analyze clean

---

## Phase 5 — AI Knowledge Intelligence (Local-First)

**Status:** Complete ✓

**Objective:** Build local-first, privacy-first AI analysis within the knowledge workspace, with a provider-agnostic architecture ready for real on-device LLM integration.

**Key Work:**
- [x] AI domain models (AIConfig, AIContext, AIResponse, AIProposal sealed types)
- [x] AI state management (AICubit + AIState with loading/success/failure)
- [x] Abstract AIService interface (provider-agnostic, replaceable)
- [x] LocalAIService with deterministic heuristic analysis (themes, isolated nodes, content overlap)
- [x] MindContextBuilder (converts Mind → AIContext, no data leaves device)
- [x] AIPanel overlay (DraggableScrollableSheet in MindPage)
- [x] ProposalCard UI with apply button (NewNodeProposal, ConnectionProposal)
- [x] AI button in mind page app bar → analyze → review → apply flow
- [x] Applied proposals use MindCubit → undo/redo works automatically
- [x] Privacy-first: no external API, no HTTP calls, no data off-device
- [x] 148 tests (26 new), 0 analyzer issues
- [x] ADRs: local-first AI (ADR-024), separate AI Cubit with proposals (ADR-025), heuristic development approach (ADR-026)
- [x] Documentation: architecture, decisions, roadmap, status all updated

**Dependencies:** Phase 2, Phase 3, Phase 4

**Completion Criteria:**
- AI analysis runs 100% on-device with no external dependencies
- AI panel opens/closes on demand with analysis and proposals
- Proposals require user confirmation before applying to mind
- Applied proposals are undoable/redoable
- Architecture supports future real on-device LLM integration without structural changes

---

## Phase 6 — Real On-Device LLM Integration

**Status:** Complete ✓

**Objective:** Replace heuristic LocalAIService with a real on-device LLM while preserving Seima's privacy-first architecture. Desktop platforms run llama.cpp via subprocess; mobile/web fall back to heuristic.

**Key Work:**
- [x] Platform audit (Flutter 3.44.2, Dart 3.12.2, all 6 platforms configured)
- [x] On-device LLM research (llama_cpp_dart, llamadart, llm_llamacpp evaluated)
- [x] Process-based architecture decision (dart:io Process + llama.cpp CLI)
- [x] LocalLLMRuntime abstract interface
- [x] ProcessLLMRuntime (subprocess management, streaming, lifecycle)
- [x] LLMAIService (AIService implementation with LLM + heuristic fallback)
- [x] ModelManager (detect, download, delete GGUF models)
- [x] LLMResponseParser (extract analysis text + structured JSON proposals)
- [x] AIConfig extended (modelPath, llamaExecutablePath, temperature, context)
- [x] AIFailure.model factory for model-specific errors
- [x] AIState extended (ModelState enum, downloadProgress, streaming status)
- [x] AICubit (model status check, download, streaming tokens)
- [x] AIPanel updated (model status bar, download UI, streaming display)
- [x] MindContextBuilder improved (content truncation, node prioritization for large minds)
- [x] Fallback: heuristic LocalAIService for unsupported platforms
- [x] Privacy: 100% on-device, no data off-device, model download is separate
- [x] 192 tests (44 new), 0 analyzer issues
- [x] ADRs: process-based LLM (ADR-027), Qwen2.5-1.5B model (ADR-028), optional download (ADR-029)

**Dependencies:** Phase 5 (AI architecture, AIService interface)

**Completion Criteria:**
- Real LLM runs on-device via llama.cpp subprocess
- Mind data remains on-device at all times
- LLM receives actual Mind context and produces specific analysis
- At least one analysis flow works (summarization + proposals)
- Proposals require user confirmation before applying
- Applied LLM changes support undo/redo (via MindCubit)
- Unsupported platforms gracefully fall back to heuristic
- Application remains responsive (non-blocking inference)
- All tests pass, 0 analyzer issues

---

## Phase 7 — Advanced Knowledge Workspace + Production Hardening

**Status:** Complete ✓

**Objective:** Improve canvas productivity with node types, curved bezier connections, connection selection, and import/export. Followed by a comprehensive production-readiness hardening audit across architecture, data integrity, undo/redo, AI/LLM safety, persistence, and testing.

**Key Work:**
- [x] Node types — text, task, question, idea with type-specific colors/icons
- [x] Curved bezier connections
- [x] Connection selection (tap to highlight, delete)
- [x] Import/export (JSON format with connection validation)
- [x] Drag undo grouping — single undo per drag operation (not 50+ entries)
- [x] Debounced autosave (300ms) with save-in-progress guard
- [x] Autosave lifecycle guard (timer cancelled on close)
- [x] Viewport culling for canvas performance
- [x] Fit-to-content
- [x] Undo/redo audit & fix (drag isolation, _preDragMind capture)
- [x] Data integrity — fromJson unknown/missing node type fallback to text
- [x] Import connection validation (rejects references to non-existent nodes)
- [x] AI streaming interface (analyzeStreaming added to AIService)
- [x] AICubit service layer fix (calls AIService instead of LLM directly)
- [x] Dead code removal (ai_request.dart deleted)
- [x] isClosed guards in stream callbacks
- [x] generateId collision reduction
- [x] Model download integrity (temp file + size verification)
- [x] Bidirectional duplicate connection check
- [x] LLM response parser content length limits
- [x] Content/tag length validation on AI proposals
- [x] Privacy audit — verified 100% on-device, no data exfiltration
- [x] AI/LLM safety audit — proposals require confirmation, undo works
- [x] Full architecture audit
- [x] Documentation sync — all docs updated to current implementation
- [x] 219 tests (27 new), 0 analyzer issues
- [x] dart format — clean
- [x] All existing tests preserved and passing

**Dependencies:** Phase 2, Phase 3, Phase 4, Phase 5, Phase 6

**Completion Criteria:**
- Canvas supports node types with visual differentiation
- Connections use curved bezier rendering
- Users can select connections for deletion
- Import/export preserves all data (nodes, connections, types)
- Drag operations produce exactly one undo entry, not hundreds
- Debounced autosave does not race with close()
- Corrupt/unknown JSON data does not crash the app
- AI proposals are validated for size and content
- Model downloads are resilient to interruption
- All tests pass, 0 analyzer issues
- Documentation is accurate

---

## Phase 9 — Sharing & Interoperability Foundation ✓

**Status:** Complete

**Objective:** Establish Seima's sharing and interoperability architecture as a first-class capability. Design canonical interchange format, build export/import pipelines, integrate platform share mechanisms, and provide safe import preview UX.

**Key Work:**
- [x] Canonical Seima knowledge format (`SeimaKnowledgePackage` with `schema: seima_knowledge`)
- [x] Deterministic serialization with explicit schema identity and version field
- [x] Forward-compatible parsing (unknown fields preserved, missing optionals defaulted)
- [x] Export pipeline (`ExportService`): `.seima` file, clipboard copy, human-readable text
- [x] Import pipeline (`ImportService`): canonical JSON, plain text, clipboard with auto-format detection
- [x] Input format detection (`InputDetector`)
- [x] Import preview with validation (source, title, node/connection count, warnings, errors)
- [x] Import as new mind or merge into existing mind
- [x] Prevent silent data overwrite (preview-first architecture)
- [x] Android share intent receiving (`ACTION_SEND` text/plain, application/json)
- [x] Kotlin `MainActivity` share handling via MethodChannel (`com.seima/sharing`)
- [x] Share handler initialization at app startup
- [x] Export page with per-mind export options (file, clipboard, text preview)
- [x] Share button in mind workspace app bar
- [x] Import/Export settings page rewritten with real navigation
- [x] Import preview screen with validation, warnings, action buttons
- [x] Import destination picker dialog
- [x] Import summary card widget
- [x] Architecture documentation: `docs/SHARING_INTEROPERABILITY_ARCHITECTURE.md`
- [x] ADR-033: Canonical Seima Knowledge Interchange Format
- [x] ADR-034: Import Pipeline with Preview-First Architecture
- [x] Updated all existing documentation to reflect new capabilities
- [x] New dependencies: `path_provider`, `share_plus`, `file_picker`

**Dependencies:** Phase 2 (Mind domain models), Phase 6 (UI patterns)

**Completion Criteria:**
- Canonical format supports round-trip: Seima → export → import → Seima
- Export preserves all mind content (nodes, connections, types, positions, timestamps)
- Import shows preview before mutation
- Import supports new mind creation and merge into existing
- Invalid input produces user-friendly errors (not crashes)
- Android share intent triggers import preview
- All tests pass, 0 analyzer issues
- Documentation is accurate

---

## Phase 10 — Sharing & Interoperability Expansion

**Status:** Planned

**Objective:** Extend sharing to more input/output formats and enhance platform integration.

**Key Work:**
- Markdown import (headers → nodes, lists → connections)
- Markdown export
- Image/PDF export (canvas screenshot)
- Text selection export from mind workspace
- iOS share/receive integration
- File picker integration for `.seima` file import
- Deep link support
- URL content extraction adapter
- XMind/FreeMind/OPML adapter support
- AI-assisted import structuring

**Dependencies:** Phase 9

---
