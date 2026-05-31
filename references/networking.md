# Networking Reference — Dio, Interceptors, JWT, Error Handling

## Security: Certificate Pinning

Il certificate pinning previene attacchi Man-in-the-Middle (MitM). **Attivo solo in produzione.**

```dart
class CertificatePinningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Il pinning è gestito a livello HttpClient, non interceptor
    handler.next(options);
  }
}

// Configurazione nel DioClient
Dio createDioWithPinning({
  required String baseUrl,
  required bool enablePinning,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  if (enablePinning) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Verifica l'impronta SHA-256 del certificato atteso
        return _verifyFingerprint(cert, host);
      };
      return client;
    };
  } else {
    // Development: permetti self-signed (non rallentare hot-reload)
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (_, __, ___) => true;
      return client;
    };
  }

  return dio;
}

bool _verifyFingerprint(X509Certificate cert, String host) {
  // Recupera fingerprint attesa dalla configurazione
  // const expectedPins = {'api.example.com': 'sha256/...'};
  // Implementazione specifica per dominio
  return false; // Blocca se non corrisponde
}
```

## Security: Prevenzione SSRF (Lato Backend)

```dart
// Usa questo validator prima di fare richieste HTTP a URL forniti dall'utente
class SsrfValidator {
  static const _blockedIpRanges = [
    '127.0.0.1',
    '169.254.169.254',  // Metadata cloud
    '10.',
    '172.16.',
    '192.168.',
    '0.0.0.0',
    '::1',
  ];

  static const _allowedDomains = <String>{
    'api.github.com',
    'cdn.example.com',
  };

  static bool isAllowed(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return false;
    if (uri.scheme != 'https') return false; // Solo HTTPS

    final host = uri.host.toLowerCase();
    if (_blockedIpRanges.any((ip) => host.startsWith(ip))) return false;
    if (_allowedDomains.isNotEmpty && !_allowedDomains.contains(host)) return false;

    return true;
  }
}
```

## Dio Client Setup

```dart
import 'package:dio/dio.dart';

class DioClient {
  DioClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    required bool isDev,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage: tokenStorage, dio: _dio),
      ErrorInterceptor(),
      LoggingInterceptor(isDev: isDev),
    ]);
  }

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.patch<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.delete<T>(path, data: data, options: options);
  }
}
```

## Auth Interceptor (JWT)

```dart
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
  });

  final TokenStorage tokenStorage;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      try {
        final refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          return handler.reject(err);
        }

        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
          options: Options(
            headers: {'Authorization': ''},  // No auth for refresh
          ),
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;
        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry the original request
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } on DioException {
        // Refresh failed — force logout
        await tokenStorage.clearTokens();
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
}
```

## Error Interceptor

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connessione lenta. Riprova tra qualche istante.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Impossibile connettersi al server. Controlla la tua connessione.',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Richiesta annullata.',
          code: 'CANCELLED',
        );
      default:
        return const UnknownException();
    }
  }

  AppException _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;
    final serverMessage = data is Map ? data['message'] as String? : null;

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: serverMessage ?? 'Dati non validi. Controlla e riprova.',
          code: 'BAD_REQUEST',
          errors: _extractFieldErrors(data),
        );
      case 401:
        return AuthException(
          message: serverMessage ?? 'Sessione scaduta. Effettua nuovamente il login.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return AuthException(
          message: serverMessage ?? 'Non hai i permessi per questa azione.',
          code: 'FORBIDDEN',
        );
      case 404:
        return ServerException(
          message: serverMessage ?? 'Risorsa non trovata.',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      case 409:
        return ServerException(
          message: serverMessage ?? 'Conflitto: la risorsa è stata modificata.',
          code: 'CONFLICT',
          statusCode: 409,
        );
      case 422:
        return ValidationException(
          message: serverMessage ?? 'Dati non processabili.',
          code: 'UNPROCESSABLE',
          errors: _extractFieldErrors(data),
        );
      case 429:
        return ServerException(
          message: 'Troppe richieste. Riprova tra qualche istante.',
          code: 'RATE_LIMITED',
          statusCode: 429,
        );
      case >= 500:
        return ServerException(
          message: 'Errore del server. Il team è stato avvisato.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
      default:
        return UnknownException(
          message: serverMessage ?? 'Errore sconosciuto (codice: $statusCode)',
        );
    }
  }

  Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is! Map) return null;
    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        (value is List) ? value.map((e) => e.toString()).toList() : [value.toString()],
      ),
    );
  }
}
```

## Logging Interceptor (Security-Safe)

> **Mai loggare payload con password, token JWT o dati personali in produzione.**
> In produzione logga solo metodo, status code, URI — MAI il body.

```dart
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required this.isDev});

  final bool isDev;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isDev) {
      // Produzione: solo metodo e URI, niente body
      debugPrint('→ ${options.method} ${options.uri}');
      handler.next(options);
      return;
    }

    // Development: logga tutto
    debugPrint('→ ${options.method} ${options.uri}');
    if (options.data != null) {
      final sanitized = _sanitizeSensitiveData(options.data);
      debugPrint('  Body: $sanitized');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✖ ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.uri}');
    if (isDev) {
      debugPrint('  Error: ${err.message}');
    }
    handler.next(err);
  }

  /// Oscura campi sensibili nei log
  dynamic _sanitizeSensitiveData(dynamic data) {
    if (data is Map) {
      final sensitiveKeys = {'password', 'token', 'secret', 'jwt', 'credit_card', 'ssn'};
      return data.map((key, value) {
        if (sensitiveKeys.any((s) => key.toString().toLowerCase().contains(s))) {
          return MapEntry(key, '***');
        }
        return MapEntry(key, _sanitizeSensitiveData(value));
      });
    }
    return data;
  }
}
```

## Connectivity Service

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final connected = results.any((r) => r != ConnectivityResult.none);
    if (connected != _isConnected) {
      _isConnected = connected;
      _controller.add(connected);
    }
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    return _isConnected;
  }

  void dispose() {
    _controller.close();
  }
}
```

## Token Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
```

## Repository Pattern with Error Handling

```dart
class ItemsRepositoryImpl implements ItemsRepository {
  ItemsRepositoryImpl({required this.dioClient, this.localDatasource});

  final DioClient dioClient;
  final ItemsLocalDatasource? localDatasource;

  @override
  Future<List<Item>> fetchAll() async {
    try {
      final response = await dioClient.get('/items');
      final items = (response.data as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Cache locally
      await localDatasource?.cacheItems(items);
      return items;
    } on DioException catch (e) {
      // If offline, try cache
      if (e.error is NetworkException && localDatasource != null) {
        final cached = await localDatasource!.getCachedItems();
        if (cached.isNotEmpty) return cached;
      }
      throw e.error as AppException? ?? const UnknownException();
    }
  }

  @override
  Future<Item> create(CreateItemRequest request) async {
    try {
      final response = await dioClient.post('/items', data: request.toJson());
      return Item.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const UnknownException();
    }
  }
}
```
