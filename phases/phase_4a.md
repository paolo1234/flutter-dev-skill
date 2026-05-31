## PHASE 4A — ARCHITECTURE PLANNING

> You are the **Lead Software Architect**. Your goal: design the technical foundation before writing code.

### Prerequisites
- Read ALL `.forge/` files (01, 02, 03) for full context
- Read `references/architecture.md` for architectural patterns
- Read `references/state_management.md` for state management options
- Read `references/conventions.md` for coding standards

### Instructions

1. **Choose State Management**
   Ask the user their preference (if not already decided):
   - **Riverpod** (recommended): Modern, type-safe, testable, code-gen support
   - **BLoC/Cubit**: Battle-tested, great for large teams, stream-based
   Present pros/cons for the specific app and recommend one with reasoning.

2. **Define Project Structure**
   Map every feature from the product brief to a feature folder:
   ```
   lib/features/
   ├── auth/           # Login, Register, Password reset
   ├── onboarding/     # First-time user experience
   ├── home/           # Main dashboard/home
   ├── [feature_a]/    # ...
   ├── [feature_b]/    # ...
   ├── settings/       # App settings, profile, preferences
   └── ...
   ```

3. **Define Dependencies & Enterprise Setup**
   List ALL packages with specific versions for pubspec.yaml:
   - State management (flutter_riverpod + riverpod_generator OR flutter_bloc)
   - Navigation & Deep Linking (go_router, app_links)
   - Networking (dio, connectivity_plus)
   - Serialization (freezed_annotation, json_annotation)
   - Local storage (flutter_secure_storage, drift/hive)
   - Observability & Analytics (sentry_flutter OR firebase_crashlytics, firebase_analytics OR posthog_flutter)
   - Localization (intl, flutter_localizations)
   - UI & Utils (shimmer, intl, path_provider, etc.)
   - Testing (mocktail)

4. **Map Feature → Screens → State**
   Create a table:
   | Feature | Screen | State Manager | Data Source |
   |---|---|---|---|
   | auth | LoginPage | AuthNotifier/AuthBloc | AuthRepository → API |
   | auth | RegisterPage | AuthNotifier/AuthBloc | AuthRepository → API |
   | home | HomePage | HomeNotifier/HomeBloc | Multiple repos |
   | ... | ... | ... | ... |

5. **Define Error Handling Architecture**
   - `AppException` sealed class hierarchy
   - How exceptions map to user-friendly messages
   - Where exceptions are caught (repository? provider/bloc? UI?)

6. **Define Networking Architecture**
   - Base URL configuration per flavor
   - Dio interceptors: auth, logging, error mapping, retry
   - Request/Response models

7. **Create Milestone Plan**
   Break implementation into **ordered milestones**:
   - **M1 — Foundation**: Project init, core setup (theme, router, dio, env)
   - **M2 — Auth** (if needed): Login, register, token management
   - **M3-MN — Features**: One milestone per major feature, ordered by dependency
   - **M(N+1) — Polish**: Animations, edge cases, empty states
   - **M(N+2) — Testing**: Unit tests, widget tests
   - **M(N+3) — DevOps**: Flavors, CI/CD, store prep
   - **M(N+4) — Legal & Compliance**: Privacy Policy, T&C, GDPR consent, third-party register

   Each milestone must have **specific, detailed tasks** (see Rule R5).

8. **Scalability Analysis** (Rule R16)
   - Review ALL external services from `.forge/09_business_plan.md`
   - Document exact limits for each service tier in `.forge/10_scalability.md`
   - Identify bottlenecks: which limit will be hit first?
   - Propose pagination, caching, and lazy-loading strategies
   - Ensure NO hardcoded values in the architecture (all from env config)

9. **Write `.forge/04_architecture.md`** following the format
10. **Write `.forge/05_milestones.md`** with all milestones and tasks (all `[ ]`)
11. **Write `.forge/10_scalability.md`** with scalability analysis
12. **Update `.forge/00_forge_config.yaml`** → `current_phase: 4`, set `state_management`, `database`, etc.
13. **Present summary** and **STOP — wait for approval**

