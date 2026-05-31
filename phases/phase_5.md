## PHASE 5 — FLAVORS, DEVOPS & STORE READY

> You are the **DevOps Engineer**. Your goal: prepare the app for production deployment.

### Prerequisites
- Read `references/flavors_and_envs.md`
- Read `references/cicd.md`
- Use `templates/config/` and `templates/cicd/` as starting points

### Instructions

1. **Configure 3 Flavors**: dev, staging, prod
   - Use `--dart-define-from-file` with JSON env files
   - Different API base URLs per flavor
   - Different app names (e.g., "MyApp Dev", "MyApp Staging", "MyApp")
   - Different bundle IDs (com.example.myapp.dev, .staging, .prod)

2. **Environment Configuration**:
   - Create `env/dev.json`, `env/staging.json`, `env/prod.json`
   - Create `EnvConfig` class that reads from dart defines
   - Add env files to `.gitignore` (sensitive data)
   - Create `env/dev.json.example` for documentation

3. **CI/CD Pipeline** (GitHub Actions):
   - `ci.yml`: On PR → analyze, test, format check
   - `deploy.yml`: On tag → build + deploy to stores
   - Include caching for Flutter SDK and pub packages

4. **Fastlane** (if iOS/Android):
   - iOS: TestFlight deployment lane
   - Android: Google Play internal track deployment lane
   - Match for iOS signing (if applicable)

5. **App Assets & Branding**:
   - Generate final app icon using `generate_image` (1024x1024) and configure:
     - Adaptive icon for Android (foreground + background layers)
     - App icon for iOS
   - Configure splash screen (flutter_native_splash or flutter_launcher_icons)
   - Generate all onboarding and empty state illustrations (from `.forge/11_asset_manifest.md`)
   - Configure app name per flavor
   - Implement sound effects if defined in asset manifest

6. **App Store Optimization (ASO) & Copywriting** (Rule R18):
   - Write compelling **store title** (max 30 chars) with primary keyword
   - Write **subtitle/short description** (max 80 chars) — benefit-focused
   - Write **full description** (4000 chars max) — structured with features, benefits, social proof
   - Research and define **keywords** (iOS: 100 chars keyword field)
   - Define **store category** and **content rating**
   - Generate **store screenshots** descriptions (what each screenshot should show)
   - Write all copy in Italian + English (if multi-language)
   - Save in `docs/store/aso_listing.md`

7. **Release Checklist, Red-Team Audit & Automation**:
   - Consiglia all'utente l'uso dello slash command `/schedule` se vuole impostare build e test end-to-end ricorrenti (es. ogni notte).
   - Write `.forge/08_release_checklist.md`
   - Run through checklist items (Test, Coverage > 80%, Performance).
   - **Adversarial Security Audit (Red-Team)**: Simula di essere un attaccante (stile AgentShield). Cerca attivamente injection attack, analizza se le regole RLS di Supabase sono bypassabili, assicurati che i permessi siano al minimo. Non limitarti a una checklist statica: scrivi veri e propri tentativi di breach nei test se necessario. Verify no API keys are hardcoded. Ensure obfuscation is enabled.
   - Generate release build for testing (`flutter build apk/ipa --release`).

8. **Update state files** and **present summary**
9. **STOP — wait for approval before Phase 6**

