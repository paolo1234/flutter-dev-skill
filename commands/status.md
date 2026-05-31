---
description: "Mostra lo stato corrente del progetto Flutter Forge."
---

# /status

Leggi e presenta lo stato corrente del progetto dai file `.forge/`:

1. **Leggi `.forge/00_forge_config.yaml`** → fase corrente, milestone corrente
2. **Leggi `.forge/05_milestones.md`** → progresso task
3. **Leggi `.forge/06_tech_debt.md`** → debiti tecnici aperti
4. **Leggi `.forge/14_current_session.md`** → contesto sessione (se esiste)
5. **Leggi `.forge/13_instincts.md`** → pattern appresi (se esiste)

## Output formato:

```
📊 STATO PROGETTO: [Nome App]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Fase:      [N] — [Nome Fase]
🏁 Milestone: [MX] — [Nome Milestone]
📈 Progresso: [X/Y] task completati ([Z]%)

📋 MILESTONE CORRENTE: [Nome]
  ✅ Task completati: [lista]
  🔄 Task in corso: [lista]
  ⬜ Task rimanenti: [lista]

⚠️ DEBITO TECNICO: [N] item aperti
  🔴 P1: [lista]
  🟡 P2: [lista]

💡 PATTERN APPRESI: [N] (da .forge/13_instincts.md)
```
