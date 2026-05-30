# Testing Reference — Unit, Widget, Integration Tests

## Test Structure

```
test/
├── core/
│   ├── network/
│   │   ├── dio_client_test.dart
│   │   └── error_interceptor_test.dart
│   └── utils/
│       └── validators_test.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_impl_test.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── user_test.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── login_page_test.dart
│   │       └── providers/
│   │           └── auth_provider_test.dart
│   └── [feature]/
│       └── ...
├── shared/
│   └── widgets/
│       ├── app_button_test.dart
│       └── empty_state_widget_test.dart
└── helpers/
    ├── mocks.dart                     # Shared mocks
    ├── test_helpers.dart              # Pump helpers
    └── fakes.dart                     # Fake implementations
```

## Unit Tests

### Model Tests (Freezed)
```dart
void main() {
  group('User', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': '123',
        'name': 'Mario Rossi',
        'email': 'mario@example.com',
        'role': 'admin',
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, '123');
      expect(user.name, 'Mario Rossi');
      expect(user.email, 'mario@example.com');
      expect(user.role, UserRole.admin);
    });

    test('toJson produces valid map', () {
      const user = User(
        id: '123',
        name: 'Mario Rossi',
        email: 'mario@example.com',
        role: UserRole.admin,
      );
      
      final json = user.toJson();
      
      expect(json['id'], '123');
      expect(json['name'], 'Mario Rossi');
    });

    test('copyWith creates modified copy', () {
      const user = User(id: '1', name: 'Mario', email: 'a@b.com');
      final updated = user.copyWith(name: 'Luigi');
      
      expect(updated.name, 'Luigi');
      expect(updated.id, '1'); // unchanged
    });

    test('equality works correctly', () {
      const user1 = User(id: '1', name: 'Mario', email: 'a@b.com');
      const user2 = User(id: '1', name: 'Mario', email: 'a@b.com');
      
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
```

### Repository Tests
```dart
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late ItemsRepositoryImpl repository;
  late MockDioClient mockDio;

  setUp(() {
    mockDio = MockDioClient();
    repository = ItemsRepositoryImpl(dioClient: mockDio);
  });

  group('ItemsRepository', () {
    group('fetchAll', () {
      test('returns list of items when API succeeds', () async {
        when(() => mockDio.get('/items')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            data: [
              {'id': '1', 'name': 'Item 1'},
              {'id': '2', 'name': 'Item 2'},
            ],
            statusCode: 200,
          ),
        );

        final items = await repository.fetchAll();
        
        expect(items, hasLength(2));
        expect(items.first.name, 'Item 1');
        verify(() => mockDio.get('/items')).called(1);
      });

      test('throws ServerException when API returns 500', () async {
        when(() => mockDio.get('/items')).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
            error: const ServerException(message: 'Server error'),
          ),
        );

        expect(
          () => repository.fetchAll(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws NetworkException when offline', () async {
        when(() => mockDio.get('/items')).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
            error: const NetworkException(message: 'No connection'),
          ),
        );

        expect(
          () => repository.fetchAll(),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}
```

### Provider/Notifier Tests (Riverpod)
```dart
void main() {
  group('AuthNotifier', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state is unauthenticated', () async {
      when(() => mockRepo.getStoredToken()).thenAnswer((_) async => null);
      
      final state = await container.read(authProvider.future);
      expect(state, isA<AuthStateUnauthenticated>());
    });

    test('login updates state to authenticated', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer(
        (_) async => const AuthResult(
          user: User(id: '1', name: 'Test'),
          token: 'token123',
        ),
      );

      await container.read(authProvider.notifier).login('a@b.com', 'pass');
      
      final state = await container.read(authProvider.future);
      expect(state, isA<AuthStateAuthenticated>());
    });
  });
}
```

## Widget Tests

### Testing All UI States
```dart
void main() {
  group('ItemsPage', () {
    testWidgets('shows skeleton loader while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemsProvider.overrideWith((ref) {
              // Return a provider that stays in loading state
              return Future.delayed(
                const Duration(seconds: 10),
                () => <Item>[],
              );
            }),
          ],
          child: const MaterialApp(home: ItemsPage()),
        ),
      );

      expect(find.byType(ItemsSkeleton), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemsProvider.overrideWith(
              (ref) => throw const NetworkException(message: 'No connection'),
            ),
          ],
          child: const MaterialApp(home: ItemsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Riprova'), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemsProvider.overrideWith((ref) async => <Item>[]),
          ],
          child: const MaterialApp(home: ItemsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nessun elemento'), findsOneWidget);
    });

    testWidgets('shows list when data is available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemsProvider.overrideWith((ref) async => [
              const Item(id: '1', name: 'First Item'),
              const Item(id: '2', name: 'Second Item'),
            ]),
          ],
          child: const MaterialApp(home: ItemsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First Item'), findsOneWidget);
      expect(find.text('Second Item'), findsOneWidget);
    });
  });
}
```

### Testing User Interactions
```dart
testWidgets('tapping delete shows confirmation dialog', (tester) async {
  await tester.pumpWidget(/* setup */);
  await tester.pumpAndSettle();

  // Long press to show context menu
  await tester.longPress(find.text('First Item'));
  await tester.pumpAndSettle();

  // Tap delete
  await tester.tap(find.text('Elimina'));
  await tester.pumpAndSettle();

  // Confirmation dialog appears
  expect(find.text('Conferma eliminazione'), findsOneWidget);
  expect(find.text('Annulla'), findsOneWidget);
  expect(find.text('Elimina'), findsNWidgets(2)); // button + dialog
});

testWidgets('form shows validation errors', (tester) async {
  await tester.pumpWidget(/* setup with LoginPage */);
  
  // Tap submit without entering anything
  await tester.tap(find.text('Accedi'));
  await tester.pumpAndSettle();

  expect(find.text('Email obbligatoria'), findsOneWidget);
  expect(find.text('Password obbligatoria'), findsOneWidget);
});
```

## Test Helpers

```dart
// test/helpers/test_helpers.dart

/// Wraps a widget with MaterialApp and ProviderScope for testing
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
  GoRouter? router,
}) {
  if (router != null) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

/// Creates a mock GoRouter for testing navigation
GoRouter createMockRouter(Widget page) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => page),
    ],
  );
}
```

## Mocking Setup (mocktail)

```yaml
dev_dependencies:
  mocktail: ^1.0.4
```

```dart
// test/helpers/mocks.dart
import 'package:mocktail/mocktail.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockDioClient extends Mock implements DioClient {}

// Register fallback values for complex types
void setUpFallbacks() {
  registerFallbackValue(const CreateItemRequest(name: '', description: ''));
  registerFallbackValue(RequestOptions());
}
```

## Coverage

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Check minimum coverage
flutter test --coverage --min-coverage 80
```

## Best Practices

1. **Test behavior, not implementation** — test what the user sees, not internal details
2. **One assertion per test** (when possible) — makes failures clear
3. **Test all 4 states** for every screen: loading, error, empty, data
4. **Use `pumpAndSettle()`** after actions that trigger animations
5. **Mock external boundaries** (API, DB), not internal logic
6. **Name tests clearly**: `[action] when [condition]` pattern
7. **Use `group()`** to organize related tests
8. **Shared setup** in `setUp()` and `tearDown()`
9. **Golden tests** for critical UI (optional, for regression detection)
