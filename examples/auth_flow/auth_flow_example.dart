// Esempio completo di un flusso di autenticazione con Riverpod e Dio
// Include: LoginPage, AuthNotifier, AuthRepository, AuthInterceptor

// Per un'implementazione completa basata su questo flow,
// usa i template in templates/feature/ e segui i reference
// in references/state_management.md e references/networking.md.

// Questo file serve solo come riferimento visivo di come i vari
// componenti interagiscono tra loro.

/*
// 1. Il Notifier (State Management)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    final token = await ref.watch(tokenStorageProvider).getToken();
    if (token != null) {
      final user = await ref.watch(authRepositoryProvider).getCurrentUser();
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
}

// 2. La UI (LoginPage)
class LoginPage extends ConsumerStatefulWidget { ... }

// 3. Il Repository (AuthRepositoryImpl)
class AuthRepositoryImpl implements AuthRepository {
  Future<AuthResult> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResult.fromJson(response.data);
  }
}
*/
