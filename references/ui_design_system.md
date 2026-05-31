# UI Design System Reference — Typography, Colors, Components

## ThemeData Structure

```dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme(Brightness.light),
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    snackBarTheme: _snackBarTheme,
    bottomNavigationBarTheme: _bottomNavTheme,
    navigationBarTheme: _navigationBarTheme,
    dialogTheme: _dialogTheme,
    bottomSheetTheme: _bottomSheetTheme,
    dividerTheme: _dividerTheme,
    chipTheme: _chipTheme,
    floatingActionButtonTheme: _fabTheme,
    pageTransitionsTheme: _pageTransitionsTheme,
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    textTheme: _textTheme,
    // ... same component themes, colors adapt via colorScheme
  );
}
```

## Typography with Google Fonts

```yaml
dependencies:
  google_fonts: ^6.2.1
```

```dart
class AppTypography {
  static TextTheme get textTheme {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
```

### Recommended Fonts by App Type
| App Type | Font | Why |
|---|---|---|
| Professional / Business | Inter, Roboto | Clean, neutral, highly readable |
| Creative / Lifestyle | Outfit, Poppins | Modern, friendly, rounded |
| Finance / Data-heavy | DM Sans, Source Sans 3 | Excellent number rendering |
| News / Reading | Merriweather (headings) + Source Serif 4 (body) | Optimized for long reading |
| Minimal / Luxury | Manrope, Plus Jakarta Sans | Elegant, geometric |

## Color System (Material 3)

### WCAG Contrast Requirements
- **Normal text (< 18sp)**: 4.5:1 contrast ratio minimum
- **Large text (≥ 18sp bold or ≥ 24sp)**: 3:1 contrast ratio minimum
- **UI components**: 3:1 against background

### Color Scheme Template
```dart
class AppColors {
  // Generate from a seed color using Material Theme Builder
  // https://m3.material.io/theme-builder
  
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF...),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF...),
    onPrimaryContainer: Color(0xFF...),
    secondary: Color(0xFF...),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF...),
    onSecondaryContainer: Color(0xFF...),
    tertiary: Color(0xFF...),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF1A1C1E),
    surfaceContainerHighest: Color(0xFFE0E2E5),
    outline: Color(0xFF72787E),
    outlineVariant: Color(0xFFC2C7CE),
  );

  // Semantic colors (not in Material, but useful)
  static const success = Color(0xFF2E7D32);
  static const onSuccess = Color(0xFFFFFFFF);
  static const warning = Color(0xFFF57F17);
  static const onWarning = Color(0xFF000000);
  static const info = Color(0xFF1565C0);
  static const onInfo = Color(0xFFFFFFFF);
}
```

## Spacing System (8pt Grid)

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Page padding
  static const pagePadding = EdgeInsets.symmetric(horizontal: 16);
  static const pageVerticalPadding = EdgeInsets.symmetric(vertical: 16);
  static const allPadding = EdgeInsets.all(16);

  // Card padding
  static const cardPadding = EdgeInsets.all(16);
  static const cardPaddingCompact = EdgeInsets.all(12);

  // List item spacing
  static const listItemSpacing = 8.0;
  static const sectionSpacing = 24.0;
}
```

## Border Radius

```dart
class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double circular = 999;

  static final small = BorderRadius.circular(sm);
  static final medium = BorderRadius.circular(md);
  static final large = BorderRadius.circular(lg);
  static final extraLarge = BorderRadius.circular(xl);
  static final circle = BorderRadius.circular(circular);
}
```

## Component Themes

### Buttons
```dart
static final _filledButtonTheme = FilledButtonThemeData(
  style: FilledButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
);

static final _outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
);
```

### Text Fields
```dart
static final _inputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: Colors.transparent,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(borderRadius: AppRadius.medium),
  enabledBorder: OutlineInputBorder(
    borderRadius: AppRadius.medium,
    borderSide: BorderSide(color: AppColors.lightColorScheme.outline),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: AppRadius.medium,
    borderSide: BorderSide(color: AppColors.lightColorScheme.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: AppRadius.medium,
    borderSide: BorderSide(color: AppColors.lightColorScheme.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: AppRadius.medium,
    borderSide: BorderSide(color: AppColors.lightColorScheme.error, width: 2),
  ),
);
```

### Cards
```dart
static final _cardTheme = CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.medium,
    side: BorderSide(color: AppColors.lightColorScheme.outlineVariant),
  ),
  clipBehavior: Clip.antiAlias,
);
```

## Micro-Animations

### Page Transitions
```dart
static final _pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
  },
);
```

### Standard Durations
```dart
class AppDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const pageTransition = Duration(milliseconds: 300);
}
```

### Standard Curves
```dart
class AppCurves {
  static const standard = Curves.easeInOut;
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
  static const emphasize = Curves.easeInOutCubicEmphasized;
}
```

### Staggered List Animation
```dart
class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

## Responsive & Device-Aware Design (R31)

### Breakpoints
| Category | Width | Examples |
|----------|-------|---------|
| Small phone | ≤ 360px | iPhone SE, Galaxy S21 |
| Standard phone | 361-414px | iPhone 14, Pixel 7 |
| Large phone | 415-480px | iPhone 15 Pro Max |
| Tablet | 481-1024px | iPad, Galaxy Tab |
| Desktop | > 1024px | Web, Windows, macOS |

### Responsive Extension
```dart
extension ResponsiveExtensions on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600 && MediaQuery.sizeOf(this).width < 1200;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1200;
  
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  
  EdgeInsets get responsivePadding => EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : isTablet ? 32 : 64,
  );
}
```

### Safe Area — ALWAYS Required
```dart
// ✅ Correct: SafeArea inside Scaffold body
Scaffold(
  body: SafeArea(
    child: Column(...),
  ),
);

// ✅ Also correct: using MediaQuery padding
Padding(
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top,
    bottom: MediaQuery.of(context).padding.bottom,
  ),
  child: content,
);

// ❌ WRONG: Content under notch/status bar
Scaffold(body: Column(...)); // No SafeArea!
```

### Text Overflow — NEVER Assume Single Line
```dart
// ✅ Title with ellipsis
Text(
  longTitle,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
);

// ✅ Flexible text in Row
Row(
  children: [
    const Icon(Icons.star),
    const SizedBox(width: 8),
    Flexible( // NOT Expanded if you want natural sizing
      child: Text(
        veryLongText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
);

// ❌ WRONG: Fixed width for text
SizedBox(width: 200, child: Text(dynamicText)); // Will overflow!
```

### Keyboard Handling for Forms
```dart
// ✅ Form that scrolls when keyboard appears
Scaffold(
  // DO NOT set resizeToAvoidBottomInset: false on form screens!
  body: SafeArea(
    child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss on tap outside
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                textInputAction: TextInputAction.next, // Go to next field
              ),
              TextFormField(
                textInputAction: TextInputAction.done, // Submit on last field
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
```

### Scroll Requirement
Every screen whose content could exceed screen height MUST be scrollable:
```dart
// ✅ Detail screen with scroll
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Image, title, description, actions, etc.
      // This WILL exceed small screens
    ],
  ),
);

// ❌ WRONG: Column without scroll for long content
Column(
  children: [/* many widgets */], // Overflow on small screens!
);
```

### Font Scaling Support
```dart
// Test with large text: 1.5x scale
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: const TextScaler.linear(1.5),
  ),
  child: yourWidget,
);

// Respect reduce motion preference
final reduceMotion = MediaQuery.of(context).disableAnimations;
AnimatedContainer(
  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
);
```

### Permission Pre-Ask Dialog Pattern (R30)
```dart
/// Show educational dialog BEFORE system permission request
Future<bool> showPermissionPreAsk({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String description,
  required String benefit,
  required String denyFallback,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            benefit,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Consenti'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non ora — $denyFallback'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
  return result ?? false;
}

// Usage:
// final agreed = await showPermissionPreAsk(
//   context: context,
//   icon: Icons.camera_alt,
//   title: 'Accesso alla fotocamera',
//   description: 'Per scattare una foto del tuo profilo',
//   benefit: 'Potrai personalizzare il tuo avatar',
//   denyFallback: 'userò un avatar predefinito',
// );
// if (agreed) {
//   final status = await Permission.camera.request();
//   // handle status...
// }
```
```
