---
description: "Formatta e analizza il codice Dart del progetto."
---

# /analyze

Esegui questi comandi in sequenza:

1. `dart format .` — Formatta tutto il codice Dart
2. `flutter analyze --fatal-infos` — Analisi statica con errori su info

Se ci sono errori:
- Mostra la lista degli errori raggruppati per file
- Proponi i fix per ognuno
- Chiedi all'utente se vuoi applicarli automaticamente

Se tutto è pulito:
- Conferma con "✅ Codice formattato e pulito. 0 errori, 0 warning."
