import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/levels/levels_screen.dart';
import 'features/video/video_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/results/results_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/units/units_screen.dart';
import 'features/units/unit_detail_screen.dart';
import 'features/assessment/assessment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Open commonly used boxes upfront so routing can synchronously read prefs.
  await Hive.openBox('prefs');
  await Hive.openBox('progress');
  runApp(const ProviderScope(child: TutorZaneApp()));
}

class TutorZaneApp extends StatelessWidget {
  const TutorZaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
          routes: [
            GoRoute(
              path: 'levels',
              builder: (context, state) => const LevelsScreen(),
              routes: [
                GoRoute(
                  path: ':levelId',
                  builder: (context, state) => UnitsScreen(
                    levelId: state.pathParameters['levelId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'unit/:unitNumber',
                      builder: (context, state) => UnitDetailScreen(
                        levelId: state.pathParameters['levelId']!,
                        unitNumber: int.tryParse(state.pathParameters['unitNumber'] ?? '1') ?? 1,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'video/:lessonId',
                  builder: (context, state) => VideoScreen(
                    lessonId: state.pathParameters['lessonId'] ?? 'demo',
                  ),
                ),
                GoRoute(
                  path: 'quiz/:lessonId',
                  builder: (context, state) => QuizScreen(
                    lessonId: state.pathParameters['lessonId'] ?? 'demo',
                  ),
                ),
                GoRoute(
                  path: ':levelId/assessment/:blockIndex',
                  builder: (context, state) => AssessmentScreen(
                    levelId: state.pathParameters['levelId']!,
                    blockIndex: int.tryParse(state.pathParameters['blockIndex'] ?? '1') ?? 1,
                  ),
                ),
                GoRoute(
                  path: 'results',
                  builder: (context, state) => const ResultsScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final prefs = Hive.box('prefs');
        final done = prefs.get('onboardingDone') == true;
        final goingToOnboarding = state.matchedLocation == '/onboarding' || state.matchedLocation == '/onboarding/';
        if (!done && !goingToOnboarding) {
          return '/onboarding';
        }
        if (done && goingToOnboarding) {
          return '/';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Tutor Zane',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
