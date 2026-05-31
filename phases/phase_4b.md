## PHASE 4B — IMPLEMENTATION

> You are the **Full Development Team**. Your goal: build the app milestone by milestone.

### Prerequisites
- Read ALL `.forge/` files for full context
- Read relevant `references/` files as needed during implementation
- Use `templates/` as starting points for new files

### Pre-Milestone: Error Scenario Matrix (OBBLIGATORIO)

Prima di iniziare a implementare una milestone, crea una matrice errori per OGNI schermata coinvolta nella milestone:

| Schermata | Scenario | Cosa vede l'utente | Azione disponibile |
|-----------|----------|--------------------|--------------------||
| LoginPage | Password errata | "Email o password non corretti" inline | Riprova, "Password dimenticata?" |
| LoginPage | Network offline | Banner top "Nessuna connessione" | Riprova automatico quando torna online |
| LoginPage | Server 500 | "Servizio temporaneamente non disponibile" | Riprova tra 30s (timer visibile) |
| ListPage | Lista vuota (primo uso) | Illustrazione + "Inizia creando..." | CTA "Crea il primo" |
| ListPage | Lista vuota (filtro attivo) | "Nessun risultato per 'X'" | "Cancella filtri" |
| ListPage | Errore caricamento | Messaggio + bottone "Riprova" | Riprova |
| ListPage | Caricamento lento (>3s) | Skeleton, poi dopo 10s "Sta impiegando più del solito" | Annulla / Riprova |
| DetailPage | Elemento non trovato (404) | "Questo elemento non esiste più" | "Torna alla lista" |
| FormPage | Submit fallito (network) | Snackbar "Salvataggio fallito" + dati preservati | Riprova (dati NON persi) |

**SE MANCA UNA RIGA PER UNA SCHERMATA → L'IMPLEMENTAZIONE È INCOMPLETA.** Includi la matrice nel commit iniziale della milestone.

### Milestone Execution Loop (Continuous PR / Goal Loop)

**Tip for users**: Suggerisci all'utente di usare il comando `/goal` di Antigravity se vuole che tu esegua questa intera milestone in totale autonomia, lasciandoti lavorare in background per completare tutti i task di fila.

For each milestone in `.forge/05_milestones.md` (o `task.md` nativo se supportato):

1. **Announce**: "Inizio Milestone MX — [Nome]"
2. **Create Error Scenario Matrix** for all screens in this milestone (see above)
3. **Mark milestone as in progress** in `05_milestones.md` (o `task.md`) (`[/]`)
4. **For each task in the milestone**:
   a. **Preflight Search (R25)**: Prima di scrivere logica core, effettua una ricerca (search-first) per evitare codice custom se esiste una libreria.
   b. Mark task as in progress (`[/]`)
   c. **TDD Micro-Commits (R27)**: Crea/modifica i file applicando il ciclo TDD (Red, Green, Refactor). Effettua un micro-commit per ogni step funzionale. Usa i *Background Tasks* (`manage_task`) per eseguire `flutter test` mentre continui a preparare il commit successivo.
   d. Follow coding conventions and architecture.
   e. **De-sloppify Pass (R27)**: Pulisci il codice da boilerplate e test ridondanti.
   f. **Functional Smoke Test** (see below): Verifica che la schermata FUNZIONA.
   g. Mark task as completed (`[x]`)
   h. Update `07_changelog.md`
5. **After completing all tasks — Checkpoint Protocol**:
   - Run `dart format .`
   - Run `flutter analyze --fatal-infos` — fix any issues
   - Run `flutter test` — fix any failures
   - Run security quick-scan:
     - `rg "static const.*(key|secret|token|api)" lib/` → must be 0 results
     - `rg "print(" lib/ --include="*.dart"` → only `debugPrint` allowed
   - Mark milestone as completed in `05_milestones.md`
   - Git commit: `feat(milestone): complete MX — [Nome]`
6. **Present milestone summary to user**: what was built, any decisions made, any questions
7. **STOP — wait for user approval before next milestone**

### Functional Smoke Test (Post-Task, OBBLIGATORIO)

Dopo aver creato/modificato una schermata, verifica MENTALMENTE che ognuno di questi punti sia implementato. Se anche uno manca → il task NON è completato.

#### Checklist per Schermate Lista:
- [ ] La lista si popola con dati reali (non hardcoded)
- [ ] Pull-to-refresh funziona e ricarica i dati
- [ ] Tap su un elemento naviga al dettaglio
- [ ] Stato vuoto mostra messaggio + illustrazione + CTA (non schermata bianca)
- [ ] Stato loading mostra skeleton (non solo spinner)
- [ ] Stato errore mostra messaggio + riprova
- [ ] Scroll raggiunge la fine senza crash
- [ ] Se paginazione: carica pagina successiva a fine scroll

#### Checklist per Schermate Form:
- [ ] Ogni campo ha label, hint, e tipo di tastiera corretto (email, number, text, password)
- [ ] Validazione inline mostra errore sotto il campo (non alert/dialog)
- [ ] Bottone submit è disabilitato se form invalido OPPURE mostra errori al tap
- [ ] Bottone submit mostra loading durante l'invio
- [ ] Dopo invio con successo → feedback (snackbar) + navigazione
- [ ] Dopo invio con errore → messaggio specifico + campi rimangono compilati (dati NON persi)
- [ ] Tastiera si chiude tappando fuori dal form
- [ ] Tab/Next sulla tastiera passa al campo successivo
- [ ] L'ultimo campo ha `TextInputAction.done` che triggera submit
- [ ] Il form scrolla quando la tastiera copre un campo

#### Checklist per Schermate Dettaglio:
- [ ] Tutti i dati vengono mostrati (non campi vuoti o "null")
- [ ] Se dati mancanti → placeholder elegante, non crash
- [ ] Azioni (modifica, elimina, condividi) funzionano
- [ ] Elimina chiede conferma prima di procedere
- [ ] Back button torna alla lista (non a una pagina random)

#### Checklist Universale (OGNI schermata):
- [ ] AppBar ha titolo corretto e azioni pertinenti
- [ ] Non ci sono overflow visibili (testo che esce, yellow-black stripes)
- [ ] La schermata funziona con dati lunghi (nome di 50+ caratteri)
- [ ] La schermata funziona con 0 dati (stato vuoto)
- [ ] La schermata funziona con molti dati (100+ elementi)
- [ ] SnackBar/Toast non è nascosto dalla bottom navigation
- [ ] Safe area rispettata (contenuto non sotto notch/status bar)
- [ ] Nessun `print()` — solo `debugPrint` condizionale

### Implementation Guidelines

#### When creating a new feature:
1. Read `references/architecture.md` for folder structure
2. Start from `templates/feature/` templates
3. Create files in this order:
   - Models (domain/models/) → run `build_runner`
   - Repository interface (domain/repositories/)
   - Data source (data/datasources/)
   - Repository implementation (data/repositories/)
   - Provider/BLoC (presentation/providers/ or presentation/blocs/)
   - UI pages (presentation/pages/)
   - UI widgets (presentation/widgets/)
4. Register routes in `app_router.dart`
5. Wire up dependencies (providers or DI)

#### When creating a new screen:
1. Read `references/ux_patterns.md` for state handling
2. **Check R29 (Complexity Budget)** — count the complexity points. If over budget, redesign before coding.
3. Implement ALL states: loading (skeleton), error (message + retry), empty (illustration + CTA), data
4. Use Design System components from `03_design_system.md`
5. Add skeleton loaders (never bare CircularProgressIndicator alone)
6. Add haptic feedback on primary actions
7. Add pull-to-refresh if it's a list
8. Handle keyboard (dismiss on scroll, next field focus)
9. Implement responsive padding and SafeArea (R31)
10. **Check R30 (Permissions)** — if this screen requires device permissions, implement just-in-time request with pre-ask dialog
11. Handle text overflow with `Flexible`/`Expanded` and `maxLines`
12. **Run Functional Smoke Test** checklist before marking complete

#### When creating models:
1. Use `@freezed` annotation
2. Include `fromJson`/`toJson` factory
3. Define all fields with correct nullability
4. Add `@Default` values where appropriate
5. Run `dart run build_runner build --delete-conflicting-outputs`

#### When creating networking:
1. Read `references/networking.md`
2. Define request/response DTOs
3. Map server errors to `AppException` types
4. Handle timeout, connection error, server error
5. Add retry logic for transient failures

---
