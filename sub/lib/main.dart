import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomeFixApp());
}

class HomeFixApp extends StatelessWidget {
  const HomeFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      /// Use our custom theme
      theme: AppTheme.lightTheme,

      /// Use go_router configuration
      routerConfig: AppRouter.router,
    );
  }
}
