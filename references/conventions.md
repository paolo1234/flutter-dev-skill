# Coding Conventions Reference — Dart / Flutter

## Import Organization

Always order imports in these groups, separated by a blank line:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. External packages (alphabetical)
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Project internal (alphabetical by path)
import 'package:my_app/core/theme/app_theme.dart';
import 'package:my_app/features/auth/domain/models/user.dart';
```

## Widget Rules

### StatelessWidget (default)
```dart
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.onTap,
  });

  final String userName;
  final String avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // build() must be < 50 lines
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        title: Text(userName),
        onTap: onTap,
      ),
    );
  }
}
```

### ConsumerWidget (Riverpod)
```dart
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    return state.when(
      loading: () => const DashboardSkeleton(),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
      data: (data) => DashboardContent(data: data),
    );
  }
}
```

### StatefulWidget (only when needed)
Use ONLY for:
- AnimationController lifecycle
- TextEditingController / FocusNode lifecycle
- PageController / ScrollController lifecycle
- Local UI state that doesn't belong in a provider/bloc

```dart
class AnimatedCard extends StatefulWidget {
  const AnimatedCard({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }
}
```

## Null Safety Rules

1. **Never use `!`** unless you can mathematically prove it's non-null
2. **Prefer `?.` and `??`** over null checks
3. **Use `late` only** when initialization is deferred but guaranteed (e.g., `initState`)
4. **Declare types explicitly** for public APIs (avoid `var` in public interfaces)
5. **Use `required`** for non-optional parameters

```dart
// ✅ Good
final userName = user?.name ?? 'Anonymous';
final age = int.tryParse(input) ?? 0;

// ❌ Bad
final userName = user!.name;  // crashes if null
```

## Const Usage

Always use `const` when possible:

```dart
// ✅ const constructor
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  // ...
}

// ✅ const values
const defaultPadding = EdgeInsets.all(16);
const maxRetries = 3;
const animationDuration = Duration(milliseconds: 300);

// ✅ const in widget tree
return const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);
```

## Async/Await Rules

```dart
// ✅ Always handle errors
Future<void> fetchData() async {
  try {
    final result = await repository.getData();
    // handle success
  } on AppException catch (e) {
    // handle known errors
  } catch (e, stackTrace) {
    // handle unknown errors, log stackTrace
  }
}

// ✅ Use unawaited() for fire-and-forget
unawaited(analytics.logEvent('screen_view'));

// ❌ Never ignore futures
repository.getData(); // WARNING: future not awaited
```

## Documentation Rules

```dart
/// Brief one-line description.
///
/// Longer description if needed, explaining behavior,
/// edge cases, or important notes.
///
/// Example:
/// ```dart
/// final user = await fetchUser('123');
/// ```
///
/// Throws [AuthException] if the user is not authenticated.
/// Returns `null` if the user is not found.
Future<User?> fetchUser(String id) async { ... }
```

Document:
- All public classes and their purpose
- All public methods with parameters and return values
- Complex private methods
- Non-obvious business logic

## Git Conventions

### Branches
```
main                    # Production-ready code
develop                 # Integration branch
feature/[name]          # New feature (from develop)
fix/[name]              # Bug fix (from develop)
refactor/[name]         # Refactoring (from develop)
release/[x.y.z]         # Release preparation (from develop)
hotfix/[name]           # Production hotfix (from main)
```

### Commits (Conventional Commits)
```
feat(auth): add biometric login support
fix(home): prevent crash on empty data list
refactor(network): extract retry logic into interceptor
test(auth): add unit tests for token refresh flow
chore(deps): update flutter_riverpod to 2.5.0
docs(readme): add setup instructions for iOS
style(lint): apply dart format to all files
perf(list): implement lazy loading for image gallery
ci(github): add deploy workflow for TestFlight
```

### Commit Rules
1. One logical change per commit
2. Present tense, imperative mood: "add" not "added" or "adds"
3. Scope is the feature or component name
4. Body for complex changes: explain WHY, not just WHAT
5. Breaking changes: add `BREAKING CHANGE:` footer

## File Organization Within a File

```dart
// 1. Part directives (freezed, json_serializable)
part 'user_model.freezed.dart';
part 'user_model.g.dart';

// 2. Constants and enums
enum UserRole { admin, user, guest }

// 3. Main class/widget
class UserModel { ... }

// 4. Extension methods
extension UserModelX on UserModel { ... }

// 5. Helper functions (private)
String _formatUserName(String first, String last) { ... }
```

## Testing Naming Convention

```dart
void main() {
  group('UserRepository', () {
    group('fetchUser', () {
      test('returns user when API call succeeds', () async { ... });
      test('throws AuthException when token is expired', () async { ... });
      test('returns cached data when offline', () async { ... });
    });
    
    group('updateUser', () {
      test('updates user and invalidates cache', () async { ... });
    });
  });
}
```

Pattern: `[action] when [condition]` or `[returns/throws] [what] when [condition]`
