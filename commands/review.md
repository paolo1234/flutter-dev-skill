---
description: "Code review strutturata del codice scritto nella sessione."
---

# /review

Esegui una code review strutturata del codice modificato:

## Checklist di Review

### 1. Architettura
- [ ] Ogni feature segue la struttura data/domain/presentation
- [ ] Nessuna dipendenza circolare tra feature
- [ ] Le dipendenze fluiscono sempre: presentation → domain ← data

### 2. Qualità Codice
- [ ] Nessun `// TODO:` o `throw UnimplementedError()` (R1)
- [ ] Nessun `print()` — solo `debugPrint` condizionale
- [ ] Nessuna API key o segreto hardcoded (R12)
- [ ] File sotto 800 righe
- [ ] Nomi variabili/classi chiari e descrittivi

### 3. UX/UI Completezza
- [ ] Ogni schermata ha TUTTI gli stati: loading, error, empty, data (R29)
- [ ] Skeleton loader invece di CircularProgressIndicator
- [ ] Error state con messaggio umano + bottone retry
- [ ] Empty state con illustrazione + CTA
- [ ] Safe area rispettata (R31)
- [ ] Testo non va in overflow su schermi piccoli
- [ ] Tastiera non nasconde i campi del form

### 4. Navigazione
- [ ] Back button funziona correttamente da ogni schermata
- [ ] Nessun dead end (schermata senza via d'uscita)
- [ ] Form con dati non salvati: conferma prima di uscire

### 5. Sicurezza
- [ ] Nessun segreto nel codice
- [ ] Token salvati in flutter_secure_storage, non SharedPreferences
- [ ] Input utente validato prima di inviare al server

### 6. Performance
- [ ] Liste usano `.builder` (non Column + SingleChildScrollView)
- [ ] `const` costruttori dove possibile
- [ ] Immagini con caching (cached_network_image)

## Output
Presenta i risultati con:
- ✅ Punti che passano
- ❌ Punti che falliscono con file e riga
- 💡 Suggerimenti di miglioramento
