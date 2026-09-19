import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo/features/cubit/auth_cubit.dart';
import 'package:flutter_todo/features/pages/login_page.dart';
import 'package:flutter_todo/features/pages/signin_page.dart';
import 'package:flutter_todo/features/home/cubit/home_cubit.dart';
import 'package:flutter_todo/features/home/pages/home_screen.dart';
import 'package:flutter_todo/features/onboarding/onboarding_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            BlocProvider(create: (_) => AuthCubit(), child: const LoginPage()),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) =>
            BlocProvider(create: (_) => AuthCubit(), child: const SigninPage()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            BlocProvider(create: (_) => HomeCubit(), child: const HomeScreen()),
      ),
    ],
  );
}
