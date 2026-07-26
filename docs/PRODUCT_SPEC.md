# Product Specification

> **Status:** Core Experience Implemented  
> The core mind-mapping experience (canvas, nodes, connections, pan/zoom, local persistence) is implemented in Phase 2. Advanced features remain planned.

---

## Capability Overview

| Category | Capability | Status |
|---|---|---|
| **Core** | Mind-map canvas | **Implemented** |
| **Core** | Node creation and editing | **Implemented** |
| **Core** | Connection between nodes | **Implemented** |
| **Core** | Map navigation (pan/zoom) | **Implemented** |
| **Core** | Map organization (folders/tags) | Planned |
| **Supporting** | Persistent local storage | **Implemented** |
| **Supporting** | Light/dark theme toggle | **Implemented** |
| **Supporting** | User preferences | Planned |
| **Supporting** | Undo/redo | **Implemented** |
| **Supporting** | Search within maps | **Implemented** |
| **Differentiating** | AI-assisted node suggestions | **Implemented** |
| **Differentiating** | AI analysis of map structure | **Implemented** |
| **Differentiating** | AI conversation on selected nodes | **Implemented** |
| **Differentiating** | Smart connections between maps | Future |
| **Differentiating** | Visual theme per map | Future |
| **Sharing** | Canonical Seima knowledge format (.seima) | **Implemented** |
| **Sharing** | Export to .seima file | **Implemented** |
| **Sharing** | Copy mind to clipboard (canonical JSON) | **Implemented** |
| **Sharing** | Human-readable text export | **Implemented** |
| **Sharing** | Import from .seima file | **Implemented** |
| **Sharing** | Import from plain text | **Implemented** |
| **Sharing** | Import from clipboard | **Implemented** |
| **Sharing** | Import preview (new mind / merge) | **Implemented** |
| **Sharing** | Android share sheet (Share into Seima) | **Implemented** |
| **Sharing** | Import validation and safety checks | **Implemented** |
| **Future** | Markdown import/export | Future |
| **Future** | Image/PDF export | Future |
| **Future** | XMind/FreeMind/OPML import | Future |
| **Future** | Cloud sync | Future |
| **Future** | Templates | Future |
| **Future** | Rich media nodes | Future |
| **Future** | Collaboration | Future |
| **Future** | API / integrations | Future |
| **Out of Scope** | Real-time collaborative editing | TBD |
| **Out of Scope** | AI content generation (blog posts, etc.) | TBD |
| **Out of Scope** | Social features | TBD |

---

## Core User Journey

1. User opens Seima and sees their map library
2. User creates or opens a mind map
3. User adds nodes (ideas, tasks, concepts)
4. User connects nodes to show relationships
5. User organizes and refines the map
6. User optionally engages AI for suggestions or analysis
7. User saves and returns later

## Primary Product Loop

```
Create/Open Map → Add/Edit Nodes → Connect Ideas → Refine Structure → AI Assistance → Save/Export → Revisit
```

## Functional Requirements

### Core: Mind-Map Canvas (Planned)

- Infinite pan/zoom canvas
- Smooth scrolling and zooming
- Visual grid or background reference
- Responsive performance with large maps

### Core: Nodes (Planned)

- Create, select, move, delete nodes
- Edit node title and body text
- Resize nodes
- Color-code nodes
- Collapse/expand node content

### Core: Connections (Planned)

- Create directed/undirected connections between nodes
- Label connections
- Remove connections
- Auto-layout options (future)

### Supporting: Theme (Implemented)

- Light and dark themes
- Toggle via `ThemeController`
- System theme mode support
- Material 3 dynamic color from seed

| **Supporting** | Storage (Planned)

| **Supporting** | Storage (Implemented)

- Local persistence using shared_preferences with JSON serialization
- Debounced auto-save on changes (300ms)
- Map metadata (title, created date, modified date, tags)

## Non-Functional Requirements

| Requirement | Target | Status |
|---|---|---|
| Startup time | < 2s cold start | Not yet measured |
| Map rendering | Smooth at 500+ nodes | Not yet measured |
| App size | < 50 MB (mobile) | Not yet measured |
| Offline capability | Full offline use | **Implemented** |
| Accessibility | WCAG 2.1 AA | Not yet implemented |
| Platform coverage | Android, iOS, Web, Windows, macOS, Linux | Scaffold exists |

## Success Criteria

- **Functional:** Users can create, edit, and organize mind maps with a smooth and intuitive experience.
- **Performance:** Maps with hundreds of nodes remain responsive.
- **Quality:** Zero crashes in normal use; consistent behavior across platforms.
- **AI differentiation:** AI assistance genuinely helps users think better, not just automate tasks.
- **Adoption:** Users choose Seima as their primary thinking tool.

---

## TBD Areas

The following areas are not yet defined and require product discovery:

- Specific AI interaction model (chat inline vs separate panel vs gesture-initiated)
- Monetization model (if any)
- Collaborative features
- Integration API design
- Enhanced export formats (Markdown, image, PDF) fidelity
