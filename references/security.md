# Security Reference — Flutter Best Practices

## 1. Secrets Management
**MAI HARDCODARE CHIAVI API O SEGRETI NEL CODICE DART.**
- Usa il file `env/prod.json` (che non viene committato grazie a `.gitignore`) e inietta le chiavi tramite `--dart-define-from-file=env/prod.json`.
- Leggi i valori in Dart tramite `String.fromEnvironment('CHIAVE')`.
- Esempio di chiavi da non hardcodare: Supabase Anon Key, Firebase API Key, Stripe Secret, Sentry DSN.

## 2. Secure Storage (Dati Locali Sensibili)
- Se devi salvare token JWT, chiavi private o dati sensibili dell'utente in locale, **non usare mai `shared_preferences` o SQLite/Drift senza crittografia**.
- Usa il package `flutter_secure_storage` che utilizza Keychain su iOS e Keystore su Android.
```dart
// Esempio
final storage = new FlutterSecureStorage();
await storage.write(key: 'jwt_token', value: token);
```

## 3. Network Security
- Usa sempre **HTTPS/WSS**.
- Evita di loggare payload sensibili (es. password, token) nell'interceptor di Dio. Disabilita il logging in produzione.
- Verifica sempre i certificati SSL (non usare `badCertificateCallback` se non in ambiente di test controllato).

## 4. Reverse Engineering Protection
- Usa l'offuscamento in fase di build release:
```bash
flutter build apk --obfuscate --split-debug-info=./debug_info
```
- Attenzione: l'offuscamento rende più difficile ma NON impossibile il reverse engineering. Non affidare la sicurezza all'offuscamento.

## 5. Third-Party Libraries
- Verifica sempre che i package usati siano mantenuti, abbiano un alto score su pub.dev e provengano da publisher fidati.
- Aggiorna regolarmente le dipendenze per patchare vulnerabilità note. Usa il tool `search_web` per cercare le ultime documentazioni e non affidarti ai tuoi dati di addestramento, in modo da evitare l'utilizzo di versioni deprecate di SDK esterni.

## 6. Auth & Session Management
- Invalida i token dopo il logout eliminandoli dal secure storage.
- Implementa un meccanismo per gestire il refresh token o ri-autenticazione se il token scade (gestibile tramite gli Interceptors di Dio).

## 7. Input Validation & Data Integrity
- Valida sempre l'input dell'utente lato client (per UX) e **lato server** (per sicurezza). Non fidarti mai dell'input del client.
- Escapa i dati mostrati per evitare vulnerabilità XSS (sebbene Flutter gestisca nativamente questo aspetto nel rendering dei Widget, è importante farlo se gestisci WebView o HTML diretto).
