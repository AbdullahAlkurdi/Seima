# Implementation Gap Analysis — Seima

---

## A. What Can a Real User Actually Do with Seima TODAY?

Assuming a successful build and install on SM-A057F:

1. **Launch the app** — See the animated splash screen with Seima logo (1.2s)
2. **See the Library** — View the mind library (initially empty with welcome message)
3. **Create a mind** — Tap FAB "New Mind", enter name + optional category
4. **Enter the workspace** — Auto-navigate to the mind canvas
5. **Add nodes** — Tap FAB "+" to add nodes at grid positions
6. **Edit nodes** — Double-tap to open node editor (change type, content, tags)
7. **Connect nodes** — Select a node, tap connect icon, tap target node
8. **Drag nodes** — Pan to reposition nodes with undo grouping
9. **Zoom/pan canvas** — Pinch zoom, pan the infinite canvas
10. **Select nodes** — Tap single, Shift+drag rectangular selection, Ctrl+click
11. **Delete nodes** — Select → delete icon, or Del/Backspace key
12. **Undo/redo** — Ctrl+Z/Y or AppBar buttons (50-deep history)
13. **Search** — Navigate to search, type query (300ms debounce), tap result
14. **Quick capture** — Navigate to quick capture, type thought, save to mind
15. **AI analysis (heuristic)** — Navigate to AI analysis page, get text analysis + proposals
16. **Apply AI proposals** — "Add to Mind" / "Connect" from proposal cards
17. **Toggle theme** — Light/dark toggle from any app bar
18. **Export mind** — Navigate to export, save .seima to temp or copy to clipboard
19. **Import mind** — Navigate to import, paste content, preview, confirm
20. **Share content into Seima** — Share text from another app → Seima appears as option
21. **Home screen widget** — Add Seima widget with "New Thought" and "Open Seima" buttons
22. **Access settings** — Theme toggle, AI model management, export/import page

---

## B. How Many Screens Exist?

**12 unique screens** (10 functional, 2 partially functional via 13 routes)

---

## C. How Many Screens Are Reachable?

**12 out of 12** — All screens are reachable via navigation

---

## D. How Many Are Actually Functional?

**8 out of 10** fully functional:
- MindLibraryPage ✅
- MindPage (workspace) ✅
- SearchPage ✅
- QuickCapturePage ✅
- AIAnalysisPage ✅
- SettingsPage ✅
- ExportImportPage ✅
- AIModelManagementPage ✅

Partially functional:
- ExportPage ⚠️ (fragile dynamic cast, temp dir only)
- ImportPreviewPage ⚠️ (cannot test full flow without a build)

---

## E. Which Core Features Are Complete?

1. ✅ Branding / Seima identity
2. ✅ Splash / Startup animation
3. ✅ Launcher icon (all platforms)
4. ✅ Mind Library (CRUD, list, sort)
5. ✅ Create mind (with name + category)
6. ✅ Quick Capture
7. ✅ Canvas workspace (infinite, pan/zoom)
8. ✅ Nodes (create, edit, delete, drag)
9. ✅ Node types (text, task, question, idea)
10. ✅ Connections (create, cancel, delete)
11. ✅ Bezier curved connections with arrowheads
12. ✅ Node editor (type, content, tags)
13. ✅ Selection (single, multi, rectangle)
14. ✅ Undo/redo (Ctrl+Z/Y, app bar, drag grouping, batch)
15. ✅ Search (debounced, content + tags)
16. ✅ Keyboard shortcuts
17. ✅ AI heuristic analysis (LocalAIService)
18. ✅ AI proposals (new node + connection)
19. ✅ AI proposal application with batch undo
20. ✅ Theme toggle (light/dark/system)
21. ✅ Loading states (3 variants)
22. ✅ Empty states (all screens)
23. ✅ Error states (all screens with retry)
24. ✅ Persistence (save/load/backup/recovery)
25. ✅ Autosave (300ms debounced)
26. ✅ Data recovery (backup-on-write + auto-restore)
27. ✅ Home screen widget (Android)
28. ✅ Export Service (.seima, clipboard, text)
29. ✅ Import Service (.seima, JSON, text) with validation
30. ✅ Import Preview with new mind + merge modes
31. ✅ External share → Seima import
32. ✅ Privacy (100% local, no telemetry)
33. ✅ Versioned storage format
34. ✅ Canvas viewport culling

---

## F. Which Are Partial?

1. ⚠️ **Mind Categories** — Model supports it, create dialog accepts it, but no UI display or filtering
2. ⚠️ **LLM Integration** — Code exists but is desktop-only (Process.start). Requires FFI for mobile
3. ⚠️ **Model Management** — Download works; cancel and delete are stubs
4. ⚠️ **AI Safety** — Only content/tag length limits; no sanitization, confirmation, rate limiting
5. ⚠️ **Export to File** — Works but saves to temp dir, no user-selected location
6. ⚠️ **Export Page** — Works but uses dynamic cast on state
7. ⚠️ **Performance** — Viewport culling helps; full-state rebuild hurts
8. ⚠️ **AI Streaming** — Implemented for desktop LLM only; heuristic falls back to non-streaming
9. ⚠️ **Accessibility** — Basic Semantics on nodes and loading view only
10. ⚠️ **Fit-to-content** — Works but fires on every rebuild due to addPostFrameCallback in build()

---

## G. Which Are Missing?

1. ❌ **Undo/redo persistence** — In-memory only; lost on app restart
2. ❌ **Mind settings** — No per-mind title/description/color settings
3. ❌ **Clear All Data** — Stub "not yet implemented"
4. ❌ **About Seima page** — Tile exists but is a no-op
5. ❌ **Seima → External app sharing** — No platform share sheet integration
6. ❌ **File save dialog for export** — Exports to temp dir only
7. ❌ **Model download cancellation** — Stub
8. ❌ **Model deletion from UI** — Stub
9. ❌ **Search history** — No recent searches
10. ❌ **Keyboard dismiss on search** — No keyboard dismissal action
11. ❌ **Onboarding** — No first-launch onboarding flow
12. ❌ **Category filtering in library** — No category UI
13. ❌ **Mobile LLM runtime** — No FFI-based runtime for Android/iOS
14. ❌ **Export to image/PDF/markdown** — Product spec says future
15. ❌ **Node resize** — No UI for resizing nodes
16. ❌ **Canvas background customization** — No options
17. ❌ **Integration/E2E tests** — 0 integration tests
18. ❌ **Web target** — Builds but no web-specific optimization

---

## H. Which Features Are Broken?

1. ❌ **Android APK build** — Fails with compileSdk 34 vs required 36
2. ❌ **Marine LLM on mobile** — Process.start throws on Android; no mobile runtime
3. ❌ **AIPanel overlapping nav bar** — No SafeArea in DraggableScrollableSheet
4. ❌ **fitToContent on every rebuild** — addPostFrameCallback in build() creates loop
5. ❌ **ExportPage dynamic cast** — `state is List<Mind>` then `state.minds` is fragile
6. ❌ **Small canvas controls on mobile** — No mobile-optimized touch targets for zoom/pan controls
7. ❌ **Full-state rebuild** — BlocBuilder rebuilds entire canvas on any state change

---

## I. Top 10 Critical Problems

| # | Problem | Severity | Impact | Fix Needed |
|---|---------|----------|--------|------------|
| 1 | **APK build fails (compileSdk 34 vs 36)** | BLOCKER | Cannot test on device | Update compileSdk to 36 |
| 2 | **No mobile LLM runtime** | HIGH | AI analysis = heuristic only on mobile | FFI-based runtime for Android |
| 3 | **Full-state canvas rebuild** | HIGH | Lag with 20+ nodes on SM-A057F | BlocSelector for granular rebuilds |
| 4 | **AIPanel overlaps nav bar** | HIGH | Android nav bar obscured | Add SafeArea + bottom padding |
| 5 | **fitToContent rebuild loop** | MEDIUM | Wasted GPU cycles | Remove from build(), call once |
| 6 | **No undo/redo persistence** | MEDIUM | History lost on restart | Persist undo stack |
| 7 | **Export saves to temp dir** | MEDIUM | User can't access exports | Add file picker for save location |
| 8 | **Model management stubs** | MEDIUM | Cancel/delete not working | Implement cancel + delete |
| 9 | **Search keyboard never dismisses** | LOW | Poor UX after search | Add keyboard dismiss on submit |
| 10 | **Clear All Data not implemented** | LOW | Cannot reset app data | Implement data clearing |

---

## J. Top 10 Missing Capabilities

| # | Capability | Priority | User Impact |
|---|-----------|----------|-------------|
| 1 | **Mobile LLM Runtime (FFI)** | Critical | AI on-device LLM doesn't work on mobile |
| 2 | **Platform share sheet for export** | High | Cannot share minds to other apps |
| 3 | **User-selected export location** | High | Export files are invisible to user |
| 4 | **Undo/redo persistence** | High | History lost on app restart |
| 5 | **Onboarding flow** | Medium | New users have no guidance |
| 6 | **Mind settings (rename from workspace)** | Medium | Must go back to library to rename |
| 7 | **Category filtering/display** | Medium | Category data is collected but invisible |
| 8 | **Image/PDF/markdown export** | Medium | Major missing export formats |
| 9 | **Canvas background/themes** | Low | No visual customization |
| 10 | **Node resize handles** | Low | Nodes are fixed size |

---

## K. Top Performance Problems

| # | Problem | Location | Impact |
|---|---------|----------|--------|
| 1 | **Full-state rebuild on any mutation** | BlocBuilder in _MindBody | Every canvas operation rebuilds ALL nodes |
| 2 | **No RepaintBoundary on node widgets** | CanvasNodeWidget | All nodes repaint even when one changes |
| 3 | **fitToContent on every build** | mind_page.dart:199 | Matrix recomputation every frame |
| 4 | **Layer optimization** | Stack in MindCanvas | Entire canvas is single composited layer |
| 5 | **No ValueNotifier for drags** | GestureDetector pan | State emit on every drag delta |
| 6 | **No node virtualization** | Positioned for all nodes | Even offscreen nodes consume layout |

---

## L. Top UX Problems

| # | Problem | Location | User Impact |
|---|---------|----------|-------------|
| 1 | **AI panel overlaps Android nav** | AIPanel | Bottom buttons/gestures blocked |
| 2 | **fitToContent auto-zooms on open** | MindPage | User confused by unexpected zoom |
| 3 | **No keyboard dismiss on search** | SearchPage | Stuck keyboard after search |
| 4 | **Export to invisible location** | ExportPage | User thinks export failed |
| 5 | **No confirmation before AI proposals** | AIAnalysisPage | Proposals applied without preview |
| 6 | **Small FAB touch target** | MindPage | Hard to tap on mobile |
| 7 | **No zoom controls UI** | MindPage | User must know pinch gesture |
| 8 | **No canvas toolbar** | MindPage | All actions in AppBar, far from content |

---

## M. Actual State of AI/LLM

| Component | Status | Reality |
|-----------|--------|---------|
| AIService interface | ✅ | Abstract class with analyze() and analyzeStreaming() |
| LocalAIService (heuristic) | ✅ WORKS | Deterministic text analysis, word frequency, theme extraction, isolated node detection, connection suggestions based on word overlap |
| LLMAIService | ⚠️ DESKTOP ONLY | Wraps LocalLLMRuntime, falls back to heuristic if runtime not ready |
| ProcessLLMRuntime | ❌ MOBILE BROKEN | Uses dart:io Process.start — throws on Android |
| ModelManager | ✅ WORKS | Downloads model files from HuggingFace (Qwen2.5-1.5B ~987MB) |
| AI Analysis Page | ✅ WORKS | Full UI with initial/loading/streaming/success/error states |
| AI Panel | ⚠️ PARTIAL | DraggableScrollableSheet with model status, analysis, proposals; overlaps nav bar |
| AI Proposals | ✅ WORKS | NewNodeProposal + ConnectionProposal with apply functionality |

**Bottom line:** AI "works" on all platforms via heuristic analysis. True LLM-powered analysis is desktop-only. On SM-A057F, only heuristic analysis will ever work without FFI-based mobile LLM runtime.

---

## N. Actual State of Sharing/Import/Export

| Component | Status | Reality |
|-----------|--------|---------|
| Export to .seima | ⚠️ PARTIAL | Writes to directory.systemTemp — invisible to user on mobile |
| Export to clipboard | ✅ WORKS | Copies JSON to system clipboard |
| Export to text | ✅ WORKS | Plain text preview via dialog |
| Export Page | ⚠️ FRAGILE | Dynamic cast on MindLibraryCubit state will crash if state format changes |
| Import .seima package | ✅ WORKS | Full validation (schema, version, node IDs, connectivity) |
| Import plain text | ✅ WORKS | Each line = node, auto-positions |
| Import JSON (legacy) | ✅ WORKS | Detects "mind" key format |
| Import Preview | ✅ WORKS | Summary card, warnings, errors, new/merge options |
| Import as New Mind | ✅ WORKS | Creates new mind in repository |
| Import Merge | ✅ WORKS | Merges into existing mind with offset |
| External → Seima | ✅ WORKS | Android intent filter + MethodChannel |
| Seima → External | ❌ MISSING | No platform share sheet |
| File save dialog | ❌ MISSING | No user-chosen export path |
| Share from workspace | ⚠️ PARTIAL | AppBar share button navigates to export page |

---

## O. Actual State of Persistence/Data Safety

| Component | Status | Reality |
|-----------|--------|---------|
| Data format | ✅ JSON via shared_preferences | All minds serialized as JSON array under single key |
| Schema versioning | ✅ Version 1 | `schemaVersion` field on Mind model |
| Backup strategy | ✅ Backup before write | Saves current state to `minds_backup` before overwriting |
| Corruption recovery | ✅ Auto-restore | If primary fails to parse, tries backup |
| Write conflict prevention | ✅ Sequence numbers | Higher sequence number wins on save |
| Concurrent save prevention | ✅ _saveInProgress flag | Prevents overlapping saves |
| Autosave | ✅ 300ms debounce | Triggers on all mutation operations |
| Undo persistence | ❌ In-memory only | History lost on app restart |
| Encryption | ❌ None | Data stored as plaintext in shared_preferences |
| Cloud sync | ❌ Not implemented | Local-only |

---

## P. What Works on SM-A057F?

Based on the built APK from 2026-07-26 and source code evidence:

1. App launches and shows splash screen
2. Library page renders with empty state
3. Mind creation dialog works
4. Canvas workspace with nodes and connections
5. Node creation, editing, deletion
6. Connection creation and cancellation
7. Undo/redo
8. Quick capture
9. Search (with debounce)
10. Heuristic AI analysis
11. AI proposal cards
12. Theme toggle
13. Settings page navigation
14. Import from share intent (if tested)

---

## Q. What Does NOT Work on SM-A057F?

1. **LLM-powered AI analysis** — Process.start throws on Android
2. **Model download → model load** — Model can be downloaded but not initialized
3. **AIPanel SafeArea** — Overlaps navigation bar
4. **Export file access** — Temp dir export inaccessible to user
5. **Model cancel/delete** — UI stubs
6. **Clear All Data** — UI stub
7. **About page** — No-op tile

---

## R. Recommended Implementation Order

### Immediate (Blockers)
1. **Fix APK build** — Update compileSdk from `flutter.compileSdkVersion` (34) to 36 in `android/app/build.gradle.kts`
2. **Add SafeArea to AIPanel** — Prevent Android nav bar overlap
3. **Fix fitToContent rebuild loop** — Move to initState callback, not build()

### Phase 1 (Critical UX)
4. **Granular BlocSelectors on canvas** — Stop full-state rebuild on every mutation
5. **RepaintBoundary on every node** — Isolate node repaints
6. **Keyboard dismiss on search** — Add submit action
7. **Add export file picker** — Let user choose save location

### Phase 2 (Feature Completion)
8. **Implement model management stubs** — Cancel download, delete model
9. **Implement Clear All Data** — Reset all minds and settings
10. **Implement platform share sheet** — Share .seima files to other apps
11. **Add undo/redo persistence** — Persist stack alongside mind data

### Phase 3 (Mobile LLM)
12. **FFI-based LLM runtime for Android** — Replace Process.start with native binding
13. **On-device inference** — llama.cpp via Dart FFI (jni)

### Phase 4 (Polish)
14. **Per-mind settings** — Rename, change description from workspace
15. **Onboarding flow** — First-launch tutorial
16. **Category filtering UI** — Display and filter by category in library
17. **Accessibility audit** — Full WCAG 2.1 AA compliance
18. **Web target optimization** — Fix manifest, test web build

### Phase 5 (Future)
19. **Export to image/PDF/markdown**
20. **Node resize handles**
21. **Canvas background customization**
22. **Cloud sync**
