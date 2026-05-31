---
description: "Esegui tutti i test Flutter con report di coverage."
---

# /test

Esegui i test del progetto:

1. `flutter test --coverage` — Esegui tutti i test con coverage
2. Analizza i risultati:
   - Se tutti passano: "✅ [N] test passati. Coverage: [X]%"
   - Se qualcuno fallisce: mostra i test falliti con il motivo
   - Se coverage < 80%: segnala i file con bassa copertura

Se non ci sono test:
- Segnala: "⚠️ Nessun test trovato. Vuoi che ne crei per le feature implementate?"
- Proponi i test da scrivere ordinati per priorità (provider/bloc > repository > widget)
