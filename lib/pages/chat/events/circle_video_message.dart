import 'dart:io';

import 'package:fluffyx/utils/localized_exception_extension.dart';
import 'package:fluffyx/utils/platform_infos.dart';
import 'package:fluffyx/widgets/blur_hash.dart';
import 'package:fluffyx/widgets/mxc_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/error_reporter.dart';

// FluffyX: Circle video message widget (Telegram-like round video bubbles)
// Protocol: standard m.video event with custom field `im.fluffy.video_message: true`

class CircleVideoMessage extends StatefulWidget {
  final Event event;
  final Timeline? timeline;

  /// Diameter of the circle bubble
  static const double diameter = 200.0;

  const CircleVideoMessage(this.event, {this.timeline, super.key});

  /// Check if an event is a circle video message
  static bool isCircleVideoMessage(Event event) {
    return event.messageType == MessageTypes.Video &&
        event.content['im.fluffy.video_message'] == true;
  }

  @override
  State<CircleVideoMessage> createState() => _CircleVideoMessageState();
}

class _CircleVideoMessageState extends State<CircleVideoMessage> {
  VideoPlayerController? _videoController;
  bool _isMuted = true;
  bool _isLoading = false;
  bool _hasError = false;
  double? _downloadProgress;

  static const String _fallbackBlurHash = 'L5H2EC=PM+yV0g-mq.wG9c010J}I';

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadAndPlay() async {
    if (_isLoading || _videoController != null) return;
    if (!PlatformInfos.supportsVideoPlayer) return;

    setState(() => _isLoading = true);

    try {
      final fileSize = widget.event.content
          .tryGetMap<String, Object?>('info')
          ?.tryGet<int>('size');

      final videoFile = await widget.event.downloadAndDecryptAttachment(
        onDownloadProgress: fileSize == null
            ? null
            : (progress) {
                if (!mounted) return;
                final pct = progress / fileSize;
                setState(() {
                  _downloadProgress = pct < 1 ? pct : null;
                });
              },
      );

      late VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.networkUrl(
          Uri.dataFromBytes(videoFile.bytes, mimeType: videoFile.mimeType),
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final fileName = Uri.encodeComponent(
          widget.event.attachmentOrThumbnailMxcUrl()!.pathSegments.last,
        );
        final file = File('${tempDir.path}/${fileName}_${videoFile.name}');
        if (!await file.exists()) {
          await file.writeAsBytes(videoFile.bytes);
        }
        controller = VideoPlayerController.file(file);
      }

      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0); // Start muted
      controller.play();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isLoading = false;
        _downloadProgress = null;
      });
    } on IOException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toLocalizedString(context))),
      );
    } catch (e, s) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ErrorReporter(context, 'Unable to play circle video').onErrorCallback(e, s);
    }
  }

  void _toggleMute() {
    final controller = _videoController;
    if (controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndPlay());
  }

  @override
  Widget build(BuildContext context) {
    const diameter = CircleVideoMessage.diameter;
    final blurHash =
        (widget.event.infoMap as Map<String, dynamic>).tryGet<String>(
              'xyz.amorgan.blurhash',
            ) ??
            _fallbackBlurHash;

    final infoMap = widget.event.content.tryGetMap<String, Object?>('info');
    final durationInt = infoMap?.tryGet<int>('duration');
    final duration =
        durationInt == null ? null : Duration(milliseconds: durationInt);

    final controller = _videoController;

    return GestureDetector(
      onTap: _toggleMute,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circle clip
            ClipOval(
              child: SizedBox(
                width: diameter,
                height: diameter,
                child: controller != null && controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      )
                    : _buildThumbnail(blurHash, diameter),
              ),
            ),

            // Circular border
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(80),
                  width: 2,
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              SizedBox(
                width: diameter,
                height: diameter,
                child: CircularProgressIndicator(
                  value: _downloadProgress,
                  strokeWidth: 3,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

            // Error icon
            if (_hasError && controller == null)
              CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),

            // Play icon (when video not yet loaded and not loading)
            if (controller == null && !_isLoading && !_hasError)
              CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),

            // Mute indicator (bottom-right)
            if (controller != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Duration badge (bottom-left)
            if (duration != null)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String blurHash, double diameter) {
    if (widget.event.hasThumbnail) {
      return MxcImage(
        event: widget.event,
        isThumbnail: true,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        placeholder: (context) => BlurHash(
          blurhash: blurHash,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
        ),
      );
    }
    return BlurHash(
      blurhash: blurHash,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
    );
  }
}
