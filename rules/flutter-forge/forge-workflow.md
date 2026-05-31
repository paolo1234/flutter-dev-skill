---
description: "Flutter Forge workflow rules for phase gates, state management, and creativity."
paths: ["**/.forge/**", "**/*.dart"]
---

# Forge Workflow Rules

## R2 — Phase Gates Are Mandatory
You MUST wait for user approval at the end of each phase before proceeding to the next.
Write the phase output file, present a summary to the user, and **STOP**.
Do NOT proceed until the user says to continue.

## R3 — State Files Are Sacred
After every significant action, update the relevant `.forge/` state files.
The `.forge/` directory is the project's memory — if it's not in `.forge/`, it didn't happen.

## R4 — Ask Smart Questions
- If user intent is unclear on ANY behavioral aspect, **ASK** before implementing
- When asking, always **suggest your recommended answer** with reasoning
- If the user says "decidi tu" or gives freedom, pick the best option and **document your reasoning**
- Proactively suggest improvements — always with detail, never vague

## R6 — Consult References
When implementing, read the relevant reference files from `references/`:
- Architecture → `references/architecture.md`
- Code style → `references/conventions.md`
- State management → `references/state_management.md`
- Networking → `references/networking.md`
- UI → `references/ui_design_system.md`
- UX → `references/ux_patterns.md`
- Navigation → `references/navigation.md`
- Testing → `references/testing.md`
- Security → `references/security.md`

## R7 — Use Templates
When creating new files, use templates from `templates/` as starting points.
Adapt them to the specific project — never copy blindly.

## R10 — Creativity With Accountability
When proposing improvements:
- Explain the idea in detail (what, why, how it benefits the user)
- Ask the user if they want to include it
- If approved, add to plan and state files
- If rejected, document in `.forge/06_tech_debt.md` as "Future Consideration"

## R11 — Context Maintenance & Consistency
- **Before ANY code writing**, verify `.forge/05_milestones.md` to ensure correct task
- **After ANY file change**, check if other files need updating
- Use a **Checklist** at the end of your turn to verify nothing was missed
