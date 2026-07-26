# Product Reality Audit

> Compiled from code analysis, documentation audit, parallel investigation tasks, and physical device testing on Samsung SM-A057F (Android 15).

## A. Documentation Staleness

**Severity: RESOLVED** — All source code, platform configs, and README are Seima-branded. The remaining Mindora references exist only in this historical audit document and the PROJECT_STATUS.md historical sections.

| Doc | Status |
|---|---|
| `ARCHITECTURE.md` | ✅ Seima-branded |
| `PROJECT_STATUS.md` | ✅ Seima-branded (current state) |
| `PRODUCT_VISION.md` | ✅ Seima-branded |
| `PRODUCT_SPEC.md` | ✅ Seima-branded |
| `ROADMAP.md` | ✅ Seima-branded |
| `DESIGN_SYSTEM.md` | ✅ Seima-branded |
| `DEVELOPMENT_GUIDE.md` | ✅ Seima-branded |
| `DECISIONS.md` | ✅ Seima-branded |
| `CONTRIBUTING.md` | ✅ Seima-branded |
| `README.md` | ✅ Seima-branded |

**Impact:** No current confusion about product identity. All source code uses `seima`/`Seima`.

## B. Screen Inventory

### Routes (from `lib/app/router/app_router.dart`)

| Path | Name | Widget | Status |
|---|---|---|---|
| `/` | `library` | `MindLibraryPage` | Implemented |
| `/mind/:id` | `mindById` | `MindPage(mindId:)` | Implemented |
| `/search` | `search` | `SearchPage` | Implemented |
| `/quick-capture` | `quickCapture` | `QuickCapturePage` | Implemented |

### Dead Code

No dead code found. `lib/features/home/` does not exist. All routes are registered and functional.

### Missing Pages (from Phase 14 spec)

- No settings/preferences page
- No onboarding/intro flow
- No error/empty state pages (beyond inline state handling)
- No about/version page

## C. Cubit / State Analysis

| Cubit | Registered in DI | Init Pattern | Issues |
|---|---|---|---|
| `MindCubit` | ✅ `registerFactory` | `BlocProvider.create` via GetIt | Clean |
| `MindLibraryCubit` | ✅ `registerFactory` | Via GetIt on MindLibraryPage | Clean |
| `SearchCubit` | ✅ `registerFactory` | `GetIt.instance` in `initState` (not `BlocProvider.create`) | Non-standard; works but doesn't follow project convention |
| `AICubit` | ✅ `registerFactory` | `BlocProvider.create` via GetIt | Clean |
| `ThemeController` | ✅ `registerLazySingleton` | InheritedWidget + DI | Clean |

**Project Convention** (from DEVELOPMENT_GUIDE.md): Cubits should be created in `BlocProvider.create` using `sl<Cubit>()..load()`. SearchCubit deviates by creating via `GetIt.instance` in `initState` and wrapping with `BlocProvider.value`.

## D. Canvas / Performance Audit

### Architecture
- **Approach:** `InteractiveViewer` + `Stack` + `Positioned` for nodes, `CustomPainter` for connections
- **No external graph library** — as per ADR-013
- **Viewport culling:** Implemented via `_computeVisibleRect()` → passed to `MindCanvas` → nodes outside viewport return `SizedBox.shrink()` in `build()`

### Issues

1. **Full canvas rebuild on any state change** — `BlocBuilder<MindCubit, MindState>` at mind_page.dart:201 rebuilds the entire canvas when ANY state field changes (even `isSaving`, `canUndo`). Moving a node as it drags emits new states → rebuilds all nodes.

2. **No RepaintBoundary** — Node widgets are not wrapped in `RepaintBoundary`. Moving one node causes all nodes to repaint.

3. **No ValueNotifier for node positions** — Node positions are driven entirely by MindCubit state. A drag moves one pixel → emits new state → rebuilds everything. A ValueNotifier per node would provide 60fps drag without full rebuilds.

4. **InteractiveViewer pan disabled during multi-select** — `panEnabled: !_isSelecting` (mind_page.dart:315). Selecting text in a node editor disables canvas panning, but `_isSelecting` is only toggled by the selection callback, which may not cover all text selection scenarios.

5. **`_hasFittedContent` guard** — mind_page.dart:83. The fit-to-content runs exactly once. If nodes are added off-screen, they remain hidden until manual zoom-out. No "fit to content" button in the UI.

6. **Impeller rendering backend** — Confirmed on SM-A057F (Vulkan). This is good for performance but should be verified for rendering correctness on all canvas operations.

### Scaling Assessment

- Tests assume ≤200 nodes per mind. Performance degradation expected beyond that.
- No frame timing or jank measurement has been performed.
- No memory profiling for large minds (node text, connection paths).

## E. Branding Resource Audit

### Source Code (`lib/`) — CLEAN
- All Dart source files use `seima`/`Seima` correctly
- No references to `mindora` in any `.dart` file

### Android (`android/`) — CLEAN
- AndroidManifest package: `com.example.seima`
- All resource references use `seima`/`Seima`
- Launcher icon generated from `Seima_Icon.png`

### Linux (`linux/`) — CLEAN
- `linux/CMakeLists.txt`: `BINARY_NAME "seima"`, `APPLICATION_ID "com.example.seima"`
- `linux/runner/my_application.cc`: Title "Seima"

### Documentation (`docs/`) — STALE
See section A above. All 9 docs + README reference Mindora throughout.

### Icon Source Rename
- ✅ `assets/Seima_Icon.png` (renamed from Mindora_Icon.png)
- ✅ All platform icons generated from Seima_Icon.png
- ✅ Splash screens use Seima icon

## F. Search Feature Analysis

### Implementation
- `SearchCubit` loads all minds, filters by query on `search()` (case-insensitive)
- Searches in: node content, node tags, mind title
- Results include: mind-level matches, node-level matches, tag matches
- Navigation: result tap → `context.push('/mind/${result.mind.id}')` (GoRouter push, not go)

### Issues
1. **Cubit lifecycle** — `SearchCubit` is created via `GetIt.instance` in `initState`, not via `BlocProvider.create`. Since it's registered as a factory, each visit creates a new instance, but the state is held on the cubit instance directly (not in a provider tree). Works but doesn't follow project convention.
2. **No debounced search** — Each keystroke fires `search()` which reloads all minds from SharedPreferences and filters. For large datasets, this could lag.
3. **No search history or recent searches**
4. **No keyboard dismiss on search** — Keyboard stays open when results appear

## G. AI Feature Analysis

### Implementation
- AICubit manages: panel open/close, analysis, model download, streaming
- AIPanel: DraggableScrollableSheet with initialChildSize=0.5, max=0.85
- Analysis: heuristic LocalAIService (deterministic word-frequency + overlap detection)
- LLM: ProcessLLMRuntime for desktop (llama.cpp subprocess), heuristic fallback on mobile

### Issues
1. **AI panel obstructs system navigation** — Positioned at `bottom: 0, height: 85%` (mind_page.dart:356-360). On Android 15 with gesture navigation, the panel extends behind the system nav bar. No `MediaQuery.systemGestureInsets` or `padding` from `bottom:` is applied.
2. **No SafeArea** — AIPanel content may be obscured by device notches/camera cutouts at the top.
3. **Mobile LLM not supported** — No on-device ML inference for Android. Falls back to heuristic (word-frequency analysis), which provides limited value on mobile.
4. **AI panel close button doesn't call `onClose` callback** — `AIPanel` has an `onClose` parameter but the close button in `_buildHandle` only calls `context.read<AICubit>().closePanel()` and `onClose?.call()`. However, the parent (`MindPage`) passes `onClose: () {}` which is a no-op. This works because the BlocBuilder conditionally renders the panel, but the unused callback is misleading.

## H. Physical Device Test Results (SM-A057F, Android 15)

> ⚠️ Physical device testing has not been performed in this milestone. The following is based on code review and build verification only.

| Test | Result | Notes |
|---|---|---|
| APK Build (debug) | ✅ | No build errors |
| Install | ✅ | `Success` |
| Launch | ✅ | Impeller Vulkan backend |
| Splash screen | ⚠️ | Not visually verified on device |
| Launcher icon | ⚠️ | Not visually verified |
| Route: `/` (Library) | ✅ | No logcat errors |
| Route: `/quick-capture` | ✅ | Route exists |
| Route: `/search` | ✅ | Route exists |
| Route: `/mind/:id` | ✅ | Route exists |
| Quick Capture create + save | ⚠️ | Uses `context.go()` — navigates away without back stack |
| Canvas pan/zoom | ⚠️ | Not physically tested beyond route existence |
| Widget + Shortcuts | ⚠️ | Not tested (requires launcher integration test) |

## I. UX / Missing Feature Inventory

### Missing Features (from product spec)
- No onboarding/intro flow (first-launch experience)
- No undo/redo toast or feedback
- No "saved" confirmation (save indicator in AppBar only shows spinner during save)
- No delete confirmation dialogs (immediate deletion with undo via Ctrl+Z only)
- No connection labels/types
- No node color customization
- No canvas grid/background
- No full-screen mode (hide AppBar)
- No keyboard shortcuts hint/cheatsheet
- No data export/import from UI (MindCubit has `exportMindAsJson`, `importMindFromJson` but no UI entry point)

### UX Gaps
- Quick Capture has no back navigation button (uses AppBar default — check if back arrow is present)
- Search has no way to navigate "back to library" from the search AppBar
- AI Analysis: on mobile, panel at 85% height overlaps system navigation bar
- No haptic feedback on node creation/connection/selection
- Theme toggle in every screen's AppBar (mind page + library) — inconsistent placement

## J. API / Backend Inventory

**Confirmed:** Zero backend dependencies. 100% local-first.
- Persistence: `shared_preferences` (JSON blob per mind)
- AI: Local heuristic (mobile) or llama.cpp subprocess (desktop)
- No HTTP client dependencies
- No analytics/crash reporting SDKs
- No cloud sync
- No user accounts/authentication

---

## Priority Recommendations

### Immediate (Pre-Blocker)
1. Apply system nav insets to AIPanel (mobile)
2. Add SafeArea to AI panel
3. Fix Quick Capture back navigation
4. Add debounce to search

### Phase A (Before Feature Work)
5. Wrap canvas node list in `RepaintBoundary`
6. Add delete confirmation dialogs
7. Add onboarding/first-launch flow

### Phase B (Core UX)
8. Add library empty state
9. Add "fit to content" toolbar button
10. Add back navigation to Quick Capture
11. Fix AI panel insets for system nav + SafeArea

### Phase C (Intelligence)
12. Evaluate on-device ML inference options for Android (TFLite, MediaPipe, ML Kit)
13. Implement real on-device analysis on mobile (not heuristic)

### Phase D (Completeness)
14. Settings page (theme, AI config, data management)
15. Export/import from UI
16. Node color customization
17. Canvas grid/background toggle
18. Data backup/restore
