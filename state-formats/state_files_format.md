## .forge/ STATE FILES FORMAT

All state files are created in the `.forge/` directory at the project root.

### `00_forge_config.yaml`
```yaml
# Flutter Forge Project Configuration
# This file is the agent's memory — read it at every session start

project_name: ""
project_description: ""
current_phase: 1                    # 1-6
current_phase_name: "product_ideation"  # product_ideation | ux_flows | design_system | architecture | devops | legal_compliance
current_milestone: ""               # "" | M1 | M2 | ...
state_management: ""                # riverpod | bloc | (set in Phase 4)
architecture: "feature_first_clean" # feature_first_clean
navigation: "go_router"             # go_router | auto_route
platforms:                          # set in Phase 1
  android: true
  ios: true
  web: false
  windows: false
  macos: false
  linux: false
code_generation: true               # freezed, json_serializable, build_runner
networking: "dio"                   # dio
database: ""                        # drift | none | (set in Phase 4)
auth_method: ""                     # jwt | firebase | supabase | none | (set in Phase 1/4)
monetization: ""                    # free | freemium | subscription | ads | none
last_updated: ""
phases_completed:
  phase_1: false
  phase_2: false
  phase_3: false
  phase_4a: false
  phase_4b: false
  phase_5: false
  phase_6: false
```

### `01_product_brief.md` (Phase 1 output)
```markdown
# Product Brief — [App Name]

## Idea Core
[Descrizione dell'idea come spiegata dall'utente]

## Target Utente
- Persona primaria: ...
- Persona secondaria: ...
- Pain point che risolviamo: ...

## Analisi Competitiva
| Competitor | Punti di forza | Punti deboli | Nostra differenziazione |
|---|---|---|---|

## Feature Set — MVP (Lancio)
### Must Have (P0)
- [ ] Feature 1: [descrizione dettagliata del comportamento]
- [ ] Feature 2: ...

### Should Have (P1)
- [ ] Feature 3: ...

### Nice to Have (P2)
- [ ] Feature 4: ...

## Roadmap Post-Lancio
### v1.1 — [Nome release]
- Feature avanzata 1
### v2.0 — [Nome release]
- Feature avanzata 2

## Modello di Monetizzazione
[Free / Freemium / Premium / Subscription / Ads / ...]
[Strategia dettagliata: cosa è gratis, cosa è a pagamento, pricing]

## Servizi Esterni & Costi
| Servizio | Uso | Piano | Limiti Free Tier | Costo Upgrade |
|---|---|---|---|---|
| Supabase | DB + Auth | Free | 50K MAU, 500MB DB | $25/mo Pro |
| ... | ... | ... | ... | ... |

## Piattaforme Target
- [ ] Android
- [ ] iOS
- [ ] Web
- [ ] Windows / macOS / Linux

## Decisioni Aperte
[Domande irrisolte, punti da chiarire con l'utente]
```

### `02_ux_flows.md` (Phase 2 output)
```markdown
# UX & User Flows — [App Name]

## Navigation Map
[Mappa testuale con frecce di tutte le schermate e le transizioni]

Splash → Onboarding (prima apertura) → Login/Register → Home
Home → [Tab 1] → Detail → Edit
Home → [Tab 2] → ...
Home → Settings → Profile → ...

## User Flows Critici

### Flow 1: [Nome] (es. Onboarding)
1. Utente apre app per la prima volta
2. Splash screen (2s con logo animato)
3. Onboarding: 3 schermate swipeable con illustrazioni
4. → Bottone "Inizia" → Login/Register
5. ...

### Flow 2: [Nome] (es. Azione principale)
...

## Gestione Stati UI
Per ogni schermata definire:
- **Empty State**: cosa mostrare quando non ci sono dati
- **Loading State**: skeleton loader / shimmer (MAI solo spinner)
- **Error State**: messaggio user-friendly + bottone Riprova
- **Data State**: contenuto reale

## Regole UX
- Pull-to-refresh su tutte le liste
- Haptic feedback su azioni importanti (tap, swipe, success)
- Skeleton loader invece di CircularProgressIndicator
- Conferma prima di azioni distruttive (elimina, logout)
- Snackbar per feedback azioni completate
- Toast/Dialog per errori bloccanti
- Transizioni pagina coerenti (fade per tab, slide per push)

## Comportamento Offline
- Quali schermate funzionano offline?
- Come segnalare all'utente che è offline?
- Caching strategy: quali dati persistiamo localmente?
- Sync strategy: come sincronizziamo quando torna online?

## Gestione Errori
- Network error → Banner/Snackbar + Retry automatico con backoff
- Server error (5xx) → Messaggio generico + Segnala problema
- Validation error (4xx) → Messaggi specifici per campo
- Auth error (401) → Redirect a login con messaggio
- Timeout → Messaggio specifico + Retry
```

### `03_design_system.md` (Phase 3 output)
```markdown
# Design System — [App Name]

## Tipografia
- Font family: [Google Font scelto]
- Headline Large: [size/weight/height]
- Headline Medium: ...
- Title Large: ...
- Body Large: ...
- Body Medium: ...
- Label Large: ...

## Palette Colori (WCAG AA)
- Primary: #XXXXXX (nome)
- On Primary: #XXXXXX
- Secondary: #XXXXXX
- On Secondary: #XXXXXX
- Surface: #XXXXXX
- On Surface: #XXXXXX
- Error: #XXXXXX
- Background: #XXXXXX
- Success: #XXXXXX
- Warning: #XXXXXX
[Sia Light Theme che Dark Theme]

## Spaziature (8pt Grid)
- xs: 4
- sm: 8
- md: 16
- lg: 24
- xl: 32
- xxl: 48

## Border Radius
- Piccolo: 8 (chip, badge)
- Medio: 12 (card, input)
- Grande: 16 (bottom sheet, dialog)
- Circolare: 999 (avatar, FAB)

## Elevazioni
- Level 0: nessuna ombra
- Level 1: card standard
- Level 2: card evidenziata
- Level 3: bottom sheet, dialog

## Componenti Atomici
### Buttons
- Primary Button: [stile completo]
- Secondary Button: ...
- Text Button: ...
- Icon Button: ...
- FAB: ...

### Inputs
- TextField: [stile con focus, error, disabled states]
- SearchBar: ...
- Dropdown: ...

### Cards
- Standard Card: ...
- Action Card: ...

### Navigation
- Bottom Navigation: [numero tab, icone, labels]
- App Bar: [stile, azioni]

### Feedback
- SnackBar: [stile success, error, info]
- Dialog: [stile confirm, alert]
- Bottom Sheet: [stile modale, persistent]

## Micro-Animazioni
- Transizione pagina: [tipo, durata, curva]
- Bottone tap: [effetto, durata]
- Lista item appear: [staggered, durata]
- Stato loading → data: [crossfade, durata]

## Icone
- Set: Material Icons / Lucide / HeroIcons / custom
- Stile: outlined / filled / rounded

## Pattern Mobile Scelti
- [✓/✗] Bottom Navigation Bar
- [✓/✗] Tab Bar
- [✓/✗] Drawer
- [✓/✗] FAB
- [✓/✗] Swipe actions su liste
- [✓/✗] Pull-to-refresh
- [✓/✗] Bottom Sheet modale
- [✓/✗] Search bar persistente
```

### `04_architecture.md` (Phase 4A output)
```markdown
# Architettura — [App Name]

## Stack Tecnologico
- Flutter: [versione]
- Dart: [versione]
- State Management: Riverpod / BLoC
- Navigation: GoRouter
- Networking: Dio
- Database locale: Drift / Hive / nessuno
- Code Generation: freezed + json_serializable + build_runner
- DI: tramite Riverpod providers / GetIt

## Struttura Progetto
```
lib/
├── main.dart
├── app.dart
├── bootstrap.dart
├── core/
│   ├── constants/
│   ├── env/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── router/
│   ├── theme/
│   └── utils/
├── features/
│   ├── feature_a/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/ (o blocs/)
│   └── feature_b/
│       └── ...
└── shared/
    ├── widgets/
    ├── models/
    └── utils/
```

## Dipendenze (pubspec.yaml)
- [list here]

## Enterprise Setup
- **Crash Reporting**: [e.g., Sentry / Firebase Crashlytics]
- **Analytics**: [e.g., PostHog / Firebase Analytics]
- **Localization**: [e.g., intl (ARB files) / easy_localization]
- **Deep Linking**: [e.g., configurato su GoRouter e applinks]
[Lista completa con versioni specifiche]

## Mappa Feature → Schermate → Provider/BLoC
[Tabella che mappa ogni feature alle sue schermate e ai provider/bloc associati]

## Strategia di Error Handling
[Come gestiamo errori: Result type, AppException, ecc.]

## Strategia di Caching
[Cosa cacchiamo, per quanto, come invalidiamo]
```

### `05_milestones.md` (Phase 4B tracking)
```markdown
# Milestones — [App Name]

## M1 — Foundation & Core ([stato])
- [x] Inizializzazione progetto Flutter
- [x] Setup core/ (theme, router, networking)
- [/] Setup navigazione base con GoRouter
- [ ] Setup Dio client con interceptors
- [ ] ...

## M2 — [Nome Milestone] ([stato])
- [ ] Task 1: [descrizione specifica]
- [ ] Task 2: ...

## M3 — [Nome Milestone] ([stato])
...
```

### `06_tech_debt.md`
```markdown
# Technical Debt Register — [App Name]

## Active Debt

### TD-001 — [Titolo] (P1/P2/P3)
- **Cosa**: [Descrizione del debito]
- **Perché**: [Perché è stato incorso]
- **Risoluzione**: [Come risolverlo]
- **Impatto**: [Cosa succede se non lo risolviamo]
- **Creato**: [data]

## Resolved Debt
[Debiti risolti con data di risoluzione]

## Future Considerations
[Idee proposte ma non approvate dall'utente — da riconsiderare]
```

### `07_changelog.md`
```markdown
# Changelog — [App Name]

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]
### Added
- ...
### Changed
- ...
### Fixed
- ...

## [0.1.0] — [data] — M1 Foundation
### Added
- Initial project setup
- Core architecture (theme, router, networking)
- Environment configuration (dev, staging, prod)
```

### `08_release_checklist.md` (Phase 5 output)
```markdown
# Release Checklist — [App Name]

## Pre-Release (Technical & UX Audit)
- [ ] flutter analyze --fatal-infos → 0 issues
- [ ] flutter test → all passing
- [ ] flutter test --coverage → >80%
- [ ] **UX Audit**: Tutte le schermate hanno senso? Le card e le liste sono interattive? Le navigazioni funzionano senza bloccare l'utente?
- [ ] **UI Audit**: Non ci sono elementi palesemente "prototipali" o segnaposto? Copy curato e non banale?
- [ ] **Database Audit**: Lo schema remoto (es. tabelle Supabase) è stato fisicamente creato e allineato col DB locale? Il sync funziona?
- [ ] Manual QA su Android (device reale o emulatore)
- [ ] Manual QA su iOS (simulator o device)
- [ ] Performance profiling (60fps, no jank)
- [ ] Accessibilità base verificata
- [ ] Security audit completato (no API keys in chiaro, obfuscation attivo)

## Legal & Compliance
- [ ] Privacy Policy pubblicata e linkata in app
- [ ] Termini e Condizioni pubblicati e linkati in app
- [ ] Consenso GDPR implementato (opt-in, diritto cancellazione)
- [ ] Third-Party Register completo (`docs/legal/third_party_register.md`)
- [ ] Licenze open-source esposte in-app (sezione "Licenze" in Settings)

## Store Assets
- [ ] App icon (1024x1024 per iOS, adaptive per Android)
- [ ] Splash screen
- [ ] Screenshot per store (phone + tablet se supportato)
- [ ] Descrizione app (breve + lunga)
- [ ] Privacy policy URL
- [ ] Categoria store

## Build & Deploy
- [ ] Flavors configurati (dev, staging, prod)
- [ ] Variabili ambiente protette (dart-define-from-file)
- [ ] Signing configurato (keystore Android, provisioning iOS)
- [ ] CI/CD pipeline funzionante
- [ ] Build release testato
```

### `09_business_plan.md` (Phase 1 output)
```markdown
# Business Plan — [App Name]

## Modello di Monetizzazione
- Strategia scelta: [Free / Freemium / Subscription / Ads]
- Cosa è gratis: [...]
- Cosa è a pagamento (se applicabile): [...]
- Pricing (se applicabile): [...]
- Motivazione: [...]

## Servizi Esterni — Analisi Costi
| Servizio | Scopo | Piano Scelto | Limiti Free Tier | Costo Upgrade | Note |
|---|---|---|---|---|---|
| [es. Supabase] | Auth + DB | Free | 50K MAU, 500MB | $25/mo Pro | Sufficiente per MVP |
| [es. Sentry] | Crash reporting | Free | 5K events/mo | $26/mo | OK fino a ~1000 DAU |

## Scalabilità Stimata (Free Tier)
- Utenti concorrenti stimati: [...]
- API calls/mese: [...]
- Storage disponibile: [...]
- Quando sarà necessario upgradare: [...]

## Piano di Marketing
### Pre-Lancio
- Landing page / social media presence
- Beta testing (TestFlight / Play Console Internal Track)
- Contenuti: [...]

### Lancio
- ASO (App Store Optimization): keywords, screenshots, descrizione
- Canali: [social, community, influencer, PR]
- Budget: [€0 / €X]

### Post-Lancio
- Retention strategy: [notifiche push, email, engagement loops]
- Metriche chiave da monitorare: [DAU, MAU, retention D1/D7/D30, churn]
- Roadmap feedback loop: come raccogliere e prioritizzare feedback utenti
```

### `10_scalability.md` (Phase 4A output)
```markdown
# Scalability Report — [App Name]

## Limiti Attuali (Free Tier)
| Risorsa | Servizio | Limite | Impatto al raggiungimento |
|---|---|---|---|
| Database rows | [Supabase] | 500MB | App non può salvare nuovi dati |
| Auth users | [Supabase] | 50K MAU | Nuovi utenti non possono registrarsi |
| API calls | [Servizio X] | Y/mese | Funzionalità Z smette di funzionare |
| Storage | [Servizio Y] | Z GB | Upload immagini bloccato |

## Strategia di Crescita
- **Fase 1 (0-1K utenti)**: Free tier, monitoraggio metriche
- **Fase 2 (1K-10K utenti)**: Valutare upgrade a piano Pro, ottimizzare query
- **Fase 3 (10K+ utenti)**: Implementare caching aggressivo, CDN, pagination server-side

## Pattern di Scalabilità Implementati
- [ ] Pagination su tutte le liste
- [ ] Caching con invalidazione
- [ ] Lazy loading immagini
- [ ] Debounce su ricerca
- [ ] Compressione immagini prima dell'upload
- [ ] Nessun valore hardcoded (tutto da config)
```

### `11_asset_manifest.md` (Phase 3 output)
```markdown
# Asset Manifest — [App Name]

## App Icon
| Asset | Dimensions | Format | Status | Note |
|---|---|---|---|---|
| app_icon | 1024x1024 | PNG | [ ] | Adaptive (Android) + iOS |
| app_icon_foreground | 1024x1024 | PNG | [ ] | Android adaptive foreground |

## Splash Screen
| Asset | Type | Format | Status | Note |
|---|---|---|---|---|
| splash_logo | Image / Lottie | PNG/JSON | [ ] | Centered logo |
| splash_background | Color / Gradient | — | [ ] | From design system |

## Onboarding Illustrations
| Screen | Asset Name | Description | Status |
|---|---|---|---|
| Onboarding 1 | onboarding_1 | [Descrizione scena] | [ ] |
| Onboarding 2 | onboarding_2 | [Descrizione scena] | [ ] |
| Onboarding 3 | onboarding_3 | [Descrizione scena] | [ ] |

## Empty State Illustrations
| Screen | Asset Name | Description | Status |
|---|---|---|---|
| [Screen name] | empty_[name] | [Descrizione] | [ ] |

## Lottie Animations (if applicable)
| Name | Purpose | Duration | Loop | Status |
|---|---|---|---|---|
| loading_spinner | Global loading | 2s | Yes | [ ] |
| success_check | Action completed | 1.5s | No | [ ] |

## Sound Effects (if applicable)
| Name | Trigger | License | Source | Status |
|---|---|---|---|---|
| [sound_name] | [when played] | CC0 | [source URL] | [ ] |

## Fonts
| Font Family | Weights | Source | License |
|---|---|---|---|
| [e.g., Inter] | 400, 500, 600, 700 | Google Fonts | OFL |
```

### `13_instincts.md` (Continuous Learning)
```markdown
# Instincts & Learned Patterns

## Pattern 1: [Nome breve]
- **Trigger**: Quando si usa/si fa [X]
- **Errore Comune**: [Cosa andava storto]
- **Soluzione**: [Come fare correttamente]
```

### `14_current_session.md` (Session Context — FORMATO ESTESO)
```markdown
# Session Context — [Data]

## Stato Corrente
- **Fase/Milestone**: Fase X, Milestone Y
- **Ultimo file modificato**: lib/features/.../...
- **Branch corrente**: feature/...

## Decisioni Prese in Questa Sessione
| # | Decisione | Motivazione |
|---|-----------|-------------|
| 1 | ... | ... |

## Bug Incontrati e Risolti
| File | Problema | Fix Applicato |
|------|----------|---------------|
| ... | ... | ... |

## Pattern Scoperti
- ...

## Prossimi Step
1. ...
2. ...
3. ...
```
