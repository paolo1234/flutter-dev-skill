---
description: "Git workflow, commit conventions, and versioning rules."
paths: ["**/*"]
---

# Git Workflow Rules (R9)

## Commit Strategy
- Use conventional commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`, `test(scope):`, `chore(scope):`
- Create feature branches: `feature/nome`, `fix/nome`
- Never commit directly to `main` or `develop`
- Atomic commits: one logical change per commit

## Mandatory Commit Triggers

You MUST commit after:
- Completing a task in a milestone (`feat(feature_name): description`)
- Fixing a bug (`fix(scope): description`)
- Adding/changing a route, a dependency, or a configuration file
- Creating or updating `.forge/` state files (`chore(forge): update milestones`)
- Any change that, if lost, would cost significant rework
- **Rule of thumb**: If you've made 3+ file changes without committing, STOP and commit now.

## Semantic Versioning (SemVer)
- Follow `MAJOR.MINOR.PATCH` format in `pubspec.yaml` version field
- `PATCH` (0.1.0 → 0.1.1): Bug fixes, small UI tweaks
- `MINOR` (0.1.1 → 0.2.0): New feature added, non-breaking
- `MAJOR` (0.2.0 → 1.0.0): Breaking changes or first public release
- Pre-release builds use `+buildNumber` suffix: `1.0.0+1`, `1.0.0+2`
- Increment `buildNumber` on EVERY release build

## Release Flow
1. When a milestone is fully complete and tested:
   - Bump version in `pubspec.yaml`
   - Update `.forge/07_changelog.md` moving items from `[Unreleased]` to `[X.Y.Z]`
   - Commit: `chore(release): bump version to X.Y.Z`
   - Tag: `git tag vX.Y.Z`
2. For production release:
   - Merge feature branch → `develop` → `main`
   - Tag `main` with the version: `git tag v1.0.0`
   - Push tags: `git push --tags`
   - CI/CD picks up the tag and triggers store deployment
