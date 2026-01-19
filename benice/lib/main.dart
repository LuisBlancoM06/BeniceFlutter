import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/repository_providers.dart';
import 'presentation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es', null);

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BeniceAstroApp(),
    ),
  );
}

class BeniceAstroApp extends ConsumerWidget {
  const BeniceAstroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BeniceAstro - Tienda de Mascotas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Ajustar el factor de escala del texto si es necesario
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
