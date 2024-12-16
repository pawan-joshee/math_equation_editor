import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/math_expression/math_expression_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'math_expression/pages/math_keyboard_page.dart';
import 'math_expression/services/settings_service.dart';

// Initialize app asynchronously
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize SettingsService with SharedPreferences
  final settingsService = SettingsService(sharedPreferences: sharedPreferences);
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text('An error occurred'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                BlocProvider<SettingsBloc>(
                  create: (_) => SettingsBloc(settingsService: settingsService)
                    ..add(LoadSettings()),
                  lazy: false, // Initialize immediately
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  };
  // Run the app
  runApp(MyApp(settingsService: settingsService));
}

void main() {
  bootstrap();
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MathExpressionBloc>(
          create: (_) => MathExpressionBloc(),
          lazy: false, // Initialize immediately
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(settingsService: settingsService)
            ..add(LoadSettings()),
          lazy: false, // Initialize immediately
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Math Equation Editor',
            theme: _getThemeData(state),
            debugShowCheckedModeBanner: false,
            home: _buildHome(context, state),
          );
        },
      ),
    );
  }

  ThemeData _getThemeData(SettingsState state) {
    if (state is SettingsLoadSuccess) {
      return state.settings.highContrastMode
          ? ThemeData.dark()
          : ThemeData.light();
    }
    return ThemeData.light();
  }

  Widget _buildHome(BuildContext context, SettingsState state) {
    if (state is SettingsLoadInProgress) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (state is SettingsLoadFailure) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load settings'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    context.read<SettingsBloc>().add(LoadSettings()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return const MathKeyboardPage();
  }
}
