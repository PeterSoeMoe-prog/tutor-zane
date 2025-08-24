import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../providers/content_providers.dart';
import '../../models/level.dart';
import '../../providers/progress_providers.dart';
import '../../providers/purchase_providers.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncLevels = ref.watch(levelsProvider);

    return Scaffold(
      body: asyncLevels.when(
        data: (LevelsRoot data) {
          // Determine recommended level from onboarding prefs and order levels accordingly.
          String? recommended = Hive.box('prefs').get('englishLevel') as String?;
          String? recommendedLevelId;
          if (recommended != null) {
            switch (recommended) {
              case 'beginner':
                recommendedLevelId = 'beginner';
                break;
              case 'intermediate':
                recommendedLevelId = 'intermediate';
                break;
              case 'advanced':
                // Current content uses id 'samples' titled 'Advance'. Map advanced -> samples.
                recommendedLevelId = 'samples';
                break;
            }
          }

          final levels = [...data.levels];
          if (recommendedLevelId != null) {
            levels.sort((a, b) {
              if (a.id == recommendedLevelId && b.id != recommendedLevelId) return -1;
              if (b.id == recommendedLevelId && a.id != recommendedLevelId) return 1;
              return 0;
            });
          }
          final items = <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Select a lesson to watch a YouTube video, then try a quick quiz.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
          ];

          for (int i = 0; i < levels.length; i++) {
            final level = levels[i];
            final purchase = ref.watch(purchaseServiceProvider);
            final unlocked = purchase.isLevelUnlocked(level.id);
            items.add(
              InkWell(
                onTap: () async {
                  if (unlocked) {
                    context.go('/levels/${level.id}');
                  } else {
                    // Dev-only unlock dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Level Locked'),
                        content: const Text('This level is locked. Unlock for testing?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Unlock')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await purchase.unlockLevel(level.id);
                      if (!context.mounted) return;
                      context.go('/levels/${level.id}');
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            level.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(width: 8),
                          if (recommendedLevelId != null && level.id == recommendedLevelId)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
                              ),
                            ),
                          if (!unlocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lock, size: 14, color: Colors.blueGrey),
                                  SizedBox(width: 4),
                                  Text('Locked', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
            final progress = ref.watch(progressServiceProvider);
            for (final lesson in level.lessons) {
              final completed = progress.isLessonCompleted(lesson.id) ||
                  progress.isLessonCompleted(lesson.youtubeId);
              items.add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Text(lesson.title),
                      subtitle: Text(lesson.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (completed)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.check_circle, color: Colors.green),
                            ),
                          const Icon(Icons.play_circle_fill),
                        ],
                      ),
                      onTap: () => context.go('/levels/video/${lesson.youtubeId}'),
                    ),
                  ),
                ),
              );
            }
            items.add(
              SizedBox(
                height: (level.id == 'beginner' || level.id == 'intermediate')
                    ? 48
                    : 16,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                expandedHeight: 140,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  title: Text(
                    'Choose your level',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: const Color(0xFF4A148C),
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFEDE7F6), // light purple
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(items),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to load content: $e'),
          ),
        ),
      ),
    );
  }
}
