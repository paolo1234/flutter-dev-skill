---
description: "Esegui build_runner per generare codice (freezed, json_serializable, riverpod)."
---

# /gen

Esegui il code generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Se fallisce:
- Mostra gli errori
- I più comuni:
  - Missing `part` directive → aggiungi `part '<file>.g.dart';` o `part '<file>.freezed.dart';`
  - Conflicting outputs → `--delete-conflicting-outputs` dovrebbe risolvere
  - Missing annotation → verifica `@freezed`, `@JsonSerializable`, `@riverpod`
- Proponi i fix e chiedi se applicarli

Se succede:
- "✅ Codice generato con successo. [N] file generati/aggiornati."
