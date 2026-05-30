# State Management Reference — Riverpod & BLoC

## Riverpod (Recommended Default)

### Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.13
  riverpod_lint: ^2.6.3
```

### Provider Types (Code Generation — Preferred)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

// Simple synchronous provider (replaces Provider)
@riverpod
UserRepository userRepository(ref) {
  return UserRepositoryImpl(ref.watch(dioClientProvider));
}

// Async data fetching (replaces FutureProvider)
@riverpod
Future<List<User>> userList(ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.fetchAll();
}

// Async with parameter (replaces FutureProvider.family)
@riverpod
Future<User> userDetail(ref, {required String userId}) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getById(userId);
}

// Stream (replaces StreamProvider)
@riverpod
Stream<List<Message>> messages(ref) {
  return ref.watch(chatServiceProvider).messageStream;
}
```

### Notifier (Code Generation — replaces StateNotifier)

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    // Initial state — check if user is logged in
    final token = await ref.watch(tokenStorageProvider).getToken();
    if (token != null) {
      final user = await ref.watch(userRepositoryProvider).getCurrentUser();
      return AuthState.authenticated(user: user);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(tokenStorageProvider).saveToken(result.token);
      return AuthState.authenticated(user: result.user);
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearToken();
    state = const AsyncData(AuthState.unauthenticated());
  }
}
```

### autoDispose Behavior

With code generation, ALL providers are `autoDispose` by default.

```dart
// autoDispose (default) — provider is destroyed when no longer listened to
@riverpod
Future<List<Item>> items(ref) async { ... }

// keepAlive — provider persists even when no longer listened to
@Riverpod(keepAlive: true)
Future<AppConfig> appConfig(ref) async { ... }
```

Use `keepAlive: true` only for:
- App-wide configuration
- Auth state
- Cache that should persist across navigation
- Database connections

### Widget Usage

```dart
// ConsumerWidget — most common
class ItemsPage extends ConsumerWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    
    return itemsAsync.when(
      loading: () => const ItemsSkeleton(),
      error: (error, _) => ErrorStateWidget(
        message: _mapErrorToMessage(error),
        onRetry: () => ref.invalidate(itemsProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'Nessun elemento',
              subtitle: 'Aggiungi il tuo primo elemento',
            )
          : ItemsList(items: items),
    );
  }
}

// ConsumerStatefulWidget — when you need StatefulWidget + Riverpod
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_searchController.text));
    // ...
  }
}
```

### Rules
1. `ref.watch` in `build()` — reactive updates
2. `ref.read` in callbacks (`onPressed`, `onTap`) — one-time reads
3. `ref.listen` for side effects (show snackbar, navigate)
4. `ref.invalidate` to force refresh
5. Never store `ref` in a variable outside build context

### Testing with Riverpod

```dart
void main() {
  group('ItemsProvider', () {
    test('returns items from repository', () async {
      final container = ProviderContainer(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(MockItemsRepository()),
        ],
      );
      addTearDown(container.dispose);

      final items = await container.read(itemsProvider.future);
      expect(items, hasLength(3));
    });
  });

  testWidgets('ItemsPage shows loading then data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsProvider.overrideWith((ref) async {
            return [Item(id: '1', name: 'Test')];
          }),
        ],
        child: const MaterialApp(home: ItemsPage()),
      ),
    );

    // Initially shows loading
    expect(find.byType(ItemsSkeleton), findsOneWidget);
    
    // After loading completes
    await tester.pumpAndSettle();
    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## BLoC / Cubit (Alternative)

### Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^9.0.0
  bloc: ^9.0.0
  equatable: ^2.0.7

dev_dependencies:
  bloc_test: ^10.0.0
```

### Cubit (Simpler — recommended for most cases)

```dart
// State
@freezed
class ItemsState with _$ItemsState {
  const factory ItemsState.initial() = _Initial;
  const factory ItemsState.loading() = _Loading;
  const factory ItemsState.loaded({required List<Item> items}) = _Loaded;
  const factory ItemsState.error({required String message}) = _Error;
}

// Cubit
class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.repository}) : super(const ItemsState.initial());

  final ItemsRepository repository;

  Future<void> loadItems() async {
    emit(const ItemsState.loading());
    try {
      final items = await repository.fetchAll();
      emit(ItemsState.loaded(items: items));
    } on AppException catch (e) {
      emit(ItemsState.error(message: e.message));
    }
  }

  Future<void> deleteItem(String id) async {
    final currentItems = state.maybeMap(
      loaded: (s) => s.items,
      orElse: () => <Item>[],
    );
    // Optimistic update
    emit(ItemsState.loaded(
      items: currentItems.where((i) => i.id != id).toList(),
    ));
    try {
      await repository.delete(id);
    } on AppException catch (e) {
      // Rollback
      emit(ItemsState.loaded(items: currentItems));
      emit(ItemsState.error(message: e.message));
    }
  }
}
```

### BLoC (Event-driven — for complex flows)

```dart
// Events
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = _LoginRequested;
  const factory AuthEvent.logoutRequested() = _LogoutRequested;
  const factory AuthEvent.tokenRefreshRequested() = _TokenRefreshRequested;
}

// State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({required User user}) = _Authenticated;
  const factory AuthState.unauthenticated({String? errorMessage}) = _Unauthenticated;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authRepository}) : super(const AuthState.initial()) {
    on<_LoginRequested>(_onLoginRequested);
    on<_LogoutRequested>(_onLogoutRequested);
    on<_TokenRefreshRequested>(_onTokenRefresh);
  }

  final AuthRepository authRepository;

  Future<void> _onLoginRequested(
    _LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthState.authenticated(user: user));
    } on AppException catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.message));
    }
  }

  Future<void> _onLogoutRequested(
    _LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onTokenRefresh(
    _TokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.refreshToken();
    } on AuthException {
      emit(const AuthState.unauthenticated(
        errorMessage: 'Sessione scaduta, effettua nuovamente il login',
      ));
    }
  }
}
```

### Widget Usage (BLoC)

```dart
class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const ItemsSkeleton(),
          loaded: (items) => items.isEmpty
              ? const EmptyStateWidget(...)
              : ItemsList(items: items),
          error: (message) => ErrorStateWidget(
            message: message,
            onRetry: () => context.read<ItemsCubit>().loadItems(),
          ),
        );
      },
    );
  }
}

// For side effects (navigation, snackbar)
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    state.maybeWhen(
      unauthenticated: (error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
        context.go('/login');
      },
      orElse: () {},
    );
  },
  child: child,
);
```

### BLoC Dependency Injection

```dart
// Using Provider for DI with BLoC
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => AuthBloc(
        authRepository: context.read<AuthRepository>(),
      ),
    ),
    BlocProvider(
      create: (context) => ItemsCubit(
        repository: context.read<ItemsRepository>(),
      )..loadItems(),
    ),
  ],
  child: const App(),
);
```

### Testing BLoC

```dart
void main() {
  group('ItemsCubit', () {
    late ItemsCubit cubit;
    late MockItemsRepository mockRepo;

    setUp(() {
      mockRepo = MockItemsRepository();
      cubit = ItemsCubit(repository: mockRepo);
    });

    tearDown(() => cubit.close());

    blocTest<ItemsCubit, ItemsState>(
      'emits [loading, loaded] when loadItems succeeds',
      build: () {
        when(() => mockRepo.fetchAll()).thenAnswer(
          (_) async => [Item(id: '1', name: 'Test')],
        );
        return cubit;
      },
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        const ItemsState.loading(),
        ItemsState.loaded(items: [Item(id: '1', name: 'Test')]),
      ],
    );

    blocTest<ItemsCubit, ItemsState>(
      'emits [loading, error] when loadItems fails',
      build: () {
        when(() => mockRepo.fetchAll()).thenThrow(
          const NetworkException(message: 'No connection'),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        const ItemsState.loading(),
        const ItemsState.error(message: 'No connection'),
      ],
    );
  });
}
```

---

## When to Choose What

| Scenario | Recommendation | Why |
|---|---|---|
| New project, small-medium team | **Riverpod** | Less boilerplate, code-gen, type-safe |
| Enterprise, large team | **BLoC** | Clear patterns, enforced structure |
| Complex event-driven flows | **BLoC** (full) | Event/State separation |
| Simple state with async | **Riverpod** or **Cubit** | Minimal boilerplate |
| Real-time data (streams) | Both work well | Riverpod StreamProvider or BLoC streams |
| Need granular rebuild control | **Riverpod** | select/family/autoDispose |
