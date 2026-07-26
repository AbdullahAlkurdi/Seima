# Performance Audit

## Test Environment
- **Device:** Samsung SM-A057F (Android 15, API 35)
- **GPU:** Mali-G57 (Impeller Vulkan backend)
- **Build:** Debug APK (not profiled/release)
- **Screen:** 720×1600, ~269dpi

## Rendering Pipeline

### Current
```
Flutter (Impeller) → Vulkan → GPU
```
✅ Impeller confirmed active. This provides better frame pacing than Skia on Mali GPUs.

### Canvas Rendering
```
MindPage
└── Stack
    ├── InteractiveViewer (pan/zoom)
    │   └── MindCanvas (CustomMultiChildLayout?)
    │       └── List of Positioned nodes
    │           └── NodeWidget (GestureDetector)
    └── AIPanel (Positioned, conditional)
```

## Confirmed Issues

### 1. Full-State Rebuild on Any Mutation
**Severity: HIGH**

`BlocBuilder<MindCubit, MindState>` at `mind_page.dart:201` rebuilds the entire canvas tree on every state change. MindState includes:
- `mind` (all nodes + connections)
- `selectedNodeIds`
- `selectedConnectionId`
- `connectionSourceNodeId`
- `isLoading`, `isSaving`, `error`
- `canUndo`, `canRedo`

Moving a node 100px → 100 state emissions → 100 full canvas rebuilds.

**Fix:** Split MindState into granular selectors. Use `BlocSelector` for individual fields (selected IDs, connection mode). Extract node positions to a `ValueNotifier` map that avoids MindCubit during drag.

### 2. No RepaintBoundary on Node Widgets
**Severity: MEDIUM**

All node widgets are direct children of the `Stack` inside `InteractiveViewer`. Without `RepaintBoundary`, changing any single node's state (content, selection, type) repaints ALL nodes.

**Fix:** Wrap each node widget in `RepaintBoundary`.

### 3. No Layer Optimization
**Severity: LOW-MEDIUM**

`InteractiveViewer` uses a `Stack` as its child. The `Stack` composited all children into one layer. With 50+ nodes, this creates a single large display list that must be re-uploaded to the GPU on any change.

**Fix:** Use `RepaintBoundary` + `children: nodes.map((n) => RepaintBoundary(child: NodeWidget(n)))`.

### 4. AI Panel Constrains Visible Canvas
**Severity: LOW**

`AIPanel` takes `height: 85%` of screen when open. The canvas is still rendered behind it but is invisible. This is wasted GPU work.

**Fix:** Reduce canvas rebuild area or clip when AI panel is open.

## Other Observations

### 5. Auto-Save Debounce
✅ 300ms debounce timer on auto-save. Tested in Phase 4 — no race conditions. `_saveInProgress` guard prevents overlapping saves.

### 6. Viewport Culling
✅ Nodes outside `_computeVisibleRect()` return `SizedBox.shrink()` in their build. This reduces widget count for off-screen nodes but doesn't prevent the parent `Stack` from laying them out.

### 7. Import/Export
✅ JSON-based, validated connections. No I/O blocking on main thread (SharedPreferences is async but fast).

### 8. Undo/Redo
In-memory stack of Mind snapshots (50 cap). No serialization during undo — fast.

## Frame Timing (Estimated, Debug Mode)

| Operation | Frame Time | Notes |
|---|---|---|
| Static canvas (empty) | < 2ms | Negligible |
| Static canvas (20 nodes) | ~8ms | Acceptable (~120fps) |
| Drag node (20 nodes) | ~12-16ms | Full rebuild per frame (need optimization) |
| Drag node (100 nodes) | ~25-35ms | Likely janky (< 30fps) |
| AI panel open (20 nodes) | ~10ms | Canvas still rendered behind panel |
| Search (20 minds, 100 nodes) | < 5ms | SharedPreferences I/O is fast |

## Memory Profile (Estimated)

| Scenario | RAM | Notes |
|---|---|---|
| Cold start | ~80MB | Flutter engine + framework |
| Canvas (50 nodes) | ~120MB | Node data + widget tree |
| Canvas (200 nodes) | ~200MB | Estimated |
| AI panel + streaming | ~130MB | Heuristic analysis is lightweight |

## Recommendations (Prioritized)

### Must Fix (Before Phase C)
1. **Wrap nodes in `RepaintBoundary`** — Immediate improvement, minimal code change
2. **Split BlocBuilder into granular selectors** — Prevents unnecessary rebuilds

### Should Fix (Phase C)
3. **Extract drag positions to `ValueNotifier`** — 60fps drag without full state emissions
4. **Profile with `flutter run --profile`** — Establish baseline frame timing

### Nice to Have
5. **Clip canvas when AI panel is open** — Reduce GPU load
6. **Node virtualization** — Only build widgets for nodes in visible viewport + margin
7. **Canvas layer caching** — Cache connection painter output when no mutations occur
8. **Memory limit warning** — Alert when node count exceeds recommended threshold
