# Next Execution Plan — Seima

**Based on the FULL_PROJECT_AUDIT, PRODUCT_REALITY_MATRIX, and IMPLEMENTATION_GAP_ANALYSIS.**

---

## Priority: BLOCKER

### 1. Fix Android APK Build
**Problem:** `flutter build apk --debug` fails: `file_picker` requires compileSdk 36, but project uses `flutter.compileSdkVersion` (currently 34).

**Files:**
- `android/app/build.gradle.kts` — Line: `compileSdk = flutter.compileSdkVersion`

**Fix:** Set `compileSdk = 36` explicitly. Also update Kotlin Gradle Plugin warning for `share_plus`.

**Why first:** Cannot test anything on device without this fix.

### 2. Add SafeArea to AIPanel
**Problem:** `AIPanel` uses `DraggableScrollableSheet` without SafeArea, causing content to overlap the Android system navigation bar.

**Files:**
- `lib/features/ai/presentation/widgets/ai_panel.dart` — The DraggableScrollableSheet builder returns a Container that should be wrapped in SafeArea.

**Fix:** Wrap the Container or Column in `SafeArea(child: ...)`.

### 3. Fix fitToContent Rebuild Loop
**Problem:** `_fitToContent` is called via `addPostFrameCallback` inside `build()` method, which schedules a callback every time the widget rebuilds. This triggers unnecessary matrix computations.

**Files:**
- `lib/features/mind/presentation/pages/mind_page.dart` — Lines 199-201 in `_MindBodyState.build()`

**Fix:** Move the fit-to-content logic to `initState()` with a post-frame callback, or use a flag in `didChangeDependencies()`.

---

## Priority: CRITICAL

### 4. Granular Canvas Rebuilds
**Problem:** The entire canvas rebuilds on any state change because `BlocBuilder<MindCubit, MindState>` in `_MindBody.build()` wraps the entire canvas. With 50+ nodes, this causes severe lag.

**Files:**
- `lib/features/mind/presentation/pages/mind_page.dart` — Lines 141-204
- `lib/features/mind/presentation/widgets/mind_canvas.dart` — Whole widget rebuilds

**Fix:** Use `BlocSelector` to split canvas into: (a) node positions (for drag), (b) node content (for edits), (c) selection state, (d) connection state. Each selector rebuilds only the affected child.

### 5. RepaintBoundary for Every Node
**Problem:** Canvas nodes are not individually isolated for repainting. Moving one node causes all nodes to repaint.

**Files:**
- `lib/features/mind/presentation/widgets/mind_canvas.dart` — Lines 176-200

**Fix:** Each `CanvasNodeWidget` is already wrapped in `RepaintBoundary`. Verify this is working (it appears to be). Add `RepaintBoundary` around `CustomPaint` for connections too.

### 6. Keyboard Dismiss on Search
**Problem:** After searching, the keyboard remains visible. No "done" action or tap-to-dismiss.

**Files:**
- `lib/features/mind/presentation/pages/search_page.dart` — The TextField in AppBar

**Fix:** Add `textInputAction: TextInputAction.search` and `onSubmitted` callback to the search TextField. Also add a `GestureDetector` on the body to dismiss keyboard on tap.

---

## Priority: HIGH

### 7. Export File Location
**Problem:** Export saves to `Directory.systemTemp` which is not accessible to users on mobile devices.

**Files:**
- `lib/features/sharing/presentation/pages/export_page.dart` — Lines 23-28
- `lib/features/sharing/data/export_service.dart` — `exportToFile()` method

**Fix:** Integrate `file_picker` to let user choose save location, or use platform-specific public directories (e.g., `Downloads` folder via `path_provider`).

### 8. Model Management Stubs
**Problem:** "Cancel Download", "Remove Model", and "Clear All Data" show snackbars "not yet implemented".

**Files:**
- `lib/features/settings/presentation/pages/ai_model_management_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

**Fix:** Implement actual functionality:
- Cancel download: Abort the HTTP request in ModelManager
- Remove model: Call `modelManager.deleteModel()`
- Clear All Data: Clear shared_preferences and reset

### 9. ExportPage Dynamic Cast
**Problem:** `ExportPage` uses `BlocBuilder<MindLibraryCubit, dynamic>` and casts `state` with `state is List<Mind>` and `state.minds`. This is fragile and will crash if MindLibraryState changes.

**Files:**
- `lib/features/sharing/presentation/pages/export_page.dart` — Lines 106-110

**Fix:** Use `BlocBuilder<MindLibraryCubit, MindLibraryState>` and properly typed `state.minds`.

### 10. Platform Share Sheet
**Problem:** Export page saves to file but does not invoke the platform share sheet. Users cannot share minds to other apps.

**Files:**
- `lib/features/sharing/presentation/pages/export_page.dart`

**Fix:** Use `share_plus` to share the exported .seima file via the platform share sheet. Add a "Share" option alongside "Save".

---

## Priority: MEDIUM

### 11. Undo/Redo Persistence
**Problem:** Undo/redo history is in-memory only. Restarting the app loses all undo history.

**Files:**
- `lib/features/mind/presentation/cubit/mind_state.dart` — undoHistory/redoHistory lists
- `lib/features/mind/data/mind_repository.dart`

**Fix:** Serialize undo/redo stacks alongside Mind data. Save latest N undo states. Load on startup.

### 12. Onboarding Flow
**Problem:** New users see an empty library with no guidance about what Seima does.

**Files:**
- New: `lib/features/onboarding/` (new feature)

**Fix:** Create a 3-4 page onboarding carousel shown on first launch. Check flag in shared_preferences.

### 13. Per-Mind Settings
**Problem:** No way to rename a mind from within the workspace. Must navigate back to library.

**Files:**
- `lib/features/mind/presentation/pages/mind_page.dart`

**Fix:** Add a "Rename" action to the mind workspace AppBar (e.g., in the popup menu or as a tap-to-edit title).

### 14. Category Display in Library
**Problem:** Category is stored on Mind model and accepted during creation, but never displayed or filterable.

**Files:**
- `lib/features/mind/presentation/pages/mind_library_page.dart` — MindCard widget

**Fix:** Display category chip on mind cards if present. Add category filter dropdown at top of library.

---

## Priority: LOW

### 15. Mobile LLM (FFI)
**Problem:** LLM analysis is desktop-only via Process.start. Mobile devices get only heuristic (LocalAIService).

**Fix:** Create `MobileLLMRuntime` that uses Dart FFI to call llama.cpp compiled for Android arm64. Integrate with `dart:ffi` and `jni` plugin (already listed in GeneratedPluginRegistrant).

### 16. Export to Image/PDF/Markdown
**Problem:** Only .seima and text formats supported. No standard export formats.

**Fix:** Add ExportService methods for: `exportToMarkdown()`, `exportToImage()` (using RepaintBoundary render), `exportToPdf()` (using pdf package).

### 17. Web Target Polish
**Problem:** `web/manifest.json` describes the app as "A new Flutter project." with #0175C2 theme color.

**Fix:** Update manifest.json with proper Seima description and theme color #3D5A80.

### 18. Clear All Data Implementation
**Problem:** The "Clear All Data" button shows a snackbar "not yet implemented".

**Fix:** Clear SharedPreferences data via MindRepository, reset all cubits.

### 19. About Seima Page
**Problem:** Settings "About Seima" tile is a no-op.

**Fix:** Create a simple about page showing version, credits, and build info.

---

## Summary: Immediate Sprint (Next 3-5 Working Items)

```
Sprint 1 — Fix Blocker + Critical UX Issues

[1] Fix APK build (compileSdk 36)         → ~15 min
[2] Add SafeArea to AIPanel               → ~5 min
[3] Fix fitToContent rebuild loop         → ~10 min
[4] Keyboard dismiss on search            → ~10 min
[5] Granular canvas rebuilds (BlocSelector) → ~2-3 hours
[6] RepaintBoundary verification          → ~15 min
[7] Verify: flutter analyze, flutter test, flutter build apk
```

**Total time:** ~4 hours to resolve all blocker + critical issues.

---

## Verification Checklist (Post-Fix)

- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — 337+ tests pass
- [ ] `flutter build apk --debug` — succeeds
- [ ] Install on SM-A057F
- [ ] App launches without crash
- [ ] All 13 routes are reachable
- [ ] Library renders, create/rename/delete/duplicate mind
- [ ] Canvas renders, create/edit/delete/drag nodes
- [ ] Connections create/cancel/select/delete
- [ ] Undo/redo works for all operations
- [ ] Search works with debounce
- [ ] Quick capture saves to selected mind
- [ ] AI analysis (heuristic) returns results
- [ ] AI panel does not overlap nav bar
- [ ] Export/copy to clipboard works
- [ ] Import from clipboard works
- [ ] Theme toggle persists
- [ ] Home screen widget installs and works
- [ ] Share content into Seima works
