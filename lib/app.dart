import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_controller.dart';
import 'features/profile/profile_setup_screen.dart';
import 'features/reminders/fcm_service.dart';
import 'features/shell/home_shell.dart';

class SiyyarteApp extends ConsumerWidget {
  const SiyyarteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return MaterialApp(
      title: 'Siyyarte',
      debugShowCheckedModeBanner: false,
      theme: isArabic
          ? AppTheme.withArabicFont(AppTheme.light())
          : AppTheme.light(),
      darkTheme: isArabic
          ? AppTheme.withArabicFont(AppTheme.dark())
          : AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Directionality (LTR/RTL) is handled automatically by MaterialApp from
      // the active locale — Arabic renders fully right-to-left.
      home: const _Root(),
    );
  }
}

/// Top-level routing: onboarding (once) → auth → profile setup → home.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(onboardingSeenProvider);
    if (!seen) {
      return OnboardingScreen(
        onDone: () {
          ref.read(sharedPrefsProvider).setBool(onboardingSeenKey, true);
          ref.read(onboardingSeenProvider.notifier).state = true;
        },
      );
    }
    return const _AuthGate();
  }
}

/// Routes between the login screen and the app based on auth state.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Register for FCM push once a user is signed in (no-op without Firebase).
    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) FcmService.instance.register(user.uid);
    });

    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) {
        if (user == null) return const LoginScreen();
        // Force first-run profile setup until a city is chosen.
        final profile = ref.watch(profileProvider);
        if (profile == null || profile.city == null) {
          return const ProfileSetupScreen();
        }
        return const HomeShell();
      },
    );
  }
}
