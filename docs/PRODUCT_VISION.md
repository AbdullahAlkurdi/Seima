# Product Vision

## What Seima Is

Seima is a knowledge and thinking tool that combines visual mind-mapping with AI-assisted reasoning. It helps users organize ideas, explore connections between concepts, and develop their thinking with the support of an intelligent partner.

Seima is being built as a serious, production-quality application — not a prototype or experiment.

## The Problem

People regularly work with complex, interconnected ideas — planning projects, learning new domains, writing, researching, or brainstorming. Traditional tools are either:

- **Too rigid** (linear documents, task managers) — they force ideas into sequences and hierarchies that don't match how thinking actually works.
- **Too unstructured** (whiteboards, free-form canvas tools) — they offer freedom but lack the structure to turn exploration into actionable results.
- **Too isolated** (most tools) — they don't help users think *better*; they only capture what the user already knows.

Seima aims to fill this gap: a structured thinking environment with an AI partner that helps users go further than they could alone.

## Target User

- Knowledge workers who regularly work with complex, interconnected information
- Students and researchers organizing understanding of a domain
- Writers and creators planning projects and exploring ideas
- Professionals tracking project knowledge, decisions, and context
- Anyone who thinks visually and wants an AI partner in their thinking process

The primary user is someone who values deep work, structured thinking, and wants to augment their own intelligence rather than replace it.

## Core User Value

Seima helps users **think better** by:

1. Providing a visual space to capture and connect ideas naturally
2. Using AI to help refine, extend, and question thinking
3. Maintaining structure that makes exploration productive, not chaotic
4. Preserving knowledge so it can be revisited and built upon over time

## Product Philosophy

- **Augment, don't replace** — AI is a thinking partner, not a replacement for the user's mind.
- **Structure enables creativity** — The right constraints make thinking clearer, not more limited.
- **Visual thinking first** — The mind-map is the primary interface because spatial relationships reflect how ideas connect.
- **Quality over speed** — Seima prioritizes a polished, reliable experience over rapid feature shipping.
- **User-owned knowledge** — The user's ideas and data belong to the user.

## Product Principles

1. **The map is the interface** — The mind-map is the primary way users interact with their ideas.
2. **AI serves the user's thinking** — AI suggestions, questions, and analysis support the user's goals, not replace them.
3. **Progressive disclosure** — Advanced features are available but don't overwhelm new users.
4. **Offline-first** — Core functionality works without a network connection.
5. **Responsive and performant** — The app feels fast regardless of map size or complexity.
6. **Consistent and polished** — Every interaction is intentional and well-crafted.
7. **Privacy-respecting** — User data is treated with care and transparency.

## What Seima Is NOT

- Not a replacement for dedicated note-taking apps (Obsidian, Notion, Roam) — though it may integrate with them.
- Not a project management tool — though it can help plan projects.
- Not a chatbot — AI interaction happens in the context of the user's visual map.
- Not a collaborative whiteboard — real-time collaboration is not a near-term priority.
- Not an AI content generator — AI is a thinking partner, not a content factory.

## Long-Term Vision

Seima becomes a user's primary environment for thinking, learning, and working with complex ideas — a personal knowledge system where visual maps, AI assistance, and structured knowledge management converge into a seamless experience.

**Current reality:** Seima has a full mind-mapping workspace with multi-selection, node types (text/task/question/idea), curved bezier connections, connection selection, import/export, debounced autosave, and a local-first AI system with real on-device LLM inference on desktop (Windows, macOS, Linux) via llama.cpp subprocess, with heuristic fallback on mobile/web. Model is optional (~1GB Qwen2.5-1.5B, downloaded on-demand). 219 tests pass, 0 analyzer issues.

**Intended direction:** Add FFI-based LLM runtime for mobile platforms, improve model download UX, and expand AI analysis capabilities.

**Long-term vision:** A mature knowledge application that combines visual thinking, AI reasoning, and personal knowledge management into one integrated tool — all running on-device with full privacy.

## High-Level Future Direction

1. **Phase 1:** Application architecture — state management, routing, feature organization ✓
2. **Phase 2:** Core mind-mapping — canvas, nodes, connections, basic editing ✓
3. **Phase 3:** Knowledge system — persistent storage, organization, search ✓
4. **Phase 4:** Knowledge Workspace — multi-selection, tags, debounced autosave ✓
5. **Phase 5:** AI Knowledge Intelligence — local-first, privacy-first AI analysis ✓
6. **Phase 6:** Real On-Device LLM Integration — llama.cpp subprocess LLM on desktop ✓
7. **Phase 7:** Canvas productivity, node types, connection selection, import/export, production hardening ✓
8. **Phase 8:** Advanced features — export (image/PDF/markdown), FFI-based LLM runtime for mobile, keyboard shortcut customization

See [ROADMAP.md](ROADMAP.md) for details.
