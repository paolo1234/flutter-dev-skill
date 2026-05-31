---
description: "Esegui la security checklist pre-release."
---

# /security

Esegui un audit di sicurezza del progetto Flutter.

## Step 1 — Scan Automatico

Esegui questi comandi e verifica che diano **0 risultati**:

```bash
# Segreti hardcoded
rg "static const.*(key|secret|token|api)" lib/

# SELECT * nel database
rg "\.select\('\*'\)" lib/

# TODO/FIXME di sicurezza non risolti
rg "TODO.*security|FIXME.*security" lib/

# print() non condizionali
rg "print\(" lib/ --include="*.dart" | grep -v "debugPrint"

# SharedPreferences per dati sensibili
rg "SharedPreferences.*(token|jwt|password|secret)" lib/
```

## Step 2 — Checklist Manuale

- [ ] Token JWT salvati in `flutter_secure_storage`, non SharedPreferences
- [ ] API key iniettate via `--dart-define-from-file`, non nel codice
- [ ] Offuscamento attivo nella build release (`--obfuscate --split-debug-info`)
- [ ] Certificate pinning configurato per produzione (se API critiche)
- [ ] RLS attivo su tutte le tabelle del database
- [ ] Logging sanitizzato (nessun dato personale nei log)
- [ ] Input utente validato lato client E lato server
- [ ] Rate limiting attivo in produzione
- [ ] HTTPS forzato per tutte le chiamate di rete

## Step 3 — Report

Presenta i risultati:
- ✅ Check superati
- ❌ Check falliti con file, riga, e fix suggerito
- Se tutti passano: "✅ Security audit superato. Pronto per release."
- Se qualcuno fallisce: "❌ [N] problemi di sicurezza da risolvere prima della release."
