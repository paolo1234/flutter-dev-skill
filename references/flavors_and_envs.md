# Flavors & Environments Reference — dev/staging/prod

## Environment Configuration with `--dart-define-from-file`

### Environment JSON Files

```
env/
├── dev.json              # Development
├── staging.json          # Staging
├── prod.json             # Production (in .gitignore)
└── prod.json.example     # Template for production
```

```json
// env/dev.json
{
  "APP_NAME": "MyApp Dev",
  "APP_SUFFIX": ".dev",
  "API_BASE_URL": "https://api-dev.example.com",
  "ENABLE_LOGGING": "true",
  "SENTRY_DSN": ""
}

// env/staging.json
{
  "APP_NAME": "MyApp Staging",
  "APP_SUFFIX": ".staging",
  "API_BASE_URL": "https://api-staging.example.com",
  "ENABLE_LOGGING": "true",
  "SENTRY_DSN": "https://xxx@sentry.io/yyy"
}

// env/prod.json
{
  "APP_NAME": "MyApp",
  "APP_SUFFIX": "",
  "API_BASE_URL": "https://api.example.com",
  "ENABLE_LOGGING": "false",
  "SENTRY_DSN": "https://xxx@sentry.io/zzz"
}
```

### EnvConfig Class

```dart
enum Flavor { dev, staging, prod }

class EnvConfig {
  static const appName = String.fromEnvironment('APP_NAME', defaultValue: 'MyApp Dev');
  static const appSuffix = String.fromEnvironment('APP_SUFFIX', defaultValue: '.dev');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  static const enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static Flavor get flavor {
    if (appSuffix.contains('dev')) return Flavor.dev;
    if (appSuffix.contains('staging')) return Flavor.staging;
    return Flavor.prod;
  }

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStaging => flavor == Flavor.staging;
  static bool get isProd => flavor == Flavor.prod;
}
```

### Running with Flavors

```bash
# Development
flutter run --dart-define-from-file=env/dev.json

# Staging
flutter run --dart-define-from-file=env/staging.json

# Production
flutter run --release --dart-define-from-file=env/prod.json

# Building
flutter build apk --release --dart-define-from-file=env/prod.json
flutter build ipa --release --dart-define-from-file=env/prod.json
```

### Android: Different Bundle IDs per Flavor

```groovy
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "com.example.myapp"
        // APP_SUFFIX is read from dart defines
        def appSuffix = project.hasProperty('dart-defines')
            ? project.property('dart-defines')
                .split(',')
                .collectEntries { entry ->
                    def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
                    [(pair[0]): pair.length > 1 ? pair[1] : '']
                }['APP_SUFFIX'] ?: ''
            : '.dev'
        applicationIdSuffix appSuffix
    }
}
```

### iOS: Different Bundle IDs per Flavor

Use Xcode build configurations or xcconfig files:

```
// ios/Flutter/Dev.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.myapp.dev
DISPLAY_NAME = MyApp Dev

// ios/Flutter/Staging.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.myapp.staging
DISPLAY_NAME = MyApp Staging

// ios/Flutter/Prod.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.myapp
DISPLAY_NAME = MyApp
```

### Main Entry Points per Flavor

```dart
// lib/main_dev.dart
void main() => bootstrap(
  () => const App(),
  flavor: Flavor.dev,
);

// lib/main_staging.dart
void main() => bootstrap(
  () => const App(),
  flavor: Flavor.staging,
);

// lib/main_prod.dart
void main() => bootstrap(
  () => const App(),
  flavor: Flavor.prod,
);
```

### VS Code Launch Configurations

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=env/dev.json"]
    },
    {
      "name": "Staging",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=env/staging.json"]
    },
    {
      "name": "Prod",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=env/prod.json"]
    }
  ]
}
```

### .gitignore for Sensitive Files

```gitignore
# Environment files with secrets
env/prod.json
env/staging.json

# Keep examples
!env/*.example
```
