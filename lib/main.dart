import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/audio_helper.dart';
import 'features/library/library_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: Builder(
        builder: (context) {
          // Initialize AudioHelper with provider container
          AudioHelper.initialize(ProviderScope.containerOf(context));
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rabbit - 日语精听',
      theme: AppTheme.lightTheme,
      home: const LibraryScreen(),
    );
  }
}
