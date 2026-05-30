# UX Patterns Reference — Empty States, Skeletons, Offline, Haptics

## Empty States

Every screen MUST handle the empty state — never show a blank page.

### Pattern
```dart
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Empty State Examples
| Screen | Icon | Title | Subtitle | Action |
|---|---|---|---|---|
| Lista vuota | inbox_outlined | "Nessun elemento" | "Aggiungi il tuo primo elemento" | "Aggiungi" |
| Ricerca senza risultati | search_off | "Nessun risultato" | "Prova con termini diversi" | — |
| Notifiche vuote | notifications_none | "Tutto tranquillo" | "Non hai notifiche" | — |
| Preferiti vuoti | favorite_border | "Nessun preferito" | "Salva i tuoi elementi preferiti" | "Esplora" |

---

## Skeleton Loaders (Shimmer)

**Never use a bare `CircularProgressIndicator`** as the only loading indicator. Use skeleton loaders that mirror the layout of the actual content.

### Setup
```yaml
dependencies:
  shimmer: ^3.0.0
```

### Base Skeleton Widget
```dart
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
```

### List Skeleton
```dart
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _ListItemSkeleton(),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SkeletonBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: MediaQuery.sizeOf(context).width * 0.4, height: 16),
                const SizedBox(height: 8),
                SkeletonBox(width: MediaQuery.sizeOf(context).width * 0.6, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Card Grid Skeleton
```dart
class CardGridSkeleton extends StatelessWidget {
  const CardGridSkeleton({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}
```

---

## Error State Widget

```dart
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## AsyncValue Helper (Riverpod)

```dart
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: loading ?? () => const Center(child: CircularProgressIndicator()),
      error: error ?? (e, _) => ErrorStateWidget(message: e.toString()),
      data: data,
    );
  }
}
```

---

## Haptic Feedback

```dart
import 'package:flutter/services.dart';

class HapticUtils {
  /// Light tap feedback — for button presses, selections
  static void lightTap() => HapticFeedback.lightImpact();

  /// Medium feedback — for toggle switches, drag end
  static void mediumTap() => HapticFeedback.mediumImpact();

  /// Heavy feedback — for destructive actions, errors
  static void heavyTap() => HapticFeedback.heavyImpact();

  /// Selection feedback — for picker changes, segment control
  static void selection() => HapticFeedback.selectionClick();

  /// Success feedback — for completed actions
  static void success() => HapticFeedback.mediumImpact();

  /// Error feedback — for failed validations
  static void error() => HapticFeedback.heavyImpact();
}
```

### When to use haptics:
- ✅ Button taps (lightTap)
- ✅ Toggle switches (mediumTap)
- ✅ Swipe to delete confirmation (heavyTap)
- ✅ Pull-to-refresh activation (lightTap)
- ✅ Successful action (success)
- ✅ Form validation error (error)
- ✅ Long press menu appears (mediumTap)
- ❌ Every scroll event
- ❌ Keyboard typing
- ❌ Page transitions

---

## Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    HapticUtils.lightTap();
    ref.invalidate(itemsProvider);
    // Wait for the new data
    await ref.read(itemsProvider.future);
  },
  child: ListView.builder(...),
);
```

---

## Offline Strategy Patterns

### Pattern 1: Cache-First (recommended for read-heavy apps)
```
1. Load from cache immediately (instant UI)
2. Fetch from network in background
3. Update cache + UI when network responds
4. Show "offline" indicator if network fails
```

### Pattern 2: Network-First (for real-time data)
```
1. Try network first
2. If network fails, load from cache
3. Show "offline mode" indicator
4. Auto-retry when connectivity returns
```

### Pattern 3: Offline-First (for apps that must work offline)
```
1. All writes go to local DB first
2. Background sync queue pushes to server
3. Conflict resolution strategy (last-write-wins / merge)
4. Sync status indicator per item
```

### Connectivity Banner
```dart
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 28,
          color: Theme.of(context).colorScheme.errorContainer,
          child: isOnline
              ? const SizedBox.shrink()
              : Center(
                  child: Text(
                    'Modalità offline — le modifiche verranno sincronizzate',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
```

---

## Confirmation Patterns

### Destructive Actions — Always Confirm
```dart
Future<bool> showDeleteConfirmation(BuildContext context, String itemName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Conferma eliminazione'),
      content: Text('Sei sicuro di voler eliminare "$itemName"? Questa azione non può essere annullata.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Elimina'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

### Undo Pattern — SnackBar with Undo
```dart
void deleteItemWithUndo(BuildContext context, WidgetRef ref, Item item) {
  // Optimistic delete
  ref.read(itemsProvider.notifier).removeItem(item.id);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('"${item.name}" eliminato'),
      action: SnackBarAction(
        label: 'Annulla',
        onPressed: () {
          ref.read(itemsProvider.notifier).restoreItem(item);
        },
      ),
      duration: const Duration(seconds: 5),
    ),
  );
  
  // After snackbar duration, permanently delete
  Future.delayed(const Duration(seconds: 6), () {
    ref.read(itemsProvider.notifier).confirmDelete(item.id);
  });
}
```

---

## Search UX

```dart
class SearchDelegate {
  // Debounce: 300ms after user stops typing
  static const searchDebounce = Duration(milliseconds: 300);
  
  // Minimum characters before searching
  static const minSearchLength = 2;
  
  // Show "recent searches" when search bar is focused but empty
  // Show "suggestions" while typing (< minSearchLength chars)
  // Show results when >= minSearchLength chars AND debounce elapsed
  // Show "no results" with suggestions when query returns empty
}
```

## Form UX Rules

1. **Real-time validation**: Validate on `onChanged` after first submit attempt, not before
2. **Next field focus**: Use `FocusNode` + `TextInputAction.next` to move between fields
3. **Submit on keyboard**: Last field uses `TextInputAction.done` and triggers form submit
4. **Dismiss keyboard**: Tap outside form area dismisses keyboard (`GestureDetector` + `FocusScope.unfocus`)
5. **Loading on submit**: Disable all fields + show loading indicator on submit button
6. **Error display**: Inline errors under each field, not a summary at top
