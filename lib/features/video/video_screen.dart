import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../providers/progress_providers.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key, required this.lessonId});

  final String lessonId; // For YouTube, this is the videoId

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.lessonId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Video'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayerScaffold(
              controller: _controller,
              builder: (context, player) => player,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson: ${widget.lessonId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Watch the video, then proceed to the quiz to test your understanding.',
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    // Mark this lesson as completed using the progress service.
                    final progress = ref.read(progressServiceProvider);
                    final router = GoRouter.of(context);
                    await progress.markLessonCompleted(widget.lessonId);
                    if (!mounted) return;
                    router.go('/levels/quiz/${widget.lessonId}');
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Start Quiz'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
