# Security Compliance Checklist

> Usa questa checklist per verificare che tutte le regole di sicurezza siano rispettate.
> **Esegui sempre prima di ogni release production.**
> Ogni item può essere verificato con un comando o un'ispezione del codice.

---

## Come Usare

```
flutter pub run build_runner build  # Prima genera tutto
dart run security_check.dart        # Poi esegui lo scanner (se implementato)
```

Oppure usa questa checklist manuale per audit completi.

---

## ✅ Compliance Scanner — Comandi di Verifica

### 1. CLIENT FLUTTER

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 1.1 | Nessun segreto hardcodato | Cerca pattern `static const.*key`, `static const.*secret`, `static const.*token` | `rg -n "static const.*(key|secret|token|api)" lib/` — dovrebbe dare 0 risultati |
| 1.2 | Usa `--dart-define-from-file` | Cerca `String.fromEnvironment` o `bool.fromEnvironment` in `lib/core/env/` | `rg -c "fromEnvironment" lib/core/env/` — almeno 3 chiamate |
| 1.3 | SecureStorage per token | Verifica `FlutterSecureStorage` usato per token JWT | `rg "FlutterSecureStorage" lib/` — presente |
| 1.4 | NO SharedPreferences per dati sensibili | Cerca pattern pericolosi | `rg "SharedPreferences" lib/` — solo per settings UI, non per token |
| 1.5 | Flutter Web: no token in LocalStorage | Controlla che su Web si usino cookie HttpOnly | Verifica nella documentazione o `rg "LocalStorage\|window.localStorage" lib/` |
| 1.6 | ProGuard/R8 in release | Controlla `android/app/build.gradle` | `rg "minifyEnabled true" android/app/build.gradle` |
| 1.7 | Obfuscation in release build | Controlla comandi di build | `rg "obfuscate\|split-debug-info"` nei docs/scripts |
| 1.8 | Validazione client solo per UX | Verifica che non ci sia logica di sicurezza in UI | Ispezione manuale: `rg "validate\|validator" lib/features/*/presentation/` |
| 1.9 | Certificate pinning attivo in prod | Cerca `badCertificateCallback` con controllo env | `rg "badCertificateCallback\|certificatePinning" lib/` |
| 1.10 | Deep link validation | Cerca validazione parametri in ingresso | `rg "handleDeepLink\|deepLink\|app_links\|go_router" lib/` |
| 1.11 | CSP header per Flutter Web | Controlla configurazione nginx/server | `rg "Content-Security-Policy\|frame-ancestors"` in file di deploy |

### 2. BACKEND E API

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 2.1 | Prevenzione SSRF | Whitelist domini + blocco IP interni | `rg "allowedDomains\|blockedIps\|ssrf\|isValidUrl"` — presente |
| 2.2 | Upload file: magic bytes | Verifica controllo magic bytes (non MIME dichiarato) | `rg "magicBytes\|_detectMimeFromBytes\|fileSignature"` |
| 2.3 | Upload file: rename con hash | Rinominare file con hash randomico | `rg "sha256\|randomName\|hash.*\.\w+$"` in upload logic |
| 2.4 | Upload file: CDN separato | File serviti da dominio diverso | Verifica configurazione storage/CDN |
| 2.5 | ReDoS protection | Timeout per regex | `rg "timeout.*RegExp\|RegExp.*timeout\|safeRegex"` |
| 2.6 | Rate limiting attivo | Controlla configurazione | `rg "rateLimit\|RateLimit\|throttle\|Throttle"` |
| 2.7 | Rate limiting: disabilitato in dev | Controlla che sia condizionale all'env | `rg "EnvConfig.isProd"` in rate limit config |

### 3. DATABASE (Supabase/PostgreSQL)

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 3.1 | RLS attivo su tutte le tabelle | Verifica policy SQL | Controlla file `.sql` o Supabase dashboard |
| 3.2 | Policy RLS con privilegio minimo | `user_id = auth.uid()` in ogni policy | `rg "auth.uid()"` — almeno una per tabella |
| 3.3 | Service Role key isolata | MAI nel client Flutter | `rg "service_role\|serviceRole\|SUPABASE_SERVICE_KEY" lib/` — 0 risultati |
| 3.4 | Proiezioni esplicite (no SELECT *) | Nessun `select('*')` | `rg "\.select\('\\*'\)" lib/` — 0 risultati |
| 3.5 | Filtri sanitizzati | Whitelist campi filtrabili | `rg "allowedFilters\|allowedColumns\|sanitizeFilter"` |

### 4. AI E LLM

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 4.1 | Proxy backend per API AI | Flutter chiama backend, non AI diretto | `rg "openai\|anthropic\|claude\|chatgpt" lib/` — 0 risultati |
| 4.2 | Prompt injection mitigation | Delimitazione dati utente (XML tags) | `rg "<SISTEMA>\|<UTENTE>\|system.*instruction\|user.*input.*separator"` |
| 4.3 | Data leakage prevention | Output filter prima di tornare al client | `rg "safeLlmResponse\|sanitize.*output\|filter.*response"` |
| 4.4 | Denial of Wallet (DoW) | Hard cap giornaliero richieste AI | `rg "MAX_DAILY\|rateLimit\|usage.*limit\|ai_usage"` |
| 4.5 | PII sanitization | Anonimizzazione prima di inviare a LLM | `rg "anonymize\|maskPii\|removePii\|sanitizePii"` |
| 4.6 | Agent security | Permessi granulari per tools | `rg "agentPermissions\|toolPermissions\|allowedActions"` |

### 5. INFRASTRUTTURA

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 5.1 | Logging sanitizzato | Nessun log di password/token/secret | `rg "password\|token\|secret\|jwt" lib/core/network/logging*` — nei log dovrebbe essere *** |
| 5.2 | Logging differenziato per env | Dev: dettagliato, Prod: solo errori | `rg "EnvConfig.isProd.*log\|EnvConfig.isDev.*log"` |
| 5.3 | Dependency auditing | Strumento di scan nel CI/CD | Verifica `.github/workflows/ci.yml` - Dependabot o Snyk |
| 5.4 | Password hashed (bcrypt/Argon2) | MAI password in chiaro nel DB | `rg "bcrypt\|argon2\|hashPassword\|passwordHash"` |
| 5.5 | API key cifrate (AES) | Per chiavi di terze parti salvate | `rg "aes\|encrypt\|decrypt.*key\|encryptionKey"` |
| 5.6 | Password: hash, non cifrare | Verifica distinzione hash vs encrypt | Ispezione manuale |

### 6. WEB (Flutter Web)

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 6.1 | No token in LocalStorage | Usa cookie HttpOnly + Secure | Verifica documentazione/architettura |
| 6.2 | CORS configurato | Solo domini autorizzati | `rg "Access-Control-Allow-Origin"` — non deve essere `*` |
| 6.3 | X-Frame-Options: DENY | Clickjacking prevention | `rg "X-Frame-Options\|frame-ancestors"` |
| 6.4 | CSRF protection | SameSite=Strict o token CSRF | `rg "SameSite\|csrf\|CSRF\|anti.*csrf"` |

### 7. MOBILE (Android)

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 7.1 | Play Integrity / Root Detection | Solo in prod, solo per azioni sensibili | `rg "PlayIntegrity\|safetyNet\|rootDetection\|deviceIntegrity"` |
| 7.2 | FLAG_SECURE su schermate sensibili | Impedisci screenshot | `rg "FLAG_SECURE\|flagSecure\|secureWindow\|ScreenSecurity"` |
| 7.3 | PKCE per OAuth2 | Se usi OAuth2, PKCE attivo | `rg "pkce\|PKCE\|codeChallenge\|codeVerifier"` |

### 8. REGOLE TRASVERSALI

| # | Regola | Verifica | Comando / Come controllare |
|---|--------|----------|---------------------------|
| 8.1 | Dev vs Prod: cose lente solo in release | Ogni controllo security deve essere condizionale | `rg "EnvConfig.isProd"` — presente dove serve |
| 8.2 | Nessun TODO/FIXME security-related | Non lasciare buchi | `rg -n "TODO.*security\|FIXME.*security\|HACK.*security" lib/` — 0 |
| 8.3 | HTTPS obbligatorio | Nessuna URL HTTP in configurazioni | `rg "http://" env/` — solo localhost in dev |

---

## 🔍 Esecuzione Automatica

Aggiungi questo step al tuo CI/CD pipeline:

```yaml
# .github/workflows/security_audit.yml
name: Security Audit

on:
  pull_request:
    branches: [develop, main]
  schedule:
    - cron: '0 8 * * 1'  # Ogni lunedì

jobs:
  security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # 1. Scan per hardcoded secrets
      - name: Scan for hardcoded secrets
        run: |
          if rg -q "static const.*(key|secret|token|api)" lib/; then
            echo "❌ Trovati hardcoded secrets!"
            exit 1
          fi
          echo "✅ Nessun secret hardcodato"

      # 2. Verifica SELECT * non usato
      - name: Check for SELECT *
        run: |
          if rg -q "\.select\('\\*'\)" lib/; then
            echo "❌ Trovato SELECT * nelle query!"
            exit 1
          fi
          echo "✅ No SELECT *"

      # 3. Verifica nessun TODO/FIXME security
      - name: Check security TODOs
        run: |
          if rg -q "TODO.*security|FIXME.*security|HACK.*security" lib/; then
            echo "❌ Trovati security TODO/FIXME irrisolti!"
            exit 1
          fi
          echo "✅ Nessun security TODO"

      # 4. Verifica HTTPS in env config
      - name: Check HTTPS-only endpoints
        run: |
          if rg -q "http://" env/prod.json; then
            echo "❌ Endpoint HTTP in produzione!"
            exit 1
          fi
          echo "✅ HTTPS-only in produzione"

      # 5. Verifica dipendenze con vulnerability scan
      - name: Check dependencies
        run: flutter pub outdated --no-transitive
```

---

## 📊 Punteggio di Compliance

Usa questo foglio di calcolo mentale per valutare la sicurezza:

| Livello | Punteggio | Azione |
|---------|-----------|--------|
| 🔴 Critico | < 50% | NON rilasciare. Risolvi prima |
| 🟡 Medio | 50-80% | Rischi moderati. Pianifica fix |
| 🟢 Buono | 80-95% | OK per release, migliora gradualmente |
| 🏆 Eccellente | > 95% | Pronto per produzione |

Calcolo: `(item_verdi / item_totali) * 100`

---

## ⚡ Development Mode Override

Tutte le verifiche che rallentano lo sviluppo sono **automaticamente disabilitate in dev**:

```dart
// Pattern universale per ogni feature di sicurezza
if (EnvConfig.isDev) {
  // Skipalo — non serve in development
  return;
}

// Implementazione reale solo in prod/staging
await _verifyIntegrity();
await _applyFlagSecure();
await _checkCertificatePin();
```

> **Regola**: Se una misura di sicurezza rallenta la compilazione o il hot-reload,
> deve avere un `if (EnvConfig.isDev) return;` o equivalente.
