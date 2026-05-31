# Analisi Comparativa: Flutter Forge vs ECC — Integrazioni Strategiche

## Premessa

**Flutter Forge** è un framework specializzato per lo sviluppo Flutter che eccelle nella pipeline verticale (idea → store).  
**ECC (Everything Claude Code)** è un sistema operativo agente general-purpose con 63 agenti, 249 skill, hook lifecycle, orchestrazione multi-agente e install selettivo.

Queste integrazioni sono state selezionate per essere compatibili con:
- **Modelli gratuiti** (nessun Opus/Sonnet richiesto)
- **OpenCode / Antigravity** come harness principale
- **Basso consumo di token** (niente sistemi pesanti che bruciano contesto)
- **Focus Flutter** — non generico cross-linguaggio

---

## 1. Architettura a Sub-Agenti

### Problema attuale
`SKILL.md` è un monolite di ~2500 righe. L'agente principale deve caricare TUTTO il contesto, anche per operazioni semplici. Tutta la logica di routing è affidata a sezioni della stessa skill.

### Soluzione ECC
ECC ha 63 agenti separati in `agents/*.md`, ognuno con:
- Frontmatter YAML (nome, descrizione, tools, model)
- Prompt specializzato
- Tool permissions granulari
- Capacità di esecuzione parallela

### Cosa integrare
**Creare sub-agenti Flutter specializzati** in `agents/`:

```
agents/
├── flutter-planner.md        # Scomposizione feature complesse in milestone
├── flutter-ux-designer.md    # Design UX e user flows
├── flutter-ui-builder.md     # Implementazione UI con design system
├── flutter-tester.md         # TDD, widget test, copertura
├── flutter-reviewer.md       # Code review qualità e convenzioni
├── flutter-security-auditor.md # Audit di sicurezza pre-release
├── flutter-store-publisher.md  # Preparazione store (metadata, asset)
└── forge-operator.md         # Orchestratore che coordina i sub-agenti
```

**Beneficio**: L'agente principale (forge-operator) carica solo la logica di orchestrazione (~200 righe). I sub-agenti vengono caricati on-demand solo quando servono. Token risparmiati: ~70% a sessione.

**Vincolo free models**: I sub-agenti devono usare lo stesso modello dell'agente principale (`tool` basato sul task, non su model costoso). Nessun Opus richiesto per sub-agenti.

---

## 2. Sistema di Hooks (Lifecycle Automation)

### Problema attuale
Tutta la logica di controllo qualità, commit e validazione è comandata da regole in SKILL.md che l'agente deve ricordare di eseguire.

### Soluzione ECC
ECC ha un sistema di hooks a 6 lifecycle points:

| Hook | Trigger | Cosa fa |
|------|---------|---------|
| PreToolUse | Prima di ogni tool | Validazione, reminder, blocchi |
| PostToolUse | Dopo ogni tool | Quality gate, logging, accumulo edit |
| Stop | Fine risposta | Build batch controlli, session persistence |
| PreCompact | Prima della compattazione | Salvataggio stato |
| SessionStart | Inizio sessione | Caricamento contesto precedente |
| SessionEnd | Fine sessione | Lifecycle marker, cost tracking |

### Cosa integrare
**Creare hooks Flutter-specifici** in `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "tool == \"Write\" && tool_input.filePath == \"**/*.dart\"",
      "command": "node scripts/hooks/pre-write-analysis.js"
    }
  ],
  "Stop": [
    {
      "matcher": "true",
      "command": "dart format --set-exit-if-changed . && flutter analyze --fatal-infos"
    }
  ],
  "SessionStart": [
    {
      "command": "echo '[Forge] Ripristino contesto sessione...' && node scripts/hooks/load-forge-context.js"
    }
  ],
  "SessionEnd": [
    {
      "command": "node scripts/hooks/save-forge-context.js"
    }
  ]
}
```

**Beneficio**: La qualità è garantita dal sistema, non dall'agente che "si ricorda". Le regole diventano automatiche.

---

## 3. Sistema di Regole a Strati

### Problema attuale
Le regole sono tutte in SKILL.md (R1-R22). Ogni regola è formulata come "devi fare X" — facile da ignorare o dimenticare.

### Soluzione ECC
ECC ha `rules/` con:
- `rules/common/` — regole trasversali (sicurezza, testing, coding style, git workflow)
- `rules/dart/`, `rules/python/`, `rules/rust/` — regole per-linguaggio
- Ogni file ha `paths:` per farle scattare automaticamente sui file giusti

### Cosa integrare
**Creare sistema a 3 layer**:

```
rules/
├── common/
│   ├── security.md            # Checklist sicurezza trasversale
│   ├── testing.md             # Coverage minimo, TDD obbligatorio
│   ├── git-workflow.md        # Conventional commits, branch strategy
│   └── coding-style.md        # Regole generali DRY/KISS/YAGNI
├── dart/
│   ├── coding-style.md        # Convenzioni Dart specifiche
│   ├── patterns.md            # Pattern Flutter (Riverpod, BLoC, GoRouter)
│   ├── testing.md             # flutter_test, mocktail, golden test
│   └── security.md            # flutter_secure_storage, dart-define, RLS
└── flutter-forge/
    ├── architecture.md        # Feature-first, Clean Architecture
    ├── state-management.md    # Riverpod vs BLoC decision tree
    └── design-system.md       # Pattern UI obbligatori
```

**Beneficio**: Le regole Dart/Flutter vengono caricate automaticamente quando l'agente lavora su file `.dart` o `pubspec.yaml`. Nessun "prompt engineering" necessario.

---

## 4. Skill Catalog Riutilizzabile

### Problema attuale
Tutto il know-how è sparso in `references/` (15 file) e in `SKILL.md`. Non c'è modo di riutilizzare parti del framework selettivamente.

### Soluzione ECC
ECC ha 249 skill in `skills/<nome>/SKILL.md` con frontmatter (name, description, origin) e contenuto strutturato. Ogni skill è:
- Autonoma (contiene tutto il necessario)
- Installabile selettivamente
- Aggiornabile indipendentemente

### Cosa integrare
**Trasformare references/ in skills/** con struttura a directory:

```
skills/
├── forge-core/
│   └── SKILL.md              # Orchestrazione fasi 1-5
├── flutter-architecture/
│   └── SKILL.md              # Feature-first, Clean Architecture
├── flutter-state-management/
│   └── SKILL.md              # Riverpod vs BLoC con esempi
├── flutter-networking/
│   └── SKILL.md              # Dio, interceptors, retry, error mapping
├── flutter-design-system/
│   └── SKILL.md              # Tema M3, 8pt grid, componenti
├── flutter-testing/
│   └── SKILL.md              # TDD, widget test, golden, integration
├── flutter-security/
│   └── SKILL.md              # Checklist sicurezza, env obfuscation
├── flutter-cicd/
│   └── SKILL.md              # GitHub Actions, Fastlane, flavors
├── flutter-localization/
│   └── SKILL.md              # ARB files, intl, pluralizzazione
├── flutter-performance/
│   └── SKILL.md              # Profiling, const costruttori, lazy loading
├── flutter-accessibility/
│   └── SKILL.md              # Semantica, TalkBack, contrasto
└── flutter-store-publish/
    └── SKILL.md              # Asset store, ASO, metadata
```

**Beneficio**: L'agente carica solo le skill necessarie per il task corrente. Ogni skill contiene esempi pratici, codice funzionante e pattern già testati.

---

## 5. Comandi Rapidi (Slash Commands)

### Problema attuale
Tutto parte da `/forge`. Non ci sono scorciatoie per operazioni comuni durante lo sviluppo.

### Soluzione ECC
ECC ha 79 comandi in `commands/*.md` con frontmatter (description, argument-hint). Ogni comando è una scorciatoia per un task specifico.

### Cosa integrare
**Creare comandi rapidi per Flutter**:

```
commands/
├── analyze          # dart format + flutter analyze (senza test)
├── test             # flutter test --coverage + report
├── review           # Code review con sub-agente flutter-reviewer
├── build-dev        # flutter build --debug
├── build-prod       # flutter build appbundle --release
├── gen-assets       # dart run build_runner build --delete-conflicting-outputs
├── security-check   # Esegue security checklist
├── add-feature      # Scaffolding nuova feature (template → code)
├── fix              # build-error-resolver specializzato Flutter
├── status           # Stato progetto da .forge/ files
└── docs             # Aggiorna documentazione
```

Registrazione in `opencode.json`:
```json
{
  "command": {
    "analyze": {
      "description": "Formatta e analizza il codice Dart",
      "template": "Esegui dart format . e flutter analyze --fatal-infos",
      "subtask": true
    },
    "review": {
      "description": "Code review del codice scritto",
      "template": "...",
      "agent": "flutter-reviewer",
      "subtask": true
    },
    "test": {
      "description": "Esegui test con coverage",
      "template": "...",
      "agent": "flutter-tester",
      "subtask": true
    }
  }
}
```

**Beneficio**: Pattern comuni diventano comandi da 1 parola invece di dover descrivere cosa fare ogni volta. Riduce attrito e consumo token.

---

## 6. Installazione Selettiva con Profili

### Problema attuale
L'installazione è tutto-o-niente. L'utente copia l'intera skill o niente.

### Soluzione ECC
ECC ha 6 profili di installazione (`minimal → core → developer → security → research → full`) con 56+ componenti installabili individualmente. Ogni componente è etichettato per famiglia (baseline, language, framework, capability, agent, skill, locale).

### Cosa integrare
**Creare sistema di install selettivo** in `scripts/install-plan.js` + `scripts/install-apply.js`:

```
Profili:
├── minimal              # Solo forge-core
├── core                 # forge-core + flutter-architecture + flutter-design-system
├── developer            # core + flutter-networking + flutter-state-management + flutter-testing
├── security             # developer + flutter-security + flutter-accessibility
├── enterprise           # security + flutter-cicd + flutter-localization + flutter-store-publish
└── full                 # Tutto
```

Ogni componente in `manifests/install-components.json`:
```json
{
  "id": "flutter-testing",
  "family": "testing",
  "description": "TDD workflow, widget test, golden test patterns",
  "files": ["skills/flutter-testing/SKILL.md", "agents/flutter-tester.md"],
  "dependencies": ["flutter-architecture"]
}
```

**Beneficio**: L'utente installa solo ciò che serve. Framework leggero per utenti base, completo per team enterprise. Schemi di validazione JSON per verificare l'integrità dell'installazione.

---

## 7. Configurazione MCP per Flutter

### Problema attuale
Nessuna integrazione MCP. L'agente non ha accesso a strumenti esterni specializzati.

### Soluzione ECC
14 configurazioni MCP per GitHub, Context7, Exa, Playwright, memoria, sequential-thinking.

### Cosa integrare
**Creare MCP servers pre-configurati per Flutter**:

```json
{
  "mcpServers": {
    "flutter-docs": {
      "command": "npx",
      "args": ["-y", "@agentdeskai/browser-tools-mcp"],
      "description": "Documentazione Flutter in tempo reale"
    },
    "pub-dev": {
      "command": "npx",
      "args": ["mcp-pub-dev"],
      "description": "Cerca pacchetti pub.dev"
    },
    "dart-docs": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      },
      "description": "Documentazione API Dart/Flutter"
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "firebase": {
      "command": "npx",
      "args": ["@openr1/mcp-server-firebase"],
      "description": "Gestione Firebase/Firestore"
    },
    "supabase": {
      "command": "npx",
      "args": ["mcp-server-supabase"],
      "description": "Gestione Supabase"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp"],
      "description": "E2E testing Flutter web"
    }
  }
}
```

**Beneficio**: L'agente può cercare documentazione live, pacchetti pub.dev, gestire backend (Firebase/Supabase), fare E2E test. Zero guesswork su API versioni.

---

## 8. Session Persistence & Context Recovery

### Problema attuale
I file `.forge/` salvano lo stato del progetto ma non il contesto della sessione (decisioni, problemi incontrati, pattern scoperti).

### Soluzione ECC
ECC ha session persistence con:
- `SessionStart` hook che carica il contesto precedente
- `SessionEnd` hook che salva lo stato
- `memory-persistence/` hooks per lifecycle persistente
- `continuous-learning-v2/` skill per estrarre pattern dalle sessioni

### Cosa integrare
**Aggiungere persistenza di contesto**:

```javascript
// scripts/hooks/save-forge-context.js
// Salva: ultimo file su cui si lavorava, decisioni architetturali,
//        errori incontrati, pattern trovati, commit hash
// Output: .forge/session_context.json
```

```dart
// .forge/session_context.json
{
  "session_id": "forge-2026-05-31-001",
  "last_file": "lib/features/auth/presentation/pages/login_page.dart",
  "decisions": [
    {
      "what": "Scelto Riverpod su BLoC per minore boilerplate",
      "why": "App semplice, team piccolo, modelli free con limiti token"
    }
  ],
  "bugs_encountered": [
    {
      "file": "lib/core/network/dio_client.dart",
      "issue": "DioException non mappato su AppException",
      "fix": "Aggiunto ErrorInterceptor"
    }
  ],
  "patterns_discovered": [
    "Usare Shimmer + crossfade per loading state invece di spinner"
  ]
}
```

**Beneficio**: Riprendere una sessione interrotta è immediato. Nessuna perdita di contesto. L'agente non deve "riscoprire" problemi già risolti.

---

## 9. Quality Gates Automatici

### Problema attuale
Le regole R21 (Security Audit) e R20 (UX Polish) sono checklist manuali che l'agente deve eseguire quando "si ricorda".

### Soluzione ECC
ECC usa PostToolUse hooks per quality gate automatici:
- `design-quality-check.js` — verifica qualità design dopo ogni scrittura
- `format+typecheck batch` — esegue lint dopo ogni sessione
- `governance capture` — traccia decisioni

### Cosa integrare
**Quality Gates Flutter automatici**:

```javascript
// scripts/hooks/flutter-quality-gate.js
// PostToolUse hook che controlla:
// 1. Hardcoded string (devono essere in .arb)
// 2. TODO/FIXME nel codice
// 3. API key hardcodate
// 4. print() statements (dovrebbero usare debugPrint con flag condizionale)
// 5. File > 800 righe (suggerisci refactoring)
// 6. Pattern che violano Material 3 (es. CircularProgressIndicator senza contesto)
// 7. const mancanti (parametri costruttore non const)

// Se violazioni trovate: logga warning + suggerisce fix
// Se CRITICAL: blocca con exit(1)
```

**Beneficio**: La qualità è verificata a ogni tool call, non alla fine. Errori vengono scoperti subito, non in fase di review. L'agente non deve "ricordare" le regole.

---

## 10. Orchestrazione Multi-Agente per Task Complessi

### Problema attuale
Quando costruisci una feature complessa, un solo agente fa tutto: backend + UI + testing + review. Consumo token elevato, qualità variabile.

### Soluzione ECC
ECC orchestra agenti in parallelo:
- `multi-plan.md`, `multi-execute.md` per esecuzione parallela
- Split role per analisi multi-prospettiva
- Agenti con tool permissions diverse

### Cosa integrare
**Flusso di lavoro multi-agente per feature Flutter**:

```
Feature Request
    │
    ├── flutter-planner    
    │   → Scompone in milestone, identifica dipendenze
    │
    ├── flutter-ux-designer 
    │   → Disegna user flow, definisce stati UI
    │
    ├── flutter-ui-builder  
    │   → Implementa widget, provider, routing
    │
    ├── flutter-tester      
    │   → Scrive test (unit + widget + golden)
    │
    └── flutter-reviewer    
        → Code review finale + quality gate
```

Implementato con:
```json
{
  "command": {
    "forge-build": {
      "description": "Costruisce una feature completa orchestrando agenti specializzati",
      "agent": "forge-operator",
      "subtask": true
    }
  }
}
```

**Beneficio**: Ogni agente fa una cosa sola e la fa bene. Riduzione del 40% consumo token vs. agente singolo che fa tutto. Il codice passa attraverso review automatica prima di essere proposto come finito.

---

## 11. Template Progetto Avanzati

### Problema attuale
Templates attuali sono buoni ma mancano:
- Template per schermate con stati (loading/error/empty/data)
- Template per provider Riverpod con error handling
- Template per test
- Template per golden test

### Cosa integrare
**Estendere templates con pattern ECC**:

```
templates/
├── cicd/                        # (già presenti)
├── config/                      # (già presenti)  
├── feature/                     # (già presenti)
├── project/                     # (già presenti)
├── screens/
│   ├── list_screen.dart.tmpl    # Schermata lista con skeleton, error, empty
│   ├── detail_screen.dart.tmpl  # Schermata dettaglio con loading state
│   ├── form_screen.dart.tmpl    # Form con validazione real-time
│   └── settings_screen.dart.tmpl # Schermata impostazioni con switch
├── test/
│   ├── widget_test.dart.tmpl    # Test widget con ProviderContainer
│   ├── provider_test.dart.tmpl  # Test provider con override
│   ├── repository_test.dart.tmpl # Test repository con mock datasource
│   └── golden_test.dart.tmpl    # Golden test setup
├── providers/
│   ├── async_notifier.dart.tmpl # AsyncNotifier con Riverpod
│   ├── stream_provider.dart.tmpl # StreamProvider pattern
│   └── future_provider.dart.tmpl # FutureProvider con error handling
└── widgets/
    ├── skeleton_list.dart.tmpl  # Skeleton loader personalizzato
    ├── error_banner.dart.tmpl   # Error banner con retry
    ├── empty_state.dart.tmpl    # (già presente)
    ├── error_state.dart.tmpl    # (già presente)
    └── shimmer_loader.dart.tmpl # (già presente ma migliorabile)
```

---

## 12. Validazione Schema per Config

### Problema attuale
`.forge/00_forge_config.yaml` non ha validazione strutturale. Se l'agente scrive valori errati, il progetto si corrompe silenziosamente.

### Soluzione ECC
10 JSON schemas che validano: install config, hooks, module, profile, plugin, state store, provenance, package manager.

### Cosa integrare
**Schemi JSON per file `.forge/`**:

```
schemas/
├── forge-config.schema.json         # Valida 00_forge_config.yaml
├── forge-milestones.schema.json     # Valida 05_milestones.md
├── forge-tech-debt.schema.json      # Valida 06_tech_debt.md
└── forge-product-brief.schema.json  # Valida 01_product_brief.md
```

Hook PostToolUse che valida automaticamente i file `.forge/` dopo ogni scrittura.

**Beneficio**: Zero errori silenziosi nella configurazione. L'agente rileva immediatamente dati malformati e li corregge prima che causino problemi.

---

## 13. Continuous Learning Sessione

### Problema attuale
Ogni sessione è una nuova sessione. I pattern scoperti in sessioni precedenti sono persi (a meno di essere manualmente documentati).

### Soluzione ECC
ECC ha `skills/continuous-learning-v2/` che:
- Cattura pattern dalle tool call
- Aggrega per frequenza
- Genera skill da pattern ricorrenti
- Sistema di osservatore asincrono

### Cosa integrare
**Versione semplificata per Flutter**:

```javascript
// scripts/hooks/extract-forge-patterns.js
// A ogni SessionEnd:
// 1. Leggi cronologia tool call della sessione
// 2. Identifica pattern ricorrenti (es. "dimenticato trailing comma" 5 volte)
// 3. Salva in .forge/learned_patterns.md
// 4. Dopo 5 occorrenze dello stesso errore → aggiungi a rules/
```

**Output**: `.forge/learned_patterns.md`
```markdown
# Pattern Appresi — Sessione 2026-05-31

## Errori Frequenti
1. `dimenticato const costruttore` (3 occorrenze) → fixato
2. `Snackbar senza context.mounted check` (2 occorrenze) → fixato

## Decisioni Ricorrenti
1. Stack: Riverpod + GoRouter + Dio → consolidato
2. Auth: Supabase + flutter_secure_storage → consolidato

## Skill Candidate
Se un pattern si ripete >5 volte in >3 sessioni →
suggerisci creazione skill automatica.
```

**Beneficio**: Il framework migliora con l'uso. Non è statico. Diventa più intelligente col tempo.

---

## 14. Cost & Budget Tracking per Free Models

### Problema attuale
Nessun controllo su consumo token. Le sessioni lunghe possono bruciare budget gratuito senza avvisi.

### Soluzione ECC
ECC ha `skills/ecc-tools-cost-audit/`, `skills/cost-aware-llm-pipeline/`, `skills/token-budget-advisor/`:
- Tracking cost per sessione
- Model routing (task semplice → modello piccolo)
- Hard cap giornaliero
- Avvisi preventivi

### Cosa integrare
**Sistema budget-aware** in `.forge/00_forge_config.yaml`:

```yaml
budget:
  max_tokens_per_session: 50000    # Avviso a 80%
  max_tokens_per_day: 150000       # Stop a 100%
  model_routing:
    analysis: "free_default"       # Per analisi usa modello base
    generation: "free_default"     # Per generazione codice usa modello base
    review: "free_default"         # Review usa modello base
  token_thresholds:
    warn_at: 80                    # % di utilizzo per avviso
    stop_at: 100                   # % di utilizzo per stop
```

**Hook PreToolUse** che controlla il budget prima di ogni tool call:
```javascript
if (currentSessionTokens > budget.warnAtPercent * budget.maxTokens) {
  echo "[Forge] Attenzione: hai usato ${percentUtilization}% del budget token";
}
if (currentSessionTokens > budget.stopAtPercent * budget.maxTokens) {
  exit(1); // Blocca
}
```

**Beneficio**: Non bruci mai tutto il budget gratuito in una sessione. L'agente è "consapevole" del costo delle sue azioni.

---

## 15. Riepilogo delle Integrazioni

| # | Area | Priorità | Complessità | Impatto Token | Beneficio Principale |
|---|------|----------|-------------|---------------|---------------------|
| 1 | Sub-agenti | ALTA | Media | -70% | Framework leggero, specializzato |
| 2 | Hooks | ALTA | Alta | +5% | Quality gate automatici |
| 3 | Rules stratificate | ALTA | Bassa | -10% | Regole applicate automaticamente |
| 4 | Skill catalog | ALTA | Media | -20% | Caricamento selettivo |
| 5 | Comandi rapidi | MEDIA | Bassa | -5% | Meno prompt, più azione |
| 6 | Install profili | MEDIA | Alta | 0 | Flessibilità installazione |
| 7 | MCP config | MEDIA | Bassa | Variabile | Documentazione live |
| 8 | Session persistence | MEDIA | Media | -10% | Zero ripartenze |
| 9 | Quality gates | ALTA | Alta | +3% | Codice pulito sempre |
| 10 | Multi-agente | BASSA | Alta | -40% | Feature build orchestrate |
| 11 | Template avanzati | MEDIA | Bassa | 0 | Meno boilerplate |
| 12 | Schema validation | BASSA | Media | +1% | Zero errori config |
| 13 | Continuous learning | BASSA | Alta | +2% | Framework migliora da solo |
| 14 | Budget tracking | ALTA | Bassa | +1% | Mai fuori budget |

### Priorità Consigliata

**Fase 1 (Prossima Settimana)** — Alto impatto, basso rischio:
1. Sub-agenti (scompattare SKILL.md in agenti)
2. Rules stratificate (common/ + dart/ + flutter-forge/)
3. Budget tracking per free models
4. Comandi rapidi per pattern comuni

**Fase 2 (Tra 2 Settimane)** — Automated quality:
5. Hooks (almeno PreToolUse + Stop)
6. Quality gates (lint, hardcoded strings, TODO)
7. Session persistence hooks
8. Template avanzati

**Fase 3 (Tra 1 Mese)** — Scaling & refinement:
9. Skill catalog completo
10. MCP configurazioni
11. Install profili
12. Schema validation

**Fase 4 (Visione)** — Advanced:
13. Multi-agente orchestration
14. Continuous learning
15. Full skill transformation

---

## Nota Finale: Adattamento per Modelli Free

Tutte le integrazioni proposte sono state selezionate per funzionare su modelli gratuiti / a basso costo. Le differenze chiave rispetto all'approccio ECC originale:

| Caratteristica | ECC (Originale) | Flutter Forge (Adattato) |
|----------------|-----------------|-------------------------|
| Sub-agenti | Usa Sonnet/Opus per agenti | Stesso modello base per tutti |
| Hooks | Node.js complessi | JavaScript leggero + bash |
| MCP | Servizi a pagamento (Context7) | Solo servizi gratuiti |
| Rules | 21 directory di regole | 3 directory essenziali |
| Install | 56 componenti | 10-15 componenti |
| Skills | 249 skill | 12 skill specializzate |
| Continuous learning | Osservatore asincrono esterno | Logging semplice su file |
| LLM layer astrazione | Python 3.11+ | Non richiesto |

L'obiettivo non è replicare ECC, ma rubare i **pattern architetturali** che lo rendono efficace — adattandoli a un contesto Flutter-first con risorse limitate.
