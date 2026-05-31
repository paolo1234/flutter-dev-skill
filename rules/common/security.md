---
description: "Security rules for all code. Applies to all Dart files and configuration."
paths: ["**/*.dart", "**/pubspec.yaml", "**/*.json", "**/*.yaml"]
---

# Security Rules (R12 + R21)

## Regole Inviolabili

- **MAI hardcodare** API key, token o credenziali nel codice Dart. Usa `--dart-define-from-file` per iniettarle.
- **MAI usare SharedPreferences** per token JWT o dati sensibili. Usa `flutter_secure_storage` (Keystore/Keychain).
- **Flutter Web**: non salvare token in LocalStorage (leggibile via XSS). Usa cookie HttpOnly + Secure gestiti dal backend.
- **Certificate Pinning** per chiamate critiche in produzione. Disabilitato in development.
- **No SELECT \*** nelle query al database. Proiezioni sempre esplicite.
- **Proxy backend per API AI**: le chiavi AI non devono MAI toccare il client Flutter.
- **Rate limiting** attivo in produzione. Disabilitato in development per performance.
- **Offuscamento** (`--obfuscate --split-debug-info`) solo nella build release.
- **Play Integrity, FLAG_SECURE, PKCE** solo in produzione, non in development.
- **RLS attivo** su tutte le tabelle del database con privilegio minimo (`user_id = auth.uid()`).
- **Logging sanitizzato**: mai loggare password, token o dati personali. Logging dettagliato solo in dev.
- **ReDoS protection**: timeout per regex lato server. Evita pattern con nested quantifier.
- **Denial of Wallet**: hard cap giornaliero per chiamate AI.
- **PII sanitization**: anonimizzare prima di inviare dati a provider AI.

## Regola d'oro per development vs production

Ogni misura di sicurezza che **rallenta la compilazione o hot-reload** deve essere condizionale:
```dart
if (EnvConfig.isDev) return; // Skipalo in dev
if (EnvConfig.isProd) { /* implementazione reale */ }
```

## Security Quick-Scan (da eseguire a ogni milestone)

Comandi che DEVONO dare 0 risultati:
```bash
rg "static const.*(key|secret|token|api)" lib/
rg "\.select\('\*'\)" lib/
rg "TODO.*security|FIXME.*security" lib/
rg "print\(" lib/ --include="*.dart" | grep -v "debugPrint"
```

## Pre-Release Security Audit Gate

Prima di ogni release, il Security Compliance Checklist (`references/security_checklist.md`) deve essere eseguito e superato.
- Ogni item deve essere verde o avere un esplicito rationale documentato in `.forge/06_tech_debt.md`.
- Crea una GitHub Action `.github/workflows/security_audit.yml` con i controlli automatizzati.
