# Design System

> **Status:** Implemented  
> This document describes the actual design tokens and theme implementation as found in `lib/src/theme/`.

---

## Design Philosophy

Mindora's visual design prioritizes clarity, focus, and calm. The interface should recede so the user's ideas take center stage. Design decisions favor:

- **Clarity** — Clean layouts, clear hierarchy, readable text.
- **Calm** — Muted backgrounds, intentional whitespace, restrained use of color.
- **Consistency** — Every screen feels like part of the same application.
- **Accessibility** — Sufficient contrast, readable type, touch-friendly targets.

## Design Principles

1. **Content first** — Visual elements support the content, not compete with it.
2. **Minimal chrome** — UI chrome (toolbars, panels) appears only when needed.
3. **Progressive disclosure** — Complexity reveals itself gradually.
4. **Platform appropriate** — Follow platform conventions while maintaining Mindora identity.
5. **Material 3 aligned** — Leverage Material 3 design language as the foundation.

## Brand Personality

- **Intelligent** — Thoughtful, not flashy.
- **Calm** — Professional, not noisy.
- **Precise** — Every detail intentional.
- **Warm** — Approachable, not cold.

---

## Color System

### Seed Color

The entire color system is derived from a single seed color using Material 3's `ColorScheme.fromSeed()`.

| Token | Hex | Usage |
|---|---|---|
| `AppColors.seed` | `#3D5A80` | Primary seed for color scheme generation |

`#3D5A80` is a muted, professional blue — calm, intelligent, and neutral enough to work across light and dark themes.

### Light Theme

Generated via `ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.light)`.

Dynamic colors are derived from the seed:
- `primary` — Derived from seed
- `onPrimary`, `primaryContainer`, `onPrimaryContainer` — Derived
- `secondary`, `tertiary` — Derived
- `surface`, `onSurface`, `surfaceContainerHighest` — Derived
- `error`, `onError` — Derived
- `outline`, `outlineVariant` — Derived

### Dark Theme

Generated via `ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.dark)`.

All colors are automatically adjusted for dark backgrounds by the Material 3 algorithm.

### Semantic Colors

Explicitly defined for success and warning states (not derived from the seed):

| Token | Hex (Light) | Usage |
|---|---|---|
| `AppColors.success` | `#1B6B3A` | Success indicator |
| `AppColors.onSuccess` | `#FFFFFF` | Text/icon on success |
| `AppColors.successContainer` | `#C8E6C9` | Success background |
| `AppColors.onSuccessContainer` | `#0D3D1A` | Text on success container |
| `AppColors.warning` | `#8B5E00` | Warning indicator |
| `AppColors.onWarning` | `#FFFFFF` | Text/icon on warning |
| `AppColors.warningContainer` | `#FFE0B2` | Warning background |
| `AppColors.onWarningContainer` | `#3A2E00` | Text on warning container |

> **Note:** Semantic colors are defined in light theme values only. Dark theme equivalents are not yet implemented. Dark theme currently uses light semantic tokens directly, which may not have sufficient contrast on dark surfaces.

### Future Expansion

The following color tokens do not yet exist and are planned for future implementation:
- Dark theme semantic color variants
- Custom info/neutral semantic colors
- Surface variants beyond Material 3 defaults
- Gradient definitions

---

## Typography

Typography follows the Material 3 type scale with explicit `TextTheme` definitions.

### Type Scale

| Style | Size | Weight | Letter Spacing | Height |
|---|---|---|---|---|
| `displayLarge` | 57 | w400 | -0.25 | 1.0 |
| `displayMedium` | 45 | w400 | 0.0 | 1.0 |
| `displaySmall` | 36 | w400 | 0.0 | 1.0 |
| `headlineMedium` | 28 | w400 | 0.0 | 1.0 |
| `headlineSmall` | 24 | w400 | 0.0 | 1.0 |
| `titleLarge` | 22 | w500 | 0.0 | 1.0 |
| `titleMedium` | 16 | w500 | 0.15 | 1.0 |
| `titleSmall` | 14 | w500 | 0.1 | 1.0 |
| `bodyLarge` | 16 | w400 | 0.5 | 1.5 |
| `bodyMedium` | 14 | w400 | 0.25 | 1.5 |
| `bodySmall` | 12 | w400 | 0.4 | 1.5 |
| `labelLarge` | 14 | w500 | 0.1 | 1.0 |
| `labelMedium` | 12 | w500 | 0.5 | 1.0 |
| `labelSmall` | 11 | w500 | 0.5 | 1.0 |

Both `light` and `dark` `TextTheme` instances are defined. They are currently identical; the dark instance exists as a separate constant for future dark-specific customization.

> **Note:** Custom font families are not yet configured. The default Material Design font (Roboto on Android, SF on iOS) is used.

### Future Expansion

- Custom font family integration
- Dark-specific type adjustments
- Monospace token for code/technical content
- Line height refinements for readability

---

## Spacing

Defined in `AppSpacing` as a set of static constants.

| Token | Value | Usage |
|---|---|---|
| `xs` | 4.0 | Minimal spacing, icon padding |
| `s` | 8.0 | Compact spacing, small gaps |
| `m` | 12.0 | Default spacing, button padding |
| `l` | 16.0 | Content padding, card margins |
| `xl` | 24.0 | Section spacing, dialog padding |
| `xxl` | 32.0 | Large section spacing |
| `xxxl` | 48.0 | Page-level margins |

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | 4.0 | Small chips, compact elements |
| `radiusMd` | 8.0 | Default radius (cards, inputs, buttons) |
| `radiusLg` | 12.0 | Dialogs, sheets, prominent containers |
| `radiusXl` | 16.0 | Large containers |
| `radiusFull` | 9999.0 | Circular/pill shapes |

---

## Elevation / Shadows

| Token | Value | Usage |
|---|---|---|
| `elevationNone` | 0.0 | Flat surfaces |
| `elevationSm` | 1.0 | Cards, buttons (default) |
| `elevationMd` | 2.0 | Elevated cards, dialogs |
| `elevationLg` | 4.0 | Modals, bottom sheets |
| `elevationXl` | 8.0 | FABs, prominent overlays |

> Elevation values match Material 3 conventions where 1dp is the standard card elevation.

---

## Material 3 Usage

- `useMaterial3: true` in both light and dark `ThemeData`.
- `ColorScheme.fromSeed()` generates complete color schemes from the seed color.
- Card, input, and button themes are customized while staying within Material 3 conventions.
- All Material 3 typography styles are defined.

---

## Component Guidelines

### Current Themed Components

| Component | Customization |
|---|---|
| Card | `elevationSm`, `radiusMd` shape |
| Input fields | Filled style, `surfaceContainerHighest` fill, no border, `radiusMd` |
| Elevated buttons | Primary color fill, `xl`/`m` padding, `radiusMd` shape, `elevationSm` |
| Outlined buttons | Primary color text, `xl`/`m` padding, `radiusMd` shape |
| Text buttons | Primary color text, `l`/`s` padding |
| Icons | `onSurface` color, 24px default size |
| Dividers | `outlineVariant` color, 1px thickness |

### Component Status

- Components exist only as theme defaults. No custom Mindora widgets are implemented.
- Custom component widgets (MindoraCard, MindoraButton, etc.) are planned for future phases.

---

## Accessibility Principles

- **Color contrast** — Material 3 `ColorScheme.fromSeed` generates colors with AA-compliant contrast ratios by default. Semantic colors should be verified for dark theme compatibility.
- **Touch targets** — Minimum 48x48dp for interactive elements (Material 3 guideline).
- **Text scaling** — System font size preferences should be respected. Custom text styles should not force absolute sizes that break at larger accessibility font settings.
- **Screen reader support** — Semantic labels, proper heading hierarchy, and meaningful accessibility descriptions are planned.

### Current Limitations
- Semantic colors lack dark theme variants.
- No explicit accessibility testing has been performed.
- No custom semantics or accessibility labels are defined beyond Flutter defaults.

---

## Mindora Icon

The Mindora brand icon (`assets/Mindora_Icon.png`) serves as the visual anchor:

- **Source:** 1024×1024 RGBA PNG with transparency
- **Usage:** App launcher icons on all platforms, native splash screen, Flutter startup animation, MindoraLoadingView component, AI panel loading states
- **Treatment:** Always rendered at native resolution. Never distorted, recolored, or composited with gradients.

## Startup & Loading

The startup and loading experience uses the Mindora icon with subtle animation:

- **StartupScreen:** Brief entry animation (scale 0.94→1.0, opacity fade) shown on app launch before transitioning to the main UI. Integrates via `MaterialApp.builder`.
- **MindoraLoadingView:** Reusable component with three variants:
  - `fullPage` — Scaffold wrapper for standalone loading screens
  - `compact` — Inline loading for panels and embedded areas
  - `overlay` — Semi-transparent overlay for modal loading
- **Animation:** Gentle breathing pulse (0.94–1.0 scale, 2s cycle, easeInOut). Respects platform reduced-motion preferences via Flutter's animation framework.
- **Progress:** Optional `LinearProgressIndicator` shown when `progress` parameter is provided (e.g., model download).
- **Accessibility:** Semantics `liveRegion` for screen reader announcements of loading state.

## Do / Don't

| Do | Don't |
|---|---|
| Use `AppColors` tokens for all colors | Hardcode hex values |
| Use `AppSpacing` tokens for spacing | Use arbitrary padding/margin values |
| Use `AppTypography` styles for text | Create ad-hoc `TextStyle` definitions |
| Extend the theme system with new tokens | Modify existing tokens without updating this document |
| Use Material 3 components when possible | Create custom components that duplicate M3 functionality |
| Verify contrast for new color tokens | Add colors without considering both themes |
