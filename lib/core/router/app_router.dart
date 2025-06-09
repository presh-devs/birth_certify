
import 'dart:async';
import 'package:birth_certify/features/certificate/presentation/widgets/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/registration/presentation/pages/registration_form_page.dart';
import '../../features/auth/presentation/providers/auth_status_provider.dart';


class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(ref.watch(authStatusProvider.stream)),
      redirect: (context, state) {
        final user = ref.read(authStatusProvider).asData?.value;
        final isLoggedIn = user != null;
        final loggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !loggingIn) return '/login';
        if (isLoggedIn && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const ShellPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegistrationFormPage(),
        ),
      ],
    );
  }
}


class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
