---
name: design-system
description: Visual design rules for every screen and widget in this repo - where colors, typography, shapes, icons, feedback (toasts, loaders, errors) and images come from, when a widget belongs in packages/design_system, how to add or change a shared component, theming both brightnesses, and the UI review checklist. Load before building or reviewing any UI in apps, features, packages or plugins.
---

# Design system

`packages/design_system` is the single source of visual truth. Features
compose it; they do not restyle it. Package details and gotchas are in
`packages/design_system/CLAUDE.md`.

## Where every visual value comes from

| Need | Use | Never |
|---|---|---|
| Color | `DesignColors.of(context).<token>` or `Theme.of(context).colorScheme.<role>` (`primary`, `onPrimary`, `surface`, `onSurfaceVariant`, `error`, `outlineVariant`, ...) | `Color(0x...)`, `Colors.*`, opacity hacks for meaning |
| Text | `Theme.of(context).textTheme.<style>` (`titleLarge`, `bodyMedium`, `labelSmall`, ...), `copyWith` only for `color` / `fontWeight` | Raw `TextStyle(fontSize: ...)`, new font families |
| Buttons, app bar, nav bar, inputs | Plain Material widgets; styling comes from `DesignSystem._baseTheme` | Per-widget `style:` that restyles shape or typography |
| Icons | `NavigationIcons` for navigation; Material `Icons` otherwise | A second icon set in a feature |
| Feedback | `Toast.success/error/warning/notification`; `Loader.show/hide` for blocking work; `DefaultLoader` inline | `ScaffoldMessenger` snack bars, ad-hoc overlays |
| Errors | `DefaultErrorView` (inline, with retry), `ErrorScreen` (full screen) | Custom error widgets per feature |
| Images | `NetworkUrlImage` (cached, placeholder, error), `AppAssetImage` (raster or SVG with fallback) | `Image.network`, Flutter `AssetImage` directly |
| Copy | `strings.<group>.<key>` from `localization` | String literals |

## Layout and spacing

- Spacing comes from `DesignSpace` (`space-*`: 4, 8, 12, 16, 24, 32, 48).
  Prefer `DesignSpace.s4` for phone screen padding.
- Corner radius comes from `DesignShape.of(context)`: one user-chosen
  corner (default 14) with the roles `xs` / `sm` / `md` / `lg` (6, 10, 14,
  22 at the default) and `forHeight(h)` for short elements. No circles,
  no stadiums, no `BorderRadius.circular(` outside `design_shape.dart`;
  `features/flip_clock/test/corner_rule_test.dart` fails on them.
- Chrome sizes and timings come from `DesignSize` and `DesignMotion`; the
  exact values live in the design system's `tokens.json`. Never invent one.
- When the same spacing or size literal repeats across three or more files,
  add a named constant to `design_system` instead of copying it again.
- Use `SafeArea`, `LayoutBuilder` / `MediaQuery.sizeOf` for responsive layout.
  No hard-coded screen widths. Scrollable content uses `ListView` / slivers.

## Is it a design-system component?

Put a widget in `packages/design_system` only when all of these hold:

1. Two or more features need it (or the app shell does).
2. It knows nothing about a product domain (no "Order", "Patient", "Invoice").
3. It renders only what its parameters give it: no `di`, no repositories, no
   navigation, no analytics calls. Callbacks go out (`onRetry`, `onChanged`).

Otherwise keep it in the feature's `lib/ui/components/`.

## Adding or changing a shared component

1. Check the catalog in `packages/design_system/CLAUDE.md`; extend an existing
   component with a parameter before creating a sibling.
2. `StatelessWidget`, `const` constructor, `super.key`, required parameters
   first. Use a `enum` for variants (see `HeaderType`, `DateFilterType`).
3. Style only through the theme. Take user-visible text as a parameter, or use
   `strings.*` for generic defaults (as `ErrorScreen` does).
4. Accessibility: 48x48dp minimum tap targets, a `tooltip` or
   `Semantics(label:)` on icon-only controls, no fixed heights around text, and
   color is never the only signal.
5. Export it from `lib/components/index.dart` (or the matching barrel).
6. Test it in `packages/design_system/test/` for light and dark themes,
   interaction callbacks, empty/error states, and large text scale
   (`MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(2)), ...)`).
7. Changing a public parameter is a breaking change: update every caller in
   `apps/` and `features/` in the same change.

## Theming

- Light and dark are both first-class. Check every new screen in both; the
  wrapper follows platform brightness.
- Palette: the Mono tokens in `lib/constants/design_tokens.dart`
  (`DesignColors.dark` / `.light`), mapped onto Material roles by
  `DesignSystem.blackScheme()` / `monoLightScheme()`. Read named tokens with
  `DesignColors.of(context)` when no Material role fits (island, hairline,
  ink-subtle). `lib/generated/theme.dart` (Material Theme Builder) only
  supplies the roles the tokens do not name; never edit it.
- Fonts: Geist for the interface (`DesignSystem(context, bodyFont: ..., displayFont: ...)`), `DisplayFace` for digits. Every face is bundled; never add one without its `.ttf` and OFL licence.
- Component-wide changes (all buttons squarer, all app bars left-aligned) go in
  `DesignSystem._baseTheme`, one place.

## UI review checklist

- [ ] No raw colors, font sizes or string literals in the diff.
- [ ] Loading, empty, error and data states are all handled.
- [ ] Works in light and dark, at 2x text scale, on a small phone width.
- [ ] Icon-only controls have labels; tap targets are at least 48dp.
- [ ] Reused design-system components instead of new look-alikes.
- [ ] New shared component: exported, tested, documented in
      `packages/design_system/CLAUDE.md`.
