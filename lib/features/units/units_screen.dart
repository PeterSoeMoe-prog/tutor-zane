import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/content_providers.dart';
import '../../models/level.dart';
import '../../providers/progress_providers.dart';
import '../../providers/assessment_providers.dart';
import '../../models/unit_dto.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key, required this.levelId});
  final String levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLevel = ref.watch(levelByIdProvider(levelId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
      ),
      body: asyncLevel.when(
        data: (LevelModel? level) {
          if (level == null) {
            return const Center(child: Text('Level not found'));
          }

          final asyncUnits = ref.watch(unitsByLevelProvider(level.id));

          return asyncUnits.when(
            data: (List<UnitDTO>? realUnits) {
              final progress = ref.read(progressServiceProvider);
              final units = <List<dynamic>>[];
              if (realUnits != null && realUnits.isNotEmpty) {
                for (final u in realUnits) {
                  units.add(u.lessons);
                }
              } else {
                const unitSize = 6;
                for (var i = 0; i < level.lessons.length; i += unitSize) {
                  units.add(level.lessons.sublist(
                    i,
                    (i + unitSize) > level.lessons.length ? level.lessons.length : i + unitSize,
                  ));
                }
              }

              final blocks = (units.length / 2).floor();

              return ListView(
                children: [
                  for (var index = 0; index < units.length; index++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        child: ListTile(
                          title: Text('${level.title} · Unit ${index + 1}'),
                          subtitle: Builder(builder: (context) {
                            final unitLessons = units[index];
                            final completed = unitLessons
                                .where((l) => progress.isLessonCompleted(l.id) || progress.isLessonCompleted(l.youtubeId))
                                .length;
                            final total = unitLessons.length;
                            return Text('$completed of $total lessons completed');
                          }),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/levels/${level.id}/unit/${index + 1}'),
                        ),
                      ),
                    ),
                  for (var blockIndex = 1; blockIndex <= blocks; blockIndex++)
                    Consumer(
                      builder: (context, ref2, _) {
                        final availableAsync = ref2.watch(
                          assessmentAvailabilityProvider((levelId: level.id, blockIndex: blockIndex)),
                        );
                        final svc = ref2.watch(assessmentServiceProvider);
                        final done = svc.isAssessmentCompleted(level.id, blockIndex);
                        return availableAsync.when(
                          data: (available) {
                            if (!available || done) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                color: Colors.indigo.withAlpha(15),
                                child: ListTile(
                                  leading: const Icon(Icons.assignment, color: Colors.indigo),
                                  title: Text('Assessment $blockIndex available'),
                                  subtitle: const Text('Short checkup after two units'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.go('/levels/${level.id}/assessment/$blockIndex'),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Failed to load units: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }
}
