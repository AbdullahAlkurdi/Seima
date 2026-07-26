# Product Reality Matrix — Seima

## Legend
| Icon | Meaning |
|------|---------|
| ✅ | Complete — works as expected |
| ⚠️ | Partial — works but has issues |
| ❌ | Missing / Broken |
| 🔲 | Not implemented |
| 📱 | Device verified on SM-A057F |
| 🧪 | Has automated tests |

---

## Core Experience

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Branding / Identity | ✅ | ✅ | ✅ | ❌ | 📱 | Seima across all platforms, custom icons |
| Splash / Startup | ✅ | ✅ | ✅ | ✅🧪 | 📱 | Animated 1.2s splash with logo |
| Launcher Icon | ✅ | ✅ | ✅ | ❌ | 📱 | Custom adaptive icons all platforms |
| Home / Library | ✅ | ✅ | ✅ | ✅🧪 | 📱 | Full CRUD, empty/error/loading states |
| Create Mind | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Dialog with name + category |
| Mind Categories | ⚠️ | ⚠️ | ❌ | ❌ | ❌ | Domain model has category; no UI for it |
| Quick Capture | ✅ | ✅ | ✅ | ❌ | ❌ | Text input + mind selector + save |

## Mind Workspace

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Canvas (infinite) | ✅ | ✅ | ✅ | ✅🧪 | 📱 | InteractiveViewer pan/zoom |
| Create Node | ✅ | ✅ | ✅ | ✅🧪 | ❌ | FAB creates at grid position |
| Node Types | ✅ | ✅ | ✅ | ✅🧪 | ❌ | text/task/question/idea |
| Node Editor | ✅ | ✅ | ✅ | ❌ | ❌ | Type, content, tags |
| Node Drag | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Pan gesture + undo grouping |
| Delete Node | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Removes connections too |
| Connection Create | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Start/complete/cancel flow |
| Connection Cancel | ✅ | ✅ | ✅ | ✅🧪 | ❌ | FAB + AppBar badge + overlay |
| Bezier Connections | ✅ | ✅ | ✅ | ❌ | ❌ | Curved with arrowheads |
| Connection Selection | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Orange highlight |
| Zoom / Pan | ✅ | ✅ | ✅ | ❌ | ❌ | 0.1x–4x scale |
| Fit-to-Content | ✅ | ✅ | ⚠️ | ❌ | ❌ | `_hasFittedContent` fires on every rebuild |
| Selection (single) | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Tap to select |
| Multi-Selection | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Shift+drag, Ctrl+click |
| Selection Rectangle | ✅ | ✅ | ✅ | ❌ | ❌ | Shift+drag rectangular selection |
| Viewport Culling | ✅ | ✅ | ✅ | ❌ | ❌ | Only renders visible nodes |
| Undo / Redo | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Ctrl+Z/Y, app bar, 50 max, drag grouping |
| Undo Persistence | ❌ | ❌ | 🔲 | ❌ | ❌ | In-memory only |
| Keyboard Shortcuts | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Ctrl+Z/Y/A, Del, Esc, Bksp |
| Canvas Empty State | ✅ | ✅ | ✅ | ❌ | ❌ | "No nodes yet" + hint |

## Mind Library

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| List Minds | ✅ | ✅ | ✅ | ✅🧪 | 📱 | Sorted by lastAccessedAt desc |
| Create Mind | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Dialog + auto-navigate |
| Rename Mind | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Inline dialog |
| Delete Mind | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Confirmation dialog |
| Duplicate Mind | ✅ | ✅ | ✅ | ✅🧪 | ❌ | "(Copy)" suffix, new IDs |
| Library Empty State | ✅ | ✅ | ✅ | ❌ | ❌ | "Welcome to Seima" |
| Library Error State | ✅ | ✅ | ✅ | ❌ | ❌ | Error icon + retry |
| Pull-to-Refresh | ✅ | ✅ | ✅ | ❌ | ❌ | RefreshIndicator |
| Category Filter | ❌ | ❌ | 🔲 | ❌ | ❌ | No category UI |

## Search

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Mind Search | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Matches title, node content, tags |
| Debounce (300ms) | ✅ | ✅ | ✅ | ❌ | ❌ | Timer-based |
| Results List | ✅ | ✅ | ✅ | ✅🧪 | ❌ | With source mind + tags |
| Navigate to Result | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Goes to mind workspace |
| Clear Search | ✅ | ✅ | ✅ | ❌ | ❌ | Clear button |
| Empty States | ✅ | ✅ | ✅ | ❌ | ❌ | Initial + no results |
| Error State | ✅ | ✅ | ✅ | ❌ | ❌ | Error + retry |
| Keyboard Dismiss | ❌ | ❌ | 🔲 | ❌ | ❌ | No keyboard dismiss on search |
| Search History | ❌ | ❌ | 🔲 | ❌ | ❌ | No recent searches |

## AI / LLM

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| AIService interface | ✅ | N/A | ✅ | ❌ | ❌ | Abstract class |
| LocalAIService (heuristic) | ✅ | ✅ | ✅ | ✅🧪 | ✅ | Works on all platforms |
| LLMAIService | ✅ | ⚠️ | ⚠️ | ✅🧪 | ❌ | Desktop-only (subprocess) |
| ProcessLLMRuntime | ✅ | ⚠️ | ❌📱 | ✅🧪 | ❌ | Cannot run on Android |
| Model Manager | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Download from HF |
| Model Download | ✅ | ✅ | ✅ | ❌ | ❌ | Progress callback, validation |
| Model Cancel | ❌ | ❌ | 🔲 | ❌ | ❌ | Stub "not implemented" |
| Model Delete | ❌ | ❌ | 🔲 | ❌ | ❌ | Stub "not implemented" |
| AI Analysis Page | ✅ | ✅ | ✅ | ❌ | ❌ | Full UI with all states |
| AI Proposals | ✅ | ✅ | ✅ | ✅🧪 | ❌ | NewNode + Connection proposals |
| Proposal Apply | ✅ | ✅ | ✅ | ❌ | ❌ | Batch undo for proposals |
| AI Streaming | ✅ | ⚠️ | ⚠️ | ✅🧪 | ❌ | Desktop LLM, else falls back |
| AI Safety Limits | ⚠️ | ⚠️ | ⚠️ | ❌ | ❌ | Content/tag length limits only |

## Settings

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Settings Page | ✅ | ✅ | ✅ | ❌ | ❌ | Theme + AI + Export + About |
| Theme Toggle | ✅ | ✅ | ✅ | ❌ | ❌ | Light/Dark/System toggle |
| AI Model Management | ✅ | ✅ | ✅ | ❌ | ❌ | Status + download/stubs |
| Export / Import Page | ✅ | ✅ | ✅ | ❌ | ❌ | Navigation hub only |
| Clear All Data | ❌ | ✅ | ❌ | ❌ | ❌ | Stub "not implemented" |
| About Seima | ❌ | ✅ | ❌ | ❌ | ❌ | Stub — no-op on tap |
| Mind Settings | ❌ | ❌ | 🔲 | ❌ | ❌ | No per-mind settings |

## Import / Export / Sharing

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| SeimaKnowledgePackage | ✅ | N/A | ✅ | ✅🧪 | ❌ | Canonical format |
| Export to .seima | ✅ | ✅ | ⚠️ | ❌ | ❌ | Temp dir only, no user location |
| Export to Clipboard | ✅ | ✅ | ✅ | ❌ | ❌ | JSON to clipboard |
| Export to Text | ✅ | ✅ | ✅ | ❌ | ❌ | Plain text preview |
| Export Page UI | ✅ | ✅ | ⚠️ | ❌ | ❌ | Fragile dynamic cast |
| Import .seima file | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Full validation pipeline |
| Import plain text | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Each line = node |
| Import clipboard | ✅ | ✅ | ✅ | ❌ | ❌ | Reads clipboard |
| Import preview | ✅ | ✅ | ✅ | ❌ | ❌ | Summary + warnings + errors |
| Import as New Mind | ✅ | ✅ | ✅ | ❌ | ❌ | Creates new mind |
| Import Merge | ✅ | ✅ | ✅ | ❌ | ❌ | Merges into existing mind |
| External Share → Seima | ✅ | ✅ | ✅ | ❌ | ❌ | Intent filter + MethodChannel |
| Seima → External Share | ❌ | ❌ | 🔲 | ❌ | ❌ | No platform share sheet |
| File save dialog | ❌ | ❌ | 🔲 | ❌ | ❌ | Exports to temp dir only |

## Home Screen Widget

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Widget Provider (Kotlin) | ✅ | ✅ | ✅ | ❌ | ❌ | SeimaWidgetProvider |
| Widget Layout XML | ✅ | ✅ | ✅ | ❌ | ❌ | Two buttons |
| Widget Info XML | ✅ | ✅ | ✅ | ❌ | ❌ | Update interval |
| Widget Action Handler | ✅ | ✅ | ✅ | ❌ | ❌ | Dart MethodChannel |
| "New Thought" Action | ✅ | ✅ | ✅ | ❌ | ❌ | Routes to /quick-capture |
| "Open Seima" Action | ✅ | ✅ | ✅ | ❌ | ❌ | Routes to / |

## Persistence / Data

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Save/Load Minds | ✅ | ✅ | ✅ | ✅🧪 | ❌ | shared_preferences |
| Backup-on-Write | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Backup before overwrite |
| Corruption Recovery | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Auto-restore from backup |
| Schema Versioning | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Version 1 |
| Sequence Numbers | ✅ | ✅ | ✅ | ✅🧪 | ❌ | Write conflict prevention |
| Autosave (300ms) | ✅ | ✅ | ✅ | ❌ | ❌ | Debounced timer |
| Concurrent Save Guard | ✅ | ✅ | ✅ | ❌ | ❌ | _saveInProgress flag |
| Undo Persistence | ❌ | ❌ | 🔲 | ❌ | ❌ | In-memory only |

## UI / UX

| Feature | Code | Reachable | Functional | Tested | Device | Notes |
|---------|------|-----------|------------|--------|--------|-------|
| Loading States | ✅ | ✅ | ✅ | ✅🧪 | ❌ | 3 variants |
| Empty States | ✅ | ✅ | ✅ | ❌ | ❌ | All screens |
| Error States | ✅ | ✅ | ✅ | ❌ | ❌ | All screens with retry |
| Accessibility | ⚠️ | ⚠️ | ⚠️ | ❌ | ❌ | Basic Semantics only |
| Light Theme | ✅ | ✅ | ✅ | ❌ | ❌ | Material 3 from seed |
| Dark Theme | ✅ | ✅ | ✅ | ❌ | ❌ | Material 3 from seed |
| Material 3 | ✅ | ✅ | ✅ | ❌ | ❌ | useMaterial3: true |

## Known Broken/Missing Items (from previous reports)

| Issue | Status | Current Evidence |
|-------|--------|-----------------|
| Black/empty screens | ✅ FIXED | Canvas renders correctly |
| Crashes | ❓ UNVERIFIED | Build fails, can't test |
| Severe lag | ⚠️ PARTIAL | Viewport culling ON; full rebuild OFF |
| Cropped splash | ✅ FIXED | Commit 57f07ca |
| Wrong launcher icon | ✅ FIXED | Commit 993df56 |
| AI nav bar overlap | ❌ STILL BROKEN | No SafeArea on AIPanel |
| Small canvas controls | ❌ STILL BROKEN | No mobile-optimized controls |
| Connection cancel during zoom | ✅ FIXED | Dedicated cancel mechanism |
| Search not working | ✅ FIXED | Full search implementation |
| Missing settings | ✅ FIXED | Settings page exists |
| Missing import/export | ✅ FIXED | Full pipeline exists |
| Missing model management | ⚠️ PARTIAL | UI exists; cancel/delete are stubs |
| Missing loading states | ✅ FIXED | All pages have loading |
| Missing empty/error states | ✅ FIXED | All pages have empty/error |

## Totals

| Category | Total | ✅ Complete | ⚠️ Partial | ❌ Missing/Broken |
|----------|-------|-----------|------------|------------------|
| Core Experience | 7 | 6 | 1 | 0 |
| Mind Workspace | 17 | 14 | 2 | 1 |
| Mind Library | 9 | 7 | 0 | 2 |
| Search | 8 | 6 | 0 | 2 |
| AI / LLM | 13 | 5 | 5 | 3 |
| Settings | 7 | 3 | 0 | 4 |
| Import/Export/Sharing | 14 | 9 | 1 | 4 |
| Home Screen Widget | 6 | 6 | 0 | 0 |
| Persistence / Data | 8 | 7 | 0 | 1 |
| UI / UX | 7 | 6 | 1 | 0 |
| **Grand Total** | **96** | **69** | **10** | **17** |
