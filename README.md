# Seima

A mind-mapping application integrated with an AI assistant for organizing ideas, tracking project progress, and visualizing complex thoughts.

**Status:** Phase 7 â€” Canvas Productivity + Production Readiness Hardening. Multi-node selection, node types (text/task/question/idea), curved connections, connection selection, import/export, drag undo grouping, debounced autosave, viewport culling, and 100% on-device AI with optional LLM.

---

## Product Vision

Mindora helps users think clearly by combining structured mind-mapping with AI-assisted reasoning. The goal is a production-quality knowledge application where users can build, connect, and explore ideas visually while an AI partner helps refine and extend their thinking.

See [docs/PRODUCT_VISION.md](docs/PRODUCT_VISION.md) for the full vision.

---

## Technical Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.44 (stable) |
| Language | Dart 3.12 |
| UI System | Material 3 |
| Theme | Centralized custom theme system (`lib/app/theme/`) |
| State Management | flutter_bloc 9.x (Cubit) |
| Routing | go_router 14.x |
| Dependency Injection | get_it 8.x |
| Platforms | Android, iOS, Web, Windows, macOS, Linux |

---

## Architecture Overview

```
lib/
â”œâ”€â”€ main.dart              # Entry point
â”œâ”€â”€ app/                   # Application infrastructure
â”‚   â”œâ”€â”€ app.dart           # MindoraApp widget
â”‚   â”œâ”€â”€ di.dart            # Dependency injection setup
â”‚   â”œâ”€â”€ config/            # App configuration
â”‚   â”œâ”€â”€ router/            # Route definitions
â”‚   â””â”€â”€ theme/             # Centralized design system
â”œâ”€â”€ core/                  # Shared foundations
â”‚   â””â”€â”€ errors/            # AppException, Failure types
â””â”€â”€ features/              # Feature modules
    â”œâ”€â”€ home/              # Home screen (placeholder)
    â”‚   â””â”€â”€ presentation/
    â”‚       â”œâ”€â”€ cubit/
    â”‚       â””â”€â”€ pages/
    â””â”€â”€ mind/              # Mind workspace + library (Phase 2/3/4/7)
        â”œâ”€â”€ data/          # MindRepository (versioned), ID provider
        â”œâ”€â”€ domain/        # Mind, MindNode, MindConnection, NodeType
        â””â”€â”€ presentation/  # MindCubit, MindLibraryCubit, SearchCubit
                           # Pages: library, workspace, search
                           # Widgets: canvas, node, connection painter, editor
    â””â”€â”€ ai/                # AI knowledge intelligence (Phase 5/6)
        â”œâ”€â”€ data/          # AIService, LLMAIService, LocalAIService
        â”‚                  # LLM runtime, model manager, response parser
        â”œâ”€â”€ domain/        # AI config, context, proposals, response
        â””â”€â”€ presentation/  # AICubit, AI panel, proposal cards
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

---

## Documentation Index

| Document | Purpose |
|---|---|
| [PRODUCT_VISION.md](docs/PRODUCT_VISION.md) | Product vision, philosophy, long-term direction |
| [PRODUCT_SPEC.md](docs/PRODUCT_SPEC.md) | Feature specification, requirements, user journey |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture principles, structure, rules |
| [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Theme tokens, component guidelines, accessibility |
| [ROADMAP.md](docs/ROADMAP.md) | Development phases and milestones |
| [DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md) | Setup, workflow, best practices |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Contribution guidelines and standards |
| [DECISIONS.md](docs/DECISIONS.md) | Architecture Decision Record log |
| [PROJECT_STATUS.md](docs/PROJECT_STATUS.md) | Current status, priorities, next steps |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.44+ ([install guide](https://docs.flutter.dev/get-started/install))
- Dart 3.12+ (bundled with Flutter)
- A code editor (VS Code, Android Studio, or IntelliJ recommended)

### Installation

```bash
git clone <repository-url>
cd seima
flutter pub get
```

### Running the App

```bash
flutter run
```

### Running Tests

```bash
flutter test
```

### Running the Analyzer

```bash
flutter analyze
```

### Formatting Code

```bash
dart format .
```

---

## Development Status

- [x] Project initialization
- [x] Visual foundation / theme system
- [x] Light and dark theme support
- [x] Material 3 integration
- [x] App architecture foundation (state management, routing, DI, errors)
- [x] Application shell (replaces default counter app)
- [x] Test foundation (unit + widget tests)
- [x] Core mind-mapping features (canvas, nodes, connections, persistence)
- [x] Mind Library (list, create, rename, delete, duplicate)
- [x] Search across minds and nodes
- [x] Undo/redo (Ctrl+Z/Y)
- [x] Keyboard shortcuts (Delete/Backspace)
- [x] Multiple mind support
- [x] Node types (text, task, question, idea)
- [x] Canvas connection selection
- [x] Curved bezier connections
- [x] Viewport culling for performance
- [x] Fit-to-content
- [x] Import/export JSON
- [x] AI integration (100% on-device, optional LLM via llama.cpp)
- [x] Drag undo grouping (single undo per drag operation)
- [x] Debounced autosave (300ms)
- [x] Production readiness hardening
- [x] 219 tests, 0 analyzer issues
- [ ] FFI-based LLM runtime for mobile platforms
- [ ] Keyboard shortcut customization
- [ ] Export to image/PDF/markdown

See [docs/ROADMAP.md](docs/ROADMAP.md) for the full development roadmap.

---

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for contribution guidelines.

---

## License

Proprietary â€” all rights reserved.
