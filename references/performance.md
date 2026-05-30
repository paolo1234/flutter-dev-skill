# Performance Reference — Flutter Optimization

## Build Optimization

1. **`const` everywhere possible** — skips rebuild entirely
2. **Split widgets** — smaller widgets = smaller rebuild scope
3. **`RepaintBoundary`** — isolate frequently repainting widgets
4. **Avoid `Opacity`** — use opaque alternatives (`ColoredBox`, `Container` with color)
5. **`AnimatedContainer`** over manual `AnimationController` for simple animations

## List Performance

```dart
// ✅ ListView.builder — lazy, only builds visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
);

// ✅ itemExtent for fixed height — improves scroll performance
ListView.builder(
  itemExtent: 72,
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
);

// ✅ SliverList for complex scroll layouts
CustomScrollView(
  slivers: [
    SliverAppBar(...),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    ),
  ],
);

// ❌ Never use Column with SingleChildScrollView for long lists
// ❌ Never use ListView (non-builder) with many items
```

## Image Optimization

```dart
// Precache images before displaying
precacheImage(NetworkImage(url), context);

// Use cached_network_image for remote images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => const SkeletonBox(width: 100, height: 100),
  errorWidget: (_, __, ___) => const Icon(Icons.error),
  memCacheWidth: 200,  // resize in memory
);

// Resize assets to actual display size
Image.asset(
  'assets/hero.png',
  cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).toInt(),
);
```

## Memory Management

- `autoDispose` on Riverpod providers (default with codegen)
- `dispose()` all controllers, subscriptions, focus nodes in StatefulWidget
- Avoid closures that capture BuildContext across async gaps
- Use `ImageCache` for repeated images

## Isolates for Heavy Work

```dart
// Use compute() for CPU-bound operations
final result = await compute(parseJsonList, rawJsonString);

List<Item> parseJsonList(String jsonString) {
  final list = jsonDecode(jsonString) as List;
  return list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
}
```

## Profiling Commands

```bash
flutter run --profile        # Profile mode (real device performance)
flutter build --release      # Release mode for final testing
flutter run --trace-startup  # Trace startup performance
```

## Golden Rules

1. **60fps constant** — no frame drops during scroll or animation
2. **Fewer widgets in tree = better** — flatten where possible
3. **Never setState on large widgets** — use fine-grained providers/blocs
4. **async/await never blocks main isolate** — use Isolate for heavy work
5. **Measure before optimizing** — use DevTools, not intuition
