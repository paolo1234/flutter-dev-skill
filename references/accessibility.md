# Accessibility Reference — a11y for Flutter

## Semantics

```dart
// ✅ Always provide semantic labels for icons and images
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Elimina elemento',  // Also serves as Semantics label
  onPressed: () {},
);

// ✅ Merge semantics for composite widgets
Semantics(
  label: 'Profilo di Mario Rossi, online',
  child: Row(
    children: [
      ExcludeSemantics(child: Avatar(url: user.avatarUrl)),
      Text(user.name),
      ExcludeSemantics(child: OnlineIndicator()),
    ],
  ),
);

// ✅ Semantic properties for interactive elements
Semantics(
  button: true,
  label: 'Aggiungi al carrello',
  hint: 'Tocca due volte per aggiungere',
  child: GestureDetector(
    onTap: addToCart,
    child: const AddToCartIcon(),
  ),
);
```

## Contrast Ratios (WCAG AA)

| Element | Minimum Ratio | How to Check |
|---|---|---|
| Normal text (< 18sp) | 4.5:1 | Use WebAIM contrast checker |
| Large text (≥ 18sp bold / ≥ 24sp) | 3:1 | |
| UI components (buttons, inputs) | 3:1 | Border/background vs surrounding |
| Focus indicators | 3:1 | Against both focus and non-focus state |

## Touch Targets

- **Minimum tap target**: 48x48 dp (Material Design guideline)
- Use `MaterialButton`, `IconButton`, `InkWell` — they ensure minimum size
- For custom widgets: wrap in `SizedBox(width: 48, height: 48)`

## Text Scaling

```dart
// ✅ Support user's text scale preference
// Use sp units (default in Flutter Text widgets)
// Don't cap maxScaleFactor unless absolutely necessary

// Test with large text:
// Settings → Accessibility → Font size → Largest

// If layout breaks with large text, use:
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.5),
    ),
  ),
  child: child,
);
```

## Screen Reader Testing

```bash
# Android: TalkBack
# Settings → Accessibility → TalkBack → Enable

# iOS: VoiceOver
# Settings → Accessibility → VoiceOver → Enable

# Flutter: Semantics debugger
MaterialApp(
  showSemanticsDebugger: true,  // Shows semantics overlay
);
```

## Checklist

- [ ] All images have alt text (Semantics label)
- [ ] All interactive elements have tooltip/label
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 components)
- [ ] Touch targets ≥ 48x48 dp
- [ ] App works with text scale 200%
- [ ] Logical focus/tab order
- [ ] Error states announced to screen reader
- [ ] No information conveyed by color alone (use icons/text too)
- [ ] Animations respect `AccessibilityFeatures.reduceMotion`

## Reduce Motion

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;

AnimatedContainer(
  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
  // ...
);
```
