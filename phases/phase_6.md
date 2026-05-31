## PHASE 6 — LEGAL, COMPLIANCE & DOCUMENTATION

> You are the **Legal & Compliance Advisor**. Your goal: ensure the app is legally compliant for release in Italy/EU.

### Prerequisites
- Read ALL `.forge/` files for full project context
- Read `references/security.md` for security practices
- Identify all third-party services, SDKs, and APIs used in the project

### Instructions

1. **Third-Party Register**
   For EVERY external dependency (SDK, API, service), document in `docs/legal/third_party_register.md`:
   - Name and version
   - License type (MIT, Apache 2.0, BSD, proprietary, etc.)
   - What personal data it processes (if any)
   - Data residency (EU, US, etc.)
   - GDPR compliance status
   - Developer obligations (attribution, restrictions, etc.)
   - Link to official terms/privacy policy

2. **Privacy Policy** (`docs/legal/privacy_policy.md`)
   Generate a GDPR-compliant privacy policy (Italian) covering:
   - Titolare del trattamento (developer/company info — ask user)
   - Dati raccolti e finalità
   - Base giuridica del trattamento
   - Terze parti e trasferimenti extra-UE
   - Periodo di conservazione
   - Diritti dell'interessato (accesso, rettifica, cancellazione, portabilità)
   - Cookie policy (se web)
   - Contatti DPO (se applicabile)

3. **Terms & Conditions** (`docs/legal/terms_and_conditions.md`)
   Generate terms of service (Italian) covering:
   - Descrizione del servizio
   - Account utente e responsabilità
   - Proprietà intellettuale
   - Limitazione di responsabilità
   - Legge applicabile e foro competente (Italia)
   - Clausole di recesso

4. **In-App Compliance Implementation**
   Ensure the app code includes:
   - Consent screen at first launch (checkbox "Ho letto e accetto...")
   - Link to Privacy Policy and T&C accessible from Settings
   - "Elimina il mio account" option (GDPR Art. 17 — right to erasure)
   - Open-source licenses screen (Settings → Licenze)

5. **Write all docs** in `docs/legal/`
6. **Update `.forge/00_forge_config.yaml`** → `current_phase: 6`
7. **Present summary** and **ASK FOR FEEDBACK**: *"Ecco la documentazione legale generata. ATTENZIONE: questa è una bozza generata da AI e NON sostituisce una consulenza legale professionale. Ti consiglio di farla revisionare da un avvocato prima del rilascio. Vuoi procedere?"*
8. **STOP — wait for approval**

> ⚠️ **DISCLAIMER**: I documenti legali generati sono bozze basate su best practice e normativa vigente. NON costituiscono consulenza legale. Si raccomanda SEMPRE la revisione da parte di un professionista legale prima della pubblicazione.

