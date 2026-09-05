import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/router.dart';
import 'core/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only disable certificate validation in debug mode for development servers
  // This allows older Android devices to connect to dev/staging environments
  // with self-signed or Let's Encrypt certificates that may not be in the system store.
  // NEVER enable this in production builds.
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    HttpOverrides.global = _DebugHttpOverrides();
  }
  
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: OprightApp()));
}

/// Development-only HTTP overrides to allow connections to staging servers
/// with certificates not in the system trust store (e.g., fly.dev, onrender.com).
/// This is ONLY active in debug/profile builds (const bool.fromEnvironment('dart.vm.product') == false).
/// Release builds (--release, --profile) will use the system's default certificate validation.
class _DebugHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Only allow our known development/staging domains
        // NEVER add production domains here
        return host.contains('onrender.com') || host.contains('fly.dev');
      };
  }
}

class OprightApp extends ConsumerWidget {
  const OprightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Opright',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      scrollBehavior: const _NoStretchScrollBehavior(),
    );
  }
}

// Disables Android's stretch overscroll effect so RefreshIndicator
// triggers correctly instead of stretching the screen.
class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
