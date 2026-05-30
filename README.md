# Flutter Forge

**Flutter Forge** è una skill per Antigravity IDE progettata per automatizzare lo sviluppo di applicazioni Flutter production-ready.

Trasforma un'idea astratta in un'app completa, architetturalmente solida e pronta per gli store, attraverso un processo rigoroso in 5 fasi.

## Caratteristiche Principali
- **Sviluppo Iterativo Guidato**: Divide lo sviluppo in Product Ideation, UX Design, UI Design, Architettura e DevOps.
- **Nessun Placeholder**: Genera solo codice funzionante e pronto alla produzione (no TODO).
- **Architettura Feature-First**: Utilizza una Clean Architecture semplificata orientata alle feature.
- **Persistenza dello Stato**: Usa file `.forge/` per memorizzare il contesto, permettendo di riprendere lo sviluppo esattamente da dove era stato interrotto.
- **Reference Inclusi**: Contiene linee guida per State Management (Riverpod/BLoC), Networking (Dio), Testing, CI/CD e UI Design System.
- **Template Pronti**: Include dozzine di template (page, repository, provider, bloc, empty/error states) già configurati con le best practices.

## Installazione

Seleziona lo script in base al tuo sistema operativo per copiare la skill nella cartella locale di Antigravity:

**Windows**:
```cmd
cd scripts
install.bat
```

**macOS/Linux**:
```bash
cd scripts
chmod +x install.sh setup.sh
./install.sh
```

## Setup Ambiente

Se hai bisogno di installare Flutter o Git, puoi usare gli script di setup inclusi:
- Windows: `scripts\setup.bat`
- macOS/Linux: `./scripts/setup.sh`

## Utilizzo

Dentro Antigravity, apri un progetto vuoto (o un progetto Flutter esistente) e digita:

```
/forge
```

L'agente:
1. Controllerà se c'è un file `.forge/00_forge_config.yaml`
2. Se **non esiste**, ti chiederà l'idea per la nuova app e inizierà dalla Fase 1 (Product Ideation).
3. Se **esiste**, leggerà i file di stato e ti chiederà se vuoi continuare dall'ultimo task rimasto in sospeso.

Comandi addizionali:
- `/forge new` — Forza l'inizio di un nuovo progetto ignorando lo stato precedente.
- `/forge status` — Mostra un riepilogo dello stato attuale del progetto e i task completati.

## Struttura della Skill

- `SKILL.md` — L'orchestratore principale letto dall'agente.
- `references/` — Guide tecniche su architettura, state management, UI, ecc.
- `templates/` — Codice pre-configurato che l'agente usa per generare feature.
- `examples/` — Esempi di implementazioni complete.
- `scripts/` — Script di utility per installazione e setup.

## Sviluppo e Contributi

Se modifichi la skill in questo repository, ricordati di lanciare lo script `install.bat/sh` per applicare i cambiamenti su Antigravity.
