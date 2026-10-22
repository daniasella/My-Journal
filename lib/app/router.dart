import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/config/app_constants.dart';
import '../features/auth/domain/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/home/presentation/main_shell_screen.dart';
import '../features/planner/presentation/task_form_screen.dart';
import '../features/journal/presentation/journal_editor_screen.dart';
import '../features/tracker/presentation/habit_form_screen.dart';
import '../features/tracker/presentation/goal_form_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/pdf_export/presentation/pdf_export_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppConstants.routeHome,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeRegister ||
          state.matchedLocation == AppConstants.routeWelcome ||
          state.matchedLocation == AppConstants.routeForgotPassword;

      // If user is not authenticated and trying to visit private route
      if (!isAuth && !isLoggingIn) {
        // If initial loading, stay on welcome/splash
        if (authState is AuthInitial || authState is AuthLoading) {
          return null;
        }
        return AppConstants.routeWelcome;
      }

      // If user is authenticated and tries to visit auth pages
      if (isAuth && isLoggingIn) {
        return AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeWelcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const MainShellScreen(initialIndex: 0),
      ),
      GoRoute(
        path: AppConstants.routePlanner,
        builder: (context, state) => const MainShellScreen(initialIndex: 1),
      ),
      GoRoute(
        path: AppConstants.routeJournal,
        builder: (context, state) => const MainShellScreen(initialIndex: 2),
      ),
      GoRoute(
        path: AppConstants.routeTracker,
        builder: (context, state) => const MainShellScreen(initialIndex: 3),
      ),
      GoRoute(
        path: AppConstants.routeInsight,
        builder: (context, state) => const MainShellScreen(initialIndex: 4),
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.routeEditProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppConstants.routePdfExport,
        builder: (context, state) => const PdfExportScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAddTask,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAddJournal,
        builder: (context, state) => const JournalEditorScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAddHabit,
        builder: (context, state) => const HabitFormScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAddGoal,
        builder: (context, state) => const GoalFormScreen(),
      ),
    ],
  );
});
