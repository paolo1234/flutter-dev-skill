---
description: "Diagnosi e risoluzione errori di build o runtime Flutter."
---

# /fix

Diagnostica e risolvi errori nel progetto Flutter.

## Procedura

1. **Identifica il tipo di errore:**
   - Se l'utente ha incollato un errore → analizzalo
   - Se nessun errore specificato → esegui `flutter analyze` per trovarli

2. **Classificazione errore:**

   | Tipo | Esempio | Strategia |
   |------|---------|-----------|
   | Compile error | `The method 'X' isn't defined` | Fix diretto nel codice |
   | Runtime error | `Null check operator used on null` | Aggiungi null check + traccia la causa |
   | Build error | `Gradle/Xcode failure` | Controlla pubspec, run `flutter clean` |
   | Codegen error | `build_runner failed` | Fix annotazioni, run `/gen` |
   | Dependency error | `Version solving failed` | Analizza versioni in pubspec |

3. **Risoluzione:**
   - Proponi il fix con spiegazione del perché
   - Se il fix è sicuro → applicalo
   - Se il fix potrebbe avere side effects → chiedi conferma
   - Dopo il fix → riesegui `flutter analyze` per verificare

4. **Se il problema persiste dopo 3 tentativi:**
   - FERMATI (R28)
   - Proponi: "Questo errore richiede un approccio diverso. Suggerisco di..."
   - Documenta in `.forge/06_tech_debt.md` se necessario
