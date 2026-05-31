---
description: "Compliance, UX quality, and design rules for Flutter Forge projects."
paths: ["**/*.dart", "**/.forge/**"]
---

# Forge Compliance & UX Quality Rules

## R13 — Verify Third-Party Technologies
- ALWAYS verify current SDK versions and syntax via web search before integrating.
- Do NOT rely blindly on older training data.

## R14 — Legal & Regulatory Compliance
- Every app MUST include GDPR-compliant privacy policy, terms & conditions.
- ALL third-party services documented in `docs/legal/third_party_register.md`.
- If the app collects personal data, implement consent management.

## R15 — Free-First Economics
- ALWAYS prefer free tiers of services.
- Document: free tier limits, what happens when exceeded, cost of next tier.
- Always provide a fully functional free path first.

## R16 — Scalability & Modularity
- NO hardcoded values: all configuration from environment or remote config.
- Every feature must be self-contained and independently testable.
- Use pagination for all lists. Use caching strategies. Design DB for growth.

## R17 — Assets & Branding
- Complete visual identity: app icon, splash screen, onboarding illustrations, empty states.
- Use `generate_image` tool for custom assets. NO placeholder images.
- ALL assets catalogued in `.forge/11_asset_manifest.md`.

## R18 — Copywriting & Microcopy
- Every user-facing string must be **intentionally written**.
- Button labels: action-oriented verbs ("Salva", "Inizia", "Continua"), never generic.
- Error messages: human-friendly, explain what happened, suggest how to fix.
- Empty states: friendly message + illustration + clear CTA.
- All copy in localization files (`.arb`) from day one.

## R20 — Anti-Prototype & UX Polish Audit
- The app must NEVER feel like a prototype.
- **Interactivity**: Every logical element MUST be interactive unless strictly decorative.
- **Data**: Never leave hardcoded placeholders. Dynamic data that displays beautifully.
- **Cloud DB**: Schema/rules MUST be generated and verified BEFORE testing.
- **Copy & UI**: Every screen reviewed for good copy, alignment, working navigation.

## R22 — Post-Completion Improvement Plan
After ALL milestones complete, generate improvement plan in `.forge/12_improvement_plan.md`.

## R23 — Strategic Context Clearing
- Session Checkpoints in `.forge/14_current_session.md` before starting new milestones.
- Suggest `/clear` or new conversation when context is too large.

## R24 — Instincts & Continuous Learning
- Register patterns in `.forge/13_instincts.md` when solving complex problems.
- Read this file at the start of every session.

## R25 — Search-First Workflow
- Before implementing, search for existing libraries on pub.dev.
- Never write custom boilerplate if a maintained library exists.

## R26 — Agent-Aware Artifacts
- Use native Artifacts on Antigravity/OpenCode alongside `.forge/` files.
- Use Background Tasks for `flutter test` and `flutter build`.

## R27 — TDD Micro-Commits & De-sloppify
- Micro-commit per TDD cycle: Red → Green → Refactor.
- De-sloppify Pass: remove `print()`, excessive debug code, dead code.

## R29 — Screen Complexity Budget
- Every screen has a complexity point budget (list: 10, detail: 12, form: 15, dialog: 8).
- If over budget → split into stepper, collapsible sections, or separate screens.

## R30 — Permission Strategy (Mobile-First)
- NEVER request permissions at app launch.
- Just-in-Time: request when user taps the feature that needs it.
- Pre-ask dialog explaining WHY before system dialog.
- Handle denial gracefully with alternatives.

## R31 — Device-Aware Design
- SafeArea on every Scaffold.
- Handle text overflow with Flexible/Expanded.
- Keyboard must not hide form fields.
- All scrollable content that could exceed screen height.
- Support font scaling up to 200%.
