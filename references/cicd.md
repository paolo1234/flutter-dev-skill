# CI/CD Reference — GitHub Actions & Fastlane

## GitHub Actions — CI Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: stable
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Check format
        run: dart format --set-exit-if-changed .
      
      - name: Analyze
        run: flutter analyze --fatal-infos
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check minimum coverage
        uses: VeryGoodOpenSource/very_good_coverage@v3
        with:
          min_coverage: 80
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
```

## GitHub Actions — Deploy Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: stable
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Decode keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
        run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/keystore.jks
      
      - name: Create key.properties
        env:
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
        run: |
          cat > android/key.properties <<EOF
          storePassword=$STORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=keystore.jks
          EOF
      
      - name: Create prod env
        env:
          PROD_ENV: ${{ secrets.PROD_ENV_JSON }}
        run: echo "$PROD_ENV" > env/prod.json
      
      - name: Build APK
        run: flutter build apk --release --dart-define-from-file=env/prod.json
      
      - name: Build App Bundle
        run: flutter build appbundle --release --dart-define-from-file=env/prod.json
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
      
      - name: Upload to Google Play
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.example.myapp
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: stable
          cache: true
      
      - name: Create prod env
        env:
          PROD_ENV: ${{ secrets.PROD_ENV_JSON }}
        run: echo "$PROD_ENV" > env/prod.json
      
      - name: Build iOS
        run: flutter build ipa --release --dart-define-from-file=env/prod.json --export-options-plist=ios/ExportOptions.plist
      
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v3
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

## Fastlane Setup

### Android (Fastfile)
```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Google Play Internal Track"
  lane :deploy_internal do
    # Build with Flutter
    sh("cd ../.. && flutter build appbundle --release --dart-define-from-file=env/prod.json")
    
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key: "fastlane/google-play-service-account.json",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end

  desc "Deploy to Google Play Production"
  lane :deploy_production do
    sh("cd ../.. && flutter build appbundle --release --dart-define-from-file=env/prod.json")
    
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key: "fastlane/google-play-service-account.json",
    )
  end
end
```

### iOS (Fastfile)
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :deploy_testflight do
    setup_ci if is_ci

    # API Key authentication (recommended over password)
    api_key = app_store_connect_api_key(
      key_id: ENV["APPSTORE_API_KEY_ID"],
      issuer_id: ENV["APPSTORE_ISSUER_ID"],
      key_filepath: "fastlane/AuthKey.p8",
    )

    # Build with Flutter
    sh("cd ../.. && flutter build ipa --release --dart-define-from-file=env/prod.json --export-options-plist=ios/ExportOptions.plist")

    upload_to_testflight(
      api_key: api_key,
      ipa: "../build/ios/ipa/MyApp.ipa",
      skip_waiting_for_build_processing: true,
    )
  end

  desc "Deploy to App Store"
  lane :deploy_appstore do
    setup_ci if is_ci

    api_key = app_store_connect_api_key(
      key_id: ENV["APPSTORE_API_KEY_ID"],
      issuer_id: ENV["APPSTORE_ISSUER_ID"],
      key_filepath: "fastlane/AuthKey.p8",
    )

    sh("cd ../.. && flutter build ipa --release --dart-define-from-file=env/prod.json --export-options-plist=ios/ExportOptions.plist")

    upload_to_app_store(
      api_key: api_key,
      ipa: "../build/ios/ipa/MyApp.ipa",
      skip_metadata: false,
      skip_screenshots: false,
      force: true,
    )
  end
end
```

## Version Management

```bash
# Version format: MAJOR.MINOR.PATCH+BUILD
# pubspec.yaml: version: 1.2.3+45

# Bump patch: 1.2.3+45 → 1.2.4+46
# Bump minor: 1.2.3+45 → 1.3.0+46
# Bump major: 1.2.3+45 → 2.0.0+46
# BUILD always increments
```

## Security Audit Pipeline

Aggiungi questo workflow per audit automatici di sicurezza:

```yaml
# .github/workflows/security_audit.yml
name: Security Audit

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]
  schedule:
    - cron: '0 6 * * 1'  # Ogni lunedì mattina

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # 1. Hardcoded secrets scan
      - name: Scan hardcoded secrets
        run: |
          if rg -q "static const.*(key|secret|token|api)" lib/; then
            echo "❌ Hardcoded secrets found!"
            exit 1
          fi
          echo "✅ No hardcoded secrets"

      # 2. SELECT * scan
      - name: Check for SELECT *
        run: |
          if rg -q "\.select\('\\*'\)" lib/; then
            echo "❌ SELECT * found in queries!"
            exit 1
          fi
          echo "✅ No SELECT *"

      # 3. Security TODO/FIXME scan
      - name: Check security debt
        run: |
          if rg -q "TODO.*security|FIXME.*security|HACK.*security" lib/; then
            echo "❌ Security debt found!"
            exit 1
          fi
          echo "✅ No security debt"

      # 4. HTTPS in production env
      - name: Check HTTPS in prod config
        run: |
          if test -f env/prod.json && rg -q "http://" env/prod.json; then
            echo "❌ HTTP endpoint in prod config!"
            exit 1
          fi
          echo "✅ HTTPS-only in production"

      # 5. Dependency audit
      - name: Check outdated dependencies
        run: flutter pub outdated --no-transitive

      # 6. Flutter analyze (security lint rules)
      - name: Analyze
        run: flutter analyze --fatal-infos
```

## Secrets Required

| Secret | Where | Purpose |
|---|---|---|
| `KEYSTORE_BASE64` | GitHub Secrets | Android signing keystore (base64 encoded) |
| `KEY_ALIAS` | GitHub Secrets | Keystore key alias |
| `KEY_PASSWORD` | GitHub Secrets | Key password |
| `STORE_PASSWORD` | GitHub Secrets | Keystore password |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | GitHub Secrets | Google Play API service account JSON |
| `APPSTORE_API_KEY_ID` | GitHub Secrets | App Store Connect API key ID |
| `APPSTORE_ISSUER_ID` | GitHub Secrets | App Store Connect issuer ID |
| `APPSTORE_API_PRIVATE_KEY` | GitHub Secrets | App Store Connect API private key (P8) |
| `PROD_ENV_JSON` | GitHub Secrets | Production env/prod.json content |
