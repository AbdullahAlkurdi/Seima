# Seima Sharing & Interoperability Architecture

> **Date:** 2026-07-26
> **Status:** Foundation Established
> **Phase:** Pre-release foundation

---

## Table of Contents

1. [Current State Audit](#1-current-state-audit)
2. [Architecture Overview](#2-architecture-overview)
3. [Canonical Knowledge Format](#3-canonical-knowledge-format)
4. [Export Pipeline](#4-export-pipeline)
5. [Import Pipeline](#5-import-pipeline)
6. [Share Into Seima](#6-share-into-seima)
7. [Share From Seima](#7-share-from-seima)
8. [Import Preview & Safety](#8-import-preview--safety)
9. [AI + Import Interoperability](#9-ai--import-interoperability)
10. [Data Integrity](#10-data-integrity)
11. [UI/UX Surfaces](#11-ux-surfaces)
12. [Platform Interoperability](#12-platform-interoperability)
13. [Implementation Phases](#13-implementation-phases)
14. [Privacy & Security](#14-privacy--security)
15. [Testing Strategy](#15-testing-strategy)
16. [Future Adapters](#16-future-adapters)

---

## 1. Current State Audit

### What Exists

| Capability | Status |
|---|---|
| Native JSON serialization (Mind.toJson) | Implemented |
| Native JSON deserialization (Mind.fromJson) | Implemented |
| Schema versioning (Mind.schemaVersion) | Implemented |
| Export/Import UI page | Skeleton only (no file I/O) |
| MindCubit.exportMind() | Returns Map<String, dynamic> |
| MindCubit.importMind() | Accepts Map<String, dynamic> |
| Connection validation on import | Implemented |
| Repository backup/restore | Implemented |
| Share sheet integration | NOT implemented |
| File picker integration | NOT implemented |
| Platform share intent receiving | NOT implemented |
| Interchange format | NOT designed |
| Import preview | NOT implemented |
| Text/clipboard ingestion | NOT implemented |

### Existing Serialization Strengths

- All domain models have `toJson()`/`fromJson()` serialization.
- Unknown fields are safely ignored in `fromJson`.
- Missing optional fields have safe defaults.
- Missing required fields throw `ArgumentError`.
- Schema versioning is present on `Mind`.
- Repository has atomic save with backup/restore.
- Connection validation on import prevents invalid states.

### Existing Serialization Gaps

- No canonical interchange format separate from app storage format.
- No deterministic field ordering.
- No explicit schema identification.
- No provenance/metadata tracking.
- No version field in the export wrapper.
- All-or-nothing import (no preview, no merge, no partial import).
- No support for non-Seima input formats.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    USER INTERFACES                       │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ Library  │  │ Mind Canvas  │  │ Import Preview   │   │
│  │ Page     │  │ Workspace    │  │ Page             │   │
│  └────┬─────┘  └──────┬───────┘  └────────┬─────────┘   │
│       │               │                    │             │
│  ┌────▼───────────────▼────────────────────▼──────────┐  │
│  │              Cubit Layer                           │  │
│  │  MindLibraryCubit / MindCubit / ImportCubit        │  │
│  └────────────────────┬───────────────────────────────┘  │
│                       │                                  │
├───────────────────────┼──────────────────────────────────┤
│  ┌────────────────────▼───────────────────────────────┐  │
│  │              Service Layer                         │  │
│  │  ┌─────────────┐   ┌─────────────┐                │  │
│  │  │ Export      │   │ Import      │                │  │
│  │  │ Service     │   │ Service     │                │  │
│  │  └──────┬──────┘   └──────┬──────┘                │  │
│  │         │                 │                        │  │
│  │  ┌──────▼──────────────────▼──────┐               │  │
│  │  │     InputDetector              │               │  │
│  │  └────────────────────────────────┘               │  │
│  │                                                    │  │
│  │  ┌─────────────┐   ┌──────────────────────────┐    │  │
│  │  │ Seima       │   │ Import Adapters:         │    │  │
│  │  │ Knowledge   │   │ - CanonicalAdapter       │    │  │
│  │  │ Package     │   │ - TextAdapter            │    │  │
│  │  └─────────────┘   │ - ClipboardAdapter       │    │  │
│  │                     └──────────────────────────┘    │  │
│  └────────────────────┬───────────────────────────────┘  │
│                       │                                  │
├───────────────────────┼──────────────────────────────────┤
│  ┌────────────────────▼───────────────────────────────┐  │
│  │           Data / Platform Layer                    │  │
│  │  ┌────────────┐  ┌──────────┐  ┌───────────────┐  │  │
│  │  │ Mind       │  │ Platform │  │ Share         │  │  │
│  │  │ Repository │  │ File I/O │  │ Handler       │  │  │
│  │  └────────────┘  └──────────┘  └───────────────┘  │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Principles

1. **Local-first:** All processing happens on-device. No user content is uploaded to any server during import/export.
2. **User-initiated:** All sharing/export is explicitly triggered by the user.
3. **Safe by default:** Preview before import. Confirm before mutation. Never silently overwrite.
4. **Forward-compatible:** The canonical format tolerates unknown fields. Future schema additions will not break existing parsers.
5. **Backward-compatible:** New Seima can read old canonical files. Old Seima (through version checking) can reject unsupported files gracefully.
6. **Deterministic:** The canonical format has a defined field order. Two exports of the same mind produce identical output.
7. **Cancellable:** Long-running import operations can be cancelled.
8. **Auditable:** Every export carries provenance metadata. Every import can be reviewed.

---

## 3. Canonical Knowledge Format

### Schema Identity

- **Schema identifier:** `seima_knowledge`
- **Format version:** integer (current: `1`)
- **Serialization:** JSON (UTF-8)
- **File extension:** `.seima`
- **MIME type:** `application/vnd.seima.knowledge`

The schema identifier is a fixed string that identifies the payload as a Seima knowledge package. The version number allows future evolution of the format without breaking existing data.

### Structure

```json
{
  "schema": "seima_knowledge",
  "seima_knowledge_version": 1,
  "created_at": "2026-07-26T14:30:00.000Z",
  "source_app": "seima",
  "mind": {
    "id": "abc123",
    "title": "My Mind",
    "description": "A mind about...",
    "category": "Work",
    "created_at": "2026-07-26T14:00:00.000Z",
    "updated_at": "2026-07-26T14:30:00.000Z",
    "tags": ["important", "reference"],
    "metadata": {
      "custom_field": "value"
    }
  },
  "nodes": [
    {
      "id": "node1",
      "type": "text",
      "content": "Main idea",
      "tags": ["core"],
      "position": { "x": 100, "y": 200 },
      "dimensions": { "width": 200, "height": 80 },
      "created_at": "2026-07-26T14:05:00.000Z",
      "updated_at": "2026-07-26T14:10:00.000Z",
      "metadata": {}
    }
  ],
  "connections": [
    {
      "id": "conn1",
      "source_id": "node1",
      "target_id": "node2",
      "type": "directed",
      "label": "leads to",
      "created_at": "2026-07-26T14:15:00.000Z",
      "metadata": {}
    }
  ],
  "provenance": {
    "exported_at": "2026-07-26T14:30:00.000Z",
    "exported_by": "seima_export",
    "source_app": "seima",
    "notes": "Exported from Seima mind workspace"
  }
}
```

### Fields

| Field | Required | Type | Description |
|---|---|---|---|
| `schema` | Yes | String | Fixed: `seima_knowledge` |
| `seima_knowledge_version` | Yes | Integer | Format version (currently 1) |
| `created_at` | Yes | ISO 8601 | When this package was created |
| `source_app` | Yes | String | Source application identifier |
| `mind` | No | Object | Mind metadata |
| `nodes` | No | Array | Knowledge nodes |
| `connections` | No | Array | Node relationships |
| `provenance` | No | Object | Export/source tracking |

#### Mind Object

| Field | Required | Type |
|---|---|---|
| `id` | Yes | String |
| `title` | Yes | String |
| `description` | No | String |
| `category` | No | String |
| `created_at` | No | ISO 8601 |
| `updated_at` | No | ISO 8601 |
| `tags` | No | String array |
| `metadata` | No | Object |

#### Node Object

| Field | Required | Type |
|---|---|---|
| `id` | Yes | String |
| `type` | Yes | String (enum: text, task, question, idea) |
| `content` | No | String |
| `tags` | No | String array |
| `position` | Yes | Object { x, y } |
| `dimensions` | Yes | Object { width, height } |
| `created_at` | No | ISO 8601 |
| `updated_at` | No | ISO 8601 |
| `metadata` | No | Object |

#### Connection Object

| Field | Required | Type |
|---|---|---|
| `id` | Yes | String |
| `source_id` | Yes | String |
| `target_id` | Yes | String |
| `type` | No | String (default: "directed") |
| `label` | No | String |
| `created_at` | No | ISO 8601 |
| `metadata` | No | Object |

### Forward/Backward Compatibility Rules

1. Unknown fields are silently ignored (JSON parsing with safe access).
2. Missing optional fields receive documented safe defaults.
3. Missing required fields produce a `SharingFailure` with a clear message.
4. Unknown `node.type` values fall back to `text`.
5. Unknown `connection.type` values fall back to `directed`.
6. The `schema` field must match exactly. Other schema values are rejected.
7. The `seima_knowledge_version` will be checked; unsupported future versions produce an actionable error.

### What is Preserved Across Export → Import Round Trip

| Item | Preserved? | Notes |
|---|---|---|
| Mind ID | Yes | Preserved for Seima-to-Seima round trip |
| Mind title | Yes | |
| Description | Yes | |
| Category | Yes | |
| All nodes | Yes | |
| Node IDs | Yes | |
| Node types | Yes | Unknown types fall back |
| Node content | Yes | |
| Node positions | Yes | |
| Node dimensions | Yes | |
| Node tags | Yes | |
| Node timestamps | Yes | |
| All connections | Yes | |
| Connection IDs | Yes | |
| Connection direction | Yes | |
| Connection timestamps | Yes | |
| Metadata | Yes | Preserved as opaque map |
| Provenance | Yes | |

### What is Lost (Deliberately)

Nothing is lost in the canonical `.seima` format. Human-readable formats (text, markdown) intentionally lose canvas-specific information.

---

## 4. Export Pipeline

### Architecture

```
Mind instance
    │
    ▼
ExportService.exportMind(mind)
    │
    ▼
SeimaKnowledgePackage.fromMind(mind)
    │
    ├──► ExportService.exportToFile(path)
    │         │
    │         ▼
    │     .seima file (JSON UTF-8)
    │
    ├──► ExportService.shareMind(mind)
    │         │
    │         ▼
    │     Temp .seima file → Platform share sheet
    │
    ├──► ExportService.exportToText(mind)
    │         │
    │         ▼
    │     Human-readable plaintext
    │
    └──► ExportService.copyToClipboard(mind)
              │
              ▼
          Clipboard text (canonical JSON)
```

### ExportService Interface

```dart
class ExportService {
  SeimaKnowledgePackage exportMind(Mind mind);
  Future<String> exportToFile(Mind mind, {String? directory});
  Future<void> shareMind(Mind mind);
  String exportToText(Mind mind);
  Future<void> copyToClipboard(Mind mind);
}
```

### Export Formats

| Format | Preserves | Loses | Use Case |
|---|---|---|---|
| `.seima` (canonical) | Everything | Nothing | Seima-to-Seima, backup |
| Clipboard (JSON) | Everything (as text) | -- | Quick copy/paste |
| Plain text | Content, structure | Positions, types, IDs | Human reading |
| Markdown (future) | Content, hierarchy | Positions, IDs | Documentation |
| Image (future) | Visual layout | Editability | Presentation |
| PDF (future) | Visual layout | Editability | Printing |

---

## 5. Import Pipeline

### Architecture

```
External Input (file, text, clipboard, share intent)
    │
    ▼
InputDetector.detect(input)
    │
    ├── Canonical JSON (.seima) → CanonicalAdapter
    ├── Plain text                → TextAdapter
    ├── Markdown (future)        → MarkdownAdapter
    ├── Clipboard                → Auto-detect format
    └── Other (future)           → Future adapter
    │
    ▼
SeimaKnowledgePackage (normalized)
    │
    ▼
Validation (schema, required fields, connection integrity)
    │
    ▼
ImportPreview (UI: source, title, nodes, connections, destination)
    │
    ▼
User Confirmation
    │
    ├── Create new mind
    ├── Add to existing mind
    └── Cancel
    │
    ▼
ImportService.executeImport(options)
    │
    ▼
Mind (new or merged) → Repository.save()
```

### ImportService Interface

```dart
class ImportService {
  Future<ImportPreview> previewFromFile(String path);
  Future<ImportPreview> previewFromString(String content);
  Future<ImportPreview> previewFromClipboard();
  Future<ImportPreview> previewFromPackage(SeimaKnowledgePackage pkg);

  Future<Mind> executeAsNewMind(ImportPreview preview);
  Future<Mind> executeMergeIntoMind(ImportPreview preview, Mind targetMind);
}
```

### Import Adapters

| Adapter | Input | Status |
|---|---|---|
| CanonicalAdapter | `.seima` JSON | Implemented |
| TextAdapter | Plain text | Implemented |
| ClipboardAdapter | Auto-detect | Implemented |
| MarkdownAdapter | Markdown | Future |
| XMindAdapter | `.xmind` | Future |
| FreeMindAdapter | `.mm` | Future |
| OPMLAdapter | `.opml` | Future |

### Validation Rules (applied before preview)

1. Schema field must be `seima_knowledge`.
2. Version must be ≤ current supported version.
3. Required fields must be present.
4. All connection source/target IDs must reference existing nodes (or be flagged).
5. Duplicate node IDs are detected and reported.
6. Duplicate connection IDs are detected and reported.
7. Unknown fields are silently preserved for round-trip fidelity.
8. Invalid required fields produce user-friendly errors.

---

## 6. Share Into Seima

### User Flow

```
User in another app
    │
    ├── Selects text/image/content
    ├── Presses "Share"
    └── Selects Seima from share sheet
    │
    ▼
Android intent received → MainActivity
    │
    ▼
MethodChannel → ShareHandler
    │
    ▼
ImportCubit handles incoming share
    │
    ▼
Import Preview screen opens
    │
    ├── Shows: source app, content type, preview
    ├── Options:
    │   ├── Create new mind
    │   ├── Add to existing mind
    │   └── Cancel
    │
    ▼
User confirms → Mind created/updated → Navigate to workspace
```

### Android Implementation

- **Intent filter:** `ACTION_SEND` with `text/plain` and `application/json` MIME types
- **File opening:** `ACTION_VIEW` for `.seima` files (future)
- **Platform channel:** `com.seima/sharing` via MethodChannel
- **Payload:** Shared text content passed as method arguments

---

## 7. Share From Seima

### Architecture

The same `ExportService` pipeline is used from all surfaces:

- **Library page:** Share mind from card menu
- **Mind workspace:** Share from app bar
- **Node selection:** Share selected nodes (future)
- **AI analysis:** Share AI-generated analysis (future)

### Share Flow

```
User taps Share
    │
    ▼
ExportService.shareMind(mind)
    │
    ├── Creates temp .seima file
    ├── Triggers platform share sheet
    └── Cleans up temp file
    │
    ▼
User chooses destination
    │
    ├── Another Seima instance
    ├── File storage
    ├── Messaging app
    └── Any share target
```

---

## 8. Import Preview & Safety

### Preview Content

| Item | Shown |
|---|---|
| Source type | File, text, clipboard, share |
| Content title | Extracted or filename |
| Content type | `.seima`, plain text, etc. |
| Node count | Number of detected nodes |
| Connection count | Number of detected connections |
| Detected structure | Summary of what was found |
| Destination | New mind / target mind name |
| What will be created | Clear action description |
| What may be lost | Format-specific warnings |
| Potential issues | Parsing warnings, missing fields |

### Safety Guarantees

1. Never overwrite existing mind without explicit confirmation.
2. Never silently merge data.
3. Invalid files produce user-friendly errors (not crashes).
4. Large inputs processed asynchronously (no UI freeze).
5. Import operations are cancellable.
6. Preview is always shown before mutation.
7. Imported minds are saved with new IDs by default.

---

## 9. AI + Import Interoperability

### Future Architecture

```
External content
    │
    ▼
Seima ingestion (ImportService)
    │
    ▼
AI analysis (AIService.analyze())
    │
    ▼
Suggested structure (proposals)
    │
    ▼
User review (proposal cards)
    │
    ▼
User confirmation
    │
    ▼
Mind / nodes / relationships created
```

### Principles

1. AI must NOT automatically modify user data without confirmation.
2. Imported content must be safely inspectable before AI transformation.
3. AI proposals are applied through the existing `beginBatchUndo`/`endBatchUndo` mechanism.
4. Users can accept or reject individual AI suggestions.
5. The AI can suggest connections between imported nodes and existing nodes.

---

## 10. Data Integrity

### Existing Architecture Used

- **Atomic persistence:** `MindRepository.save()` writes backup first, then primary; restores from backup on corruption.
- **Validation before mutation:** `_validateConnections()` runs before any import.
- **Undo/redo:** Import operations trigger the undo stack.

### New Guarantees

1. Export never modifies user data (read-only).
2. Import validates the complete package before writing anything.
3. The undo stack captures the pre-import state.
4. Import cancellation restores the pre-import state.
5. Malformed input never crashes the app.
6. Large inputs are processed on a background isolate where feasible.
7. AI-assisted imports remain reviewable and undoable.

---

## 11. UX Surfaces

### Home / Library Page

- Import button (visible in empty state and app bar)
- Recent imported content indicator (future)

### Mind Workspace (App Bar)

- Share button (share the current mind)
- Import into current mind (future)

### Dedicated Screens

| Screen | Purpose | Trigger |
|---|---|---|
| Import Preview | Review content before import | File picker, share, clipboard |
| Export | Export options for selected minds | Share/export action |
| Share receive | Handle incoming share intent | System share sheet |

### Dialogs

| Dialog | Purpose |
|---|---|
| Confirm import | Simple yes/no for clear cases |
| Destination picker | Choose which mind to merge into |
| Import success | Confirmation with option to open |
| Import failure | Error details + retry option |

---

## 12. Platform Interoperability

### Current Support

| Platform | Share Out | Share In | File Open | Notes |
|---|---|---|---|---|
| Android | Planned | This phase | Planned | Primary (SM-A057F) |
| iOS | Future | Future | Future | |
| Windows | Future | N/A | Future | |
| macOS | Future | Future | Future | |
| Linux | Future | N/A | Future | |
| Web | N/A | N/A | Future | |

### Android Details

- **Share intent:** `ACTION_SEND` with `text/plain`, `application/json`
- **File intent:** `ACTION_VIEW` with `.seima` files (future)
- **MIME type:** `application/vnd.seima.knowledge` (future)
- **Share sheet:** `Intent.createChooser()` via platform
- **Deep links:** Not required for initial implementation

### Abstractions

```dart
abstract class PlatformShareHandler {
  Future<String?> getPendingSharedContent();
  Future<void> clearPendingSharedContent();
}
```

---

## 13. Implementation Phases

### Phase A: Canonical Seima Knowledge Format

- Define `SeimaKnowledgePackage` class with serialization.
- Implement `fromMind()` / `toMind()` conversion.
- Add validation and error handling.
- Write comprehensive tests.

### Phase B: Native Seima Export/Share

- Implement `ExportService` with file output.
- Integrate `share_plus` for platform share sheet.
- Update export/import settings page.
- Add share button to mind workspace.

### Phase C: Native Seima Import

- Implement `ImportService` with file and string input.
- Implement `CanonicalAdapter` and `TextAdapter`.
- Add file picker for `.seima` files.
- Wire into existing `MindCubit.importMind()`.

### Phase D: Android "Share Into Seima"

- Add Android intent filters.
- Implement `ShareHandler` with MethodChannel.
- Create share receive flow UI.
- Wire to Import Preview page.

### Phase E: Import Preview & Validation UX

- Implement `ImportPreviewPage`.
- Add validation summary.
- Implement destination picker.
- Wire import execute flow.

### Phase F: Text/Markdown/Clipboard Ingestion

- Text adapter (plain text → nodes).
- Clipboard monitoring.
- Quick import from text selection.

### Phase G: Future External Adapters

- Markdown file parser.
- XMind/FreeMind/OPML adapters.
- URL content extraction.
- Image/screenshot ingestion.

---

## 14. Privacy & Security

### Local-First Principle

- All processing is local. No user content is uploaded.
- The only network operation in Seima is optional AI model downloads (from HuggingFace).
- Export writes to local storage. Sharing is through the platform share sheet (user controls destination).
- Import reads from local files or platform clipboard.

### User Control

- All sharing is user-initiated.
- All imports require explicit user confirmation.
- Users can review preview before any data mutation.
- Users can cancel at any point.
- Users choose destination (new mind / existing mind).

### No Telemetry

- No analytics or telemetry is collected.
- No usage data is sent.
- No crash reporting (unless configured by the platform).

---

## 15. Testing Strategy

### Unit Tests

| Test Suite | File | Coverage |
|---|---|---|
| Canonical serialization | `seima_knowledge_package_test.dart` | toJson, fromJson, round trip |
| Missing fields | `seima_knowledge_package_test.dart` | Safe defaults, errors |
| Unknown fields | `seima_knowledge_package_test.dart` | Silent preservation |
| Invalid required fields | `seima_knowledge_package_test.dart` | User-friendly errors |
| Corrupted input | `seima_knowledge_package_test.dart` | Parse failure handling |
| Empty import | `import_service_test.dart` | Zero-node mind |
| Duplicate IDs | `import_service_test.dart` | Detection + error |
| Duplicate connections | `import_service_test.dart` | Detection + error |
| Export service | `export_service_test.dart` | Mind → Package fidelity |
| Import service | `import_service_test.dart` | Package → Mind fidelity |
| Input detector | `input_detector_test.dart` | Format detection |
| Text adapter | `import_service_test.dart` | Plain text parsing |
| Round trip | `seima_knowledge_package_test.dart` | Export → Import → Export |

### Integration Tests

- Export mind → verify file exists → import → verify content matches
- Clipboard export → clipboard import → verify round trip
- Import validation with invalid data → verify error messages

---

## 16. Future Adapters

### Planned Adapters

| Format | Priority | Complexity | Notes |
|---|---|---|---|
| Markdown | High | Medium | Headers → nodes, lists → connections |
| XMind | Medium | High | Zip-based format with XML |
| FreeMind (.mm) | Medium | Medium | XML-based mind map format |
| OPML | Medium | Medium | Outline format |
| JSON (generic) | Low | Medium | Heuristic structure detection |
| CSV | Low | Medium | Rows → nodes, columns → properties |

### Adapter Interface

```dart
abstract class ImportAdapter {
  String get formatName;
  bool canHandle(String input);
  Future<ImportPreview> preview(String input);
  Future<SeimaKnowledgePackage> parse(String input);
}
```
