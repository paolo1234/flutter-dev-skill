# Navigation Reference — GoRouter Advanced Patterns

## Setup

```yaml
dependencies:
  go_router: ^14.8.1
```

## Basic Router Configuration

```dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  redirect: _authGuard,
  errorBuilder: (context, state) => const NotFoundPage(),
  routes: [
    // Splash / Auth flow
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return DetailPage(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // Settings (outside shell — no bottom nav)
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationSettingsPage(),
        ),
        GoRoute(
          path: 'theme',
          builder: (context, state) => const ThemeSettingsPage(),
        ),
      ],
    ),
  ],
);
```

## App Shell with Bottom Navigation

```dart
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Cerca',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
```

## Auth Guard (Redirect)

```dart
String? _authGuard(BuildContext context, GoRouterState state) {
  final isLoggedIn = /* read auth state */;
  final isOnAuthPage = state.matchedLocation == '/login' ||
      state.matchedLocation == '/register' ||
      state.matchedLocation == '/onboarding';
  final isSplash = state.matchedLocation == '/';

  // Allow splash always
  if (isSplash) return null;

  // Not logged in and trying to access protected page
  if (!isLoggedIn && !isOnAuthPage) return '/login';

  // Logged in and trying to access auth page
  if (isLoggedIn && isOnAuthPage) return '/home';

  return null; // No redirect
}
```

### Auth Guard with Riverpod

```dart
// In router provider
@riverpod
GoRouter appRouter(ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
      // ... same redirect logic
    },
    routes: [ ... ],
  );
}
```

## Custom Page Transitions

```dart
GoRoute(
  path: '/detail/:id',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: DetailPage(id: state.pathParameters['id']!),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  },
);
```

## Route Names (Type-Safe)

```dart
class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const detail = '/home/detail';
  static const search = '/search';
  static const profile = '/profile';
  static const settings = '/settings';
}

// Usage
context.go(RouteNames.home);
context.go('${RouteNames.detail}/$itemId');
context.push(RouteNames.settings);
```

## Navigation Patterns

### go vs push
- `context.go('/path')` — Replaces the stack (use for tab navigation, auth redirects)
- `context.push('/path')` — Pushes on stack (use for drill-down navigation)
- `context.pop()` — Goes back one level

### Passing Data
```dart
// Path parameters (for IDs)
GoRoute(
  path: 'detail/:id',
  builder: (context, state) => DetailPage(id: state.pathParameters['id']!),
);
context.go('/home/detail/123');

// Query parameters (for filters)
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    return SearchPage(initialQuery: query);
  },
);
context.go('/search?q=flutter');

// Extra (for complex objects — not deep-linkable)
context.push('/detail', extra: myItemObject);
final item = GoRouterState.of(context).extra as Item;
```

## Deep Linking

GoRouter supports deep linking natively. Ensure:
1. All routes have meaningful paths
2. Route parameters are strings (IDs, slugs)
3. Don't rely on `extra` for critical data (it's lost on deep link)
4. Configure iOS Universal Links and Android App Links in native config

## Best Practices

1. All routes defined in ONE file (`app_router.dart`)
2. Use `StatefulShellRoute` for bottom navigation (preserves state per tab)
3. Use path parameters for IDs, query parameters for optional filters
4. Use `redirect` for auth guard — never check auth in individual pages
5. Always provide an `errorBuilder` for 404
6. Use named routes constants for type safety
7. `context.go` for tab switches, `context.push` for detail drill-down
