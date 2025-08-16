// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_status_provider.dart';
import '../../features/certificate/presentation/widgets/shell_page.dart';
import '../../features/certificate/presentation/pages/simple_verification_page.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authState = ref.read(authStatusProvider);
        final isLoggedIn = authState.value != null;
        
        // Public routes that don't require authentication
        final publicRoutes = ['/verify', '/verify/:certificateId'];
        final isPublicRoute = publicRoutes.any((route) => 
          state.matchedLocation.startsWith(route.split(':')[0]));
        
        if (isPublicRoute) {
          return null; // Allow access to public routes
        }
        
        // Redirect to login if not authenticated and trying to access protected routes
        if (!isLoggedIn && state.matchedLocation != '/login') {
          return '/login';
        }
        
        // Redirect to dashboard if authenticated and trying to access login
        if (isLoggedIn && state.matchedLocation == '/login') {
          return '/';
        }
        
        return null;
      },
      routes: [
        // Public route for certificate verification
        GoRoute(
          path: '/verify',
          name: 'verify',
          builder: (context, state) => const SimpleVerificationPage(),
        ),
        GoRoute(
          path: '/verify/:certificateId',
          name: 'verify-certificate',
          builder: (context, state) {
            final certificateId = state.pathParameters['certificateId']!;
            return SimpleVerificationPage(initialCertificateId: certificateId);
          },
        ),
        
        // Authentication route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        
        // Protected routes
        ShellRoute(
          builder: (context, state, child) => ShellPage(),
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SizedBox(), // The ShellPage handles the content
              ),
            ),
          ],
        ),
      ],
    );
  }
}