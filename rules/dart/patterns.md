---
description: "Flutter patterns for state management, navigation, and architecture."
paths: ["**/*.dart", "**/pubspec.yaml"]
---

# Flutter Patterns

## Architecture: Feature-First Clean Architecture
```
lib/features/<feature_name>/
├── data/
│   ├── datasources/    # Remote/Local data sources
│   └── repositories/   # Repository implementations
├── domain/
│   ├── models/         # Data models (freezed)
│   └── repositories/   # Repository interfaces (abstract)
└── presentation/
    ├── pages/          # Full-screen widgets
    ├── widgets/        # Reusable UI components
    └── providers/      # Riverpod providers (or blocs/)
```

## Riverpod Patterns
- Use `@riverpod` annotation (codegen) for all providers
- Use `AsyncNotifier` for stateful async operations (CRUD)
- Use `FutureProvider` for read-only async data
- Always handle `AsyncValue` states: `.when(loading:, error:, data:)`
- Use `autoDispose` (default with codegen) to prevent memory leaks
- Use `ref.invalidate()` to force refresh, not manual state manipulation
- Test providers with `ProviderContainer` and `overrides`

## BLoC Patterns (if chosen)
- One BLoC per feature/screen, not one global BLoC
- Events are `sealed class`, States are `sealed class`
- Use `Cubit` for simple state (no events needed)
- Use `BlocObserver` for global logging in dev mode

## GoRouter Patterns
- `context.go()` for tab navigation and auth redirects (replaces stack)
- `context.push()` for drill-down navigation (adds to stack)
- `context.pop()` to go back
- Use `StatefulShellRoute.indexedStack` for bottom navigation (preserves tab state)
- Auth guard via `redirect:` parameter, never in individual pages
- Always provide `errorBuilder` for 404 pages
- Use path parameters for IDs, query parameters for optional filters
- Never rely on `extra` for data needed in deep links

## Error Handling Pattern
- Define `AppException` as sealed class with typed variants
- Map all external errors (Dio, Firebase, etc.) to `AppException` in repository layer
- Never expose raw exceptions to UI — always map to user-friendly messages
- Use `Result<T>` or `Either<Failure, T>` pattern in repositories if preferred
