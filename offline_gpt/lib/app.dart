import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/ui/app_shell.dart';
import 'core/ui/tech_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/models/presentation/models_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

class OfflineGPTApp extends ConsumerStatefulWidget {
  const OfflineGPTApp({super.key});

  @override
  ConsumerState<OfflineGPTApp> createState() => _OfflineGPTAppState();
}

class _OfflineGPTAppState extends ConsumerState<OfflineGPTApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'OfflineGPT',
      theme: buildTechTheme(),
      routerConfig: router,
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final authController = ref.read(authControllerProvider.notifier);

  return GoRouter(
    initialLocation: '/chat',
    refreshListenable: GoRouterRefreshStream(authController.stream),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isProtectedRoute =
          state.matchedLocation == '/models' || state.matchedLocation == '/settings';

      if (!isAuthenticated && isProtectedRoute) {
        return '/auth';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/models';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/models',
            builder: (context, state) => const ModelsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
