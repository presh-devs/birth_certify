import 'package:birth_certify/features/auth/presentation/pages/login_page.dart';
import 'package:birth_certify/features/certificate/presentation/pages/certificate_list_page.dart';
import 'package:birth_certify/features/registration/presentation/pages/registration_form_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) =>  LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) =>  CertificateListPage(),
        routes: [
          GoRoute(
            path: 'certificates',
            name: 'certificates',
            builder: (context, state) =>  CertificateListPage(),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) =>  RegistrationFormPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('404: Page not found\n${state.error}', textAlign: TextAlign.center),
      ),
    ),
  );
}
