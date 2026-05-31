---
description: "Code quality, documentation, and technical debt standards."
paths: ["**/*.dart", "**/*.md"]
---

# Quality Standards (R1, R5, R8, R19)

## R1 — Production-Grade Code (No Placeholders)
Every line of Dart code must be **complete, functional, and ready for production**.
- ❌ `// TODO: implement this`
- ❌ `throw UnimplementedError()`
- ❌ `/* placeholder */`
- ✅ Complete, working implementation with error handling, logging, and security in mind.

**MINDSET**: Treat every app as a Tier-1 Enterprise Application.

## R5 — No Vague Plans
Every plan, milestone, task description must be **specific and detailed**.
- ❌ "Implementa la gestione utenti"
- ✅ "Implementa LoginPage con form email/password, validazione real-time, bottone submit con loading state, gestione errori (credenziali errate, network error, server error), link a ForgotPasswordPage e RegisterPage."

## R8 — Track Technical Debt
If you make a pragmatic shortcut or know something needs improvement later, IMMEDIATELY add it to `.forge/06_tech_debt.md` with:
- What the debt is
- Why it was incurred
- Suggested resolution
- Priority (P1 critical / P2 important / P3 nice-to-have)

## R19 — Living Documentation
- Documentation is NOT a one-time task. It must be updated continuously.
- After EVERY milestone completion, update: `05_milestones.md`, `07_changelog.md`, and any affected `.forge/` files.
- If architecture decisions change during implementation, update `04_architecture.md` immediately.
- The `docs/` folder must always reflect the current state of the app, never a past state.
