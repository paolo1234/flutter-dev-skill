---
description: "Dart coding style conventions. Auto-loaded when working on .dart files."
paths: ["**/*.dart"]
---

# Dart Coding Style

## Naming Conventions
- **Files**: `snake_case.dart` (e.g., `login_page.dart`, `auth_repository.dart`)
- **Classes**: `PascalCase` (e.g., `LoginPage`, `AuthRepository`)
- **Variables/Functions**: `camelCase` (e.g., `userName`, `fetchData()`)
- **Constants**: `camelCase` (e.g., `maxRetries`, `defaultTimeout`)
- **Private members**: prefix with `_` (e.g., `_internalState`)
- **Enums**: `PascalCase` values (e.g., `AuthStatus.authenticated`)

## File Organization
1. Imports (dart:, package:, relative — separated by blank lines)
2. Part directives (if using code generation)
3. Constants
4. Main class/widget
5. Helper classes (private)

## Import Rules
- ALWAYS use package imports, never relative: `import 'package:my_app/features/auth/...'`
- Sort imports: `dart:` → `package:` (third-party) → `package:` (project)
- Never import from `lib/` with relative paths in cross-feature references

## Key Practices
- Use `const` constructors everywhere possible
- Prefer `final` over `var`
- Use trailing commas for better formatting
- Max file length: 800 lines. If exceeded → refactor into smaller files.
- Use `switch` expressions (Dart 3) over `if-else` chains for enum-based logic
- Never use `dynamic` unless absolutely required. Prefer typed alternatives.
- Use `sealed class` for state representations (e.g., `AuthState`)
