# Screen Architecture — Target Navigation Design

## Current vs Target

### Current Routes

```
/                  → MindLibraryPage
/mind/:id          → MindPage(mindId:)
/search            → SearchPage
/quick-capture     → QuickCapturePage
```

### Current Problems
- No home/shell structure — every route is a standalone page
- Quick Capture has no back navigation to parent mind
- Search has no "back to library" affordance in AppBar
- `HomePage` exists but is dead code (not in router)
- No support for modal routes, dialogs, or bottom sheets in the routing layer
- No nested navigation (e.g., library → mind with in-page sub-routes)

---

## Target Navigation Architecture

### Shell-Based Layout

```
ShellRoute (with BottomNavigationBar or drawer)
├── /                   → HomePage (dashboard + library)
├── /search             → SearchPage
├── /settings           → SettingsPage
└── /quick-capture      → QuickCapturePage
/mind/:id               → MindPage (full-screen, no shell)
/library                → MindLibraryPage (alternative entry)
```

### Page Breakdown

| Route | Widget | Type | Shell? | Notes |
|---|---|---|---|---|
| `/` | `HomePage` | Shell child | Yes | Dashboard: recent minds, quick actions, "new mind" CTA |
| `/search` | `SearchPage` | Shell child | Yes | Global search across all minds |
| `/settings` | `SettingsPage` | Shell child | Yes | Theme, AI config, data, about |
| `/quick-capture` | `QuickCapturePage` | Shell child | Yes | Auto-focus text field, mind selector, save |
| `/mind/:id` | `MindPage` | Full-screen | No | Canvas, hides shell navigation |
| `/mind/:id/node/:nodeId` | `NodeDetailPage` | Full-screen | No | Deep-link to specific node in a mind |
| `/onboarding` | `OnboardingPage` | Modal/full-screen | No | First-launch experience, no back navigation |

### Navigation Patterns

| Action | Navigation | Type |
|---|---|---|
| Tap mind in library | `context.go('/mind/${id}')` | Push (replaces shell) |
| Back from mind to library | `context.go('/')` | Pop to shell root |
| Tap search result | `context.push('/mind/${id}')` | Push (adds to stack on top of shell) |
| Save quick capture | `context.go('/mind/${updated.id}')` | Replace with mind page |
| Cancel quick capture | `context.pop()` | Pop back to shell root |
| Theme/AI config | `context.push('/settings')` | Push within shell |
| First launch | `context.go('/onboarding')` | Replace all (no back) |

### Deep Link Support

```
seima://mind/{id}
seima://mind/{id}/node/{nodeId}
seima://search?q={query}
seima://quick-capture?text={text}
```

---

## Cubit Wiring per Route

| Route | Cubits | Init Pattern |
|---|---|---|
| `/` | `HomeCubit` | `BlocProvider(create: (_) => sl<HomeCubit>()..load())` |
| `/search` | `SearchCubit` | `BlocProvider(create: (_) => sl<SearchCubit>()..load())` |
| `/settings` | None (simple scaffold) | — |
| `/quick-capture` | None | Direct `MindRepository` via GetIt (no cubit needed) |
| `/mind/:id` | `MindCubit` + `AICubit` | `MultiBlocProvider` pattern |

---

## Route Transition Strategy

| From → To | Animation | Logic |
|---|---|---|
| Shell → Mind | Slide left (push) | Library slides out, mind canvas slides in |
| Mind → Shell | Slide right (pop) | Reverse animation |
| Quick Capture → Mind | Fade through (replace) | Keyboard closes, canvas appears |
| Any → Onboarding | Fade (replace all) | Smooth transition, no back possible |

---

## Route Guard Requirements

- `/onboarding` — Only shown on first launch (`SharedPreferences` flag)
- `/mind/:id` — Redirect to `/` if mind does not exist
- No auth guards (local-only app)
