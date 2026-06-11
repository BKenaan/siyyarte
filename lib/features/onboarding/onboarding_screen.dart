import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Three-slide onboarding (Track · Remind · Budget) with an inline language
/// switch, shown once. Calls [onDone] when finished/skipped.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    final slides = [
      (
        icon: Icons.event_available_outlined,
        title: t.onboardTrackTitle,
        body: t.onboardTrackBody
      ),
      (
        icon: Icons.notifications_active_outlined,
        title: t.onboardRemindTitle,
        body: t.onboardRemindBody
      ),
      (
        icon: Icons.payments_outlined,
        title: t.onboardBudgetTitle,
        body: t.onboardBudgetBody
      ),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Language toggle
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SegmentedButton<String>(
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: [
                      ButtonSegment(value: 'en', label: Text(t.english)),
                      ButtonSegment(value: 'ar', label: Text(t.arabic)),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (s) =>
                        ref.read(localeProvider.notifier).setLocale(s.first),
                  ),
                ),
                TextButton(onPressed: widget.onDone, child: Text(t.skip)),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: slides.length,
                itemBuilder: (context, i) {
                  final s = slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 96, color: AppColors.tailLightRed),
                        const SizedBox(height: 32),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(s.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.tailLightRed
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  if (isLast) {
                    widget.onDone();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(isLast ? t.getStarted : t.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
