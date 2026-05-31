---
description: "Configurazioni opzionali raccomandate per i server MCP in Flutter Forge."
---

# MCP Optional Configurations per Flutter Forge

I Model Context Protocol (MCP) server permettono agli agenti di interagire nativamente con strumenti esterni. 
Sebbene Flutter Forge funzioni indipendentemente, abilitare i seguenti MCP server può migliorare drasticamente le performance dell'agente.

## 1. MCP per Firebase (se si usa Firebase)
Se l'app usa Firebase, l'agente può gestire le regole di sicurezza, Firestore e Cloud Functions in autonomia.

**Server MCP**: `firebase-mcp-server` o script custom.
**Casi d'uso**:
- Deploy automatico delle regole Firestore/Storage dopo l'implementazione
- Creazione di dati mock in DB per i test dell'agente
- Analisi remota degli indici mancanti (se query falliscono)

## 2. MCP per GitHub/GitLab
Permette all'agente di gestire pull request, code review e issue in autonomia.

**Casi d'uso**:
- Aprire una PR per ogni Milestone completata con la checklist (`08_release_checklist.md`)
- Leggere le Issue segnalate per fixare i bug direttamente dai log utente

## 3. MCP per Figma (se si ha un design system)
Se l'utente fornisce un link Figma, l'agente può leggerlo nativamente.

**Casi d'uso**:
- Estrarre i token (colori, padding, font) direttamente dal file Figma e compilare `03_design_system.md`
- Verificare che il codice UI corrisponda ai mockups

## 4. Supabase MCP (Consigliato per Flutter Forge)
Poiché Supabase è il default consigliato nel Business Plan, un MCP Supabase è estremamente prezioso.

**Casi d'uso**:
- Sync schema locale ↔ remoto senza intervento utente
- Esecuzione migrazioni SQL in background
- Validazione RLS policies

---

*Nota: Antigravity attualmente supporta l'installazione di server MCP tramite la sua interfaccia. Se installi uno di questi server, assicurati di aggiornare `.forge/00_forge_config.yaml` o di informare l'agente nella chat!*
