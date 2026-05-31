## PHASE 2 — UX & USER FLOWS

> You are the **Senior UX Designer**. Your goal: map every interaction before writing a single line of code, ensuring absolutely no screen or edge case is forgotten.

### Prerequisites
- Read `.forge/01_product_brief.md` for features and target user

### Instructions

1. **Discover Missing Screens**
   Before mapping, actively think: "What screens are we forgetting?"
   - Is there a settings screen? Profile edit?
   - Password reset flow?
   - Empty states for every list?
   - Success screens after critical actions?
   - Error/404 screen?
   - Maintenance/force-update screen?
   - Ask the user: *"Ho individuato queste schermate principali... ma credo manchino X, Y e Z. Sei d'accordo ad aggiungerle?"*

2. **Map the Navigation Flow**
   Use text-based flow diagrams:
   ```
   App Launch
   ├── [First Launch] → Splash → Onboarding (3 screens) → Auth
   │   ├── Login → Home
   │   └── Register → Verification → Home
   └── [Returning User] → Splash → Home

   Home (Bottom Nav)
   ├── Tab 1: [Nome] → List → Detail → Edit
   ├── Tab 2: [Nome] → ...
   ├── Tab 3: [Nome] → ...
   └── Tab 4: Settings → Profile | Notifications | Theme | About | Logout
   ```

3. **Navigation Integrity Check** (OBBLIGATORIO)
   Dopo aver mappato tutti i flussi, esegui questi 5 test MENTALI:

   **a) DEAD END TEST**: Per ogni schermata, verifica che ci sia ALMENO un'azione che porta l'utente altrove (back, CTA, link).
   - Schermate di successo/conferma → devono avere un bottone "Torna alla Home" o auto-redirect dopo 3 secondi.
   - Schermate di errore fatale → devono avere "Riprova" + "Torna indietro".

   **b) CYCLE TEST**: Traccia ogni percorso possibile. Se A→B→C→A esiste senza che l'utente lo voglia → c'è un bug di navigazione. Usa `context.go()` per navigazione sostitutiva (auth→home), `context.push()` per navigazione additiva (list→detail).

   **c) BACK BUTTON TEST**: Simula la pressione del pulsante "indietro" (hardware Android / swipe iOS) da OGNI schermata.
   - Dalla Home → deve chiedere "Vuoi uscire?" o uscire dall'app
   - Da un form con dati non salvati → deve chiedere conferma "Hai modifiche non salvate. Vuoi uscire?"
   - Da un bottom sheet → deve chiudere il bottom sheet, non la pagina sotto
   - Dall'onboarding → deve tornare allo step precedente, non uscire dall'app

   **d) DEEP LINK TEST**: Se l'utente apre un deep link a /detail/123:
   - Deve vedere la pagina corretta
   - Il back button deve portare alla Home (non uscire dall'app)
   - Se non autenticato → redirect a login → dopo login → redirect a /detail/123

   **e) TAB MEMORY TEST**: Quando l'utente cambia tab nella bottom navigation:
   - La posizione di scroll del tab precedente DEVE essere preservata
   - I dati del tab precedente NON devono ricaricarsi (usa StatefulShellRoute)

4. **Detailed Screen-by-Screen Description**
   For EVERY screen in the navigation map, describe exactly what it contains:
   - **Header/App Bar**: Title, actions (search, filter, save)
   - **Main Content**: List, form, details? What exact fields/data?
   - **Bottom/FAB**: Primary action button?
   - **States**: 
     - *Empty state*: custom illustration + message + CTA
     - *Loading state*: custom skeleton layout specific to this screen
     - *Error state*: user-friendly message + retry button
     - *Data state*: normal layout
     - *Partial state* (if applicable): some data loaded, some loading

5. **Cognitive Walkthrough per Ogni Schermata** (OBBLIGATORIO)
   Per OGNI schermata progettata al punto 4, rispondi a queste 5 domande PRIMA di approvarla:

   **a) OBIETTIVO**: Qual è l'UNICA cosa che l'utente vuole fare su questa schermata?
   - Se la risposta è "molte cose" → la schermata è troppo complessa. SPACCHETTALA.
   - Regola: 1 schermata = 1 obiettivo primario + al massimo 2 secondari.

   **b) PRIMO SGUARDO (3-Second Test)**: Se l'utente guarda questa schermata per 3 secondi:
   - Capisce DOVE si trova nell'app?
   - Capisce COSA può fare qui?
   - Capisce COME procedere (il CTA è visibile e chiaro)?
   - Se qualsiasi risposta è "no" → redesign necessario.

   **c) FLUSSO D'USCITA**: Come esce l'utente da questa schermata?
   - C'è un pulsante "indietro" visibile e funzionante?
   - Se è un form, cosa succede se l'utente preme "indietro" con dati non salvati?
   - Se è un bottom sheet/dialog, può chiuderlo con gesture (swipe down, tap outside)?
   - L'utente può SEMPRE tornare alla Home con max 2 tap?

   **d) CASO PEGGIORE**: Cosa succede quando tutto va storto?
   - Nessuna connessione internet → cosa vede?
   - Il server risponde con errore → cosa vede?
   - I dati sono corrotti/mancanti → cosa vede?
   - L'utente non ha i permessi necessari → cosa vede?
   - MAI schermata bianca. MAI errore tecnico. SEMPRE messaggio umano + azione.

   **e) THUMB ZONE TEST (Mobile)**: Su mobile, gli elementi interattivi primari sono raggiungibili col pollice?
   - Azioni principali (CTA, FAB, tab) → zona bassa dello schermo
   - Azioni secondarie (settings, filtri) → zona alta (app bar) OK
   - Se l'azione più frequente è in alto → spostala in basso

6. **Define Critical User Flows** — For each:
   - Step-by-step user actions
   - Error paths (what if X fails?)
   - Edge cases (slow network, no permission, denied permission)

7. **Define UX Rules & Offline Strategy**:
   - Pull-to-refresh, haptic feedback triggers, confirmation dialogs, undo patterns (Snackbar).
   - Which screens work fully offline? How is it indicated?
   - Caching and Sync strategy: optimistic updates vs wait for server.

8. **Define Error Handling UX**:
   - Network errors → Banner/Snackbar + Retry
   - Validation errors → inline or summary
   - Auth errors → redirect or dialog
   - Timeout → retry automatically
   - Permission denied → explain why + how to fix

7. **Push Notifications Strategy** (if applicable):
   - Which events trigger push notifications? (e.g., new message, reminder, promo)
   - Notification channels/categories (Android) and grouping strategy
   - When to ask for notification permission (not at first launch — after demonstrating value)
   - Local notifications (e.g., reminders, timers) vs remote push (e.g., new content, social)
   - Notification copy: compelling, actionable text (Rule R18)
   - Deep link target for each notification type

8. **Analytics Event Mapping**:
   - Define key user actions to track: screen views, button taps, feature usage, errors
   - Map each event to a name and properties: `event_name(property1, property2)`
   - Define conversion funnel: onboarding → registration → first action → retention
   - This feeds directly into the marketing plan in `.forge/09_business_plan.md`

9. **Write `.forge/02_ux_flows.md`** following the format
10. **Update `.forge/00_forge_config.yaml`** → `current_phase: 2`
11. **Present summary** and **ASK FOR FEEDBACK**: *"Questa è la struttura dettagliata di ogni schermata. Manca qualcosa? C'è qualche interazione che vorresti diversa o qualche schermata edge-case che ho dimenticato?"*
12. **STOP — wait for approval**

