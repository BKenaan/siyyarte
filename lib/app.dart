import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/siyyarte_logo.dart';
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
      home: const _Entrance(),
    );
  }
}

/// Branded entrance: the emblem scales/fades in over the brand navy, then
/// cross-fades into the app. Picks up where the static native splash ends so
/// opening the app feels like one continuous motion.
class _Entrance extends StatefulWidget {
  const _Entrance();

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _done ? const _Root() : const _IntroSplash(),
    );
  }
}

class _IntroSplash extends StatelessWidget {
  const _IntroSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandNavy,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.scale(scale: 0.72 + 0.28 * v, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SiyyarteMark(size: 148),
              const SizedBox(height: 20),
              Text(
                'SIYYARTE',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'سيّارتي',
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.accentOrange.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
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
        // Force first-run profile setup until a city is chosen — but wait for
        // the cloud profile first so an existing account isn't re-asked.
        final profile = ref.watch(profileProvider);
        final controller = ref.read(profileProvider.notifier);
        if ((profile == null || profile.city == null) &&
            !controller.remoteChecked) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (profile == null || profile.city == null) {
          return const ProfileSetupScreen();
        }
        return const HomeShell();
      },
    );
  }
}
