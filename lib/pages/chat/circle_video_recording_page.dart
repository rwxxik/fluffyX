// FluffyX: Circle video recording page (Telegram-like round video messages)
// Records video using the camera package with circular preview and sends as
// m.video event with `im.fluffy.video_message: true`.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Full-screen page for recording circle video messages.
/// Returns the recorded video file path via Navigator.pop on confirmation.
class CircleVideoRecordingPage extends StatefulWidget {
  const CircleVideoRecordingPage({super.key});

  @override
  State<CircleVideoRecordingPage> createState() =>
      _CircleVideoRecordingPageState();
}

class _CircleVideoRecordingPageState extends State<CircleVideoRecordingPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isDisposed = false;
  String? _recordedFilePath;
  String? _errorMessage;

  // Recording timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  static const int _maxDurationSeconds = 60;

  // Animation for pulsing record indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _previewDiameter = 250.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras available');
        return;
      }

      // Prefer front camera
      _selectedCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex < 0) _selectedCameraIndex = 0;

      await _setupCamera(_cameras[_selectedCameraIndex]);
    } catch (e) {
      Logs().w('Failed to initialize camera', e);
      if (!_isDisposed && mounted) {
        setState(() => _errorMessage = 'Camera error: $e');
      }
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    final previousController = _cameraController;
    if (previousController != null) {
      // Stop recording if switching camera mid-recording
      if (_isRecording) {
        await _stopRecording(discard: true);
      }
      await previousController.dispose();
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (!_isDisposed && mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      Logs().w('Failed to setup camera', e);
      if (!_isDisposed && mounted) {
        setState(() => _errorMessage = 'Camera initialization failed: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitialized = false);
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _startRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (_isRecording) return;

    try {
      await controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });
      _pulseController.repeat(reverse: true);
      // FluffyX: moved max-duration check outside setState to avoid calling
      // async _stopRecording inside a synchronous setState callback.
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        _elapsedSeconds++;
        if (_elapsedSeconds >= _maxDurationSeconds) {
          _stopRecording();
        } else {
          setState(() {});
        }
      });
    } catch (e) {
      Logs().w('Failed to start recording', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording({bool discard = false}) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isRecordingVideo) return;

    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      final file = await controller.stopVideoRecording();
      if (!_isDisposed && mounted) {
        if (discard) {
          // Delete the discarded file
          try {
            await File(file.path).delete();
          } catch (_) {}
          setState(() {
            _isRecording = false;
            _hasRecorded = false;
            _recordedFilePath = null;
          });
        } else {
          setState(() {
            _isRecording = false;
            _hasRecorded = true;
            _recordedFilePath = file.path;
          });
        }
      }
    } catch (e) {
      Logs().w('Failed to stop recording', e);
      if (!_isDisposed && mounted) {
        setState(() {
          _isRecording = false;
          _hasRecorded = false;
        });
      }
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _discardRecording() {
    if (_recordedFilePath != null) {
      try {
        File(_recordedFilePath!).delete();
      } catch (_) {}
    }
    setState(() {
      _hasRecorded = false;
      _recordedFilePath = null;
      _elapsedSeconds = 0;
    });
  }

  void _confirmAndSend() {
    if (_recordedFilePath != null) {
      Navigator.of(context).pop(_recordedFilePath);
    }
  }

  void _cancel() {
    if (_isRecording) {
      _stopRecording(discard: true);
    }
    if (_recordedFilePath != null) {
      try {
        File(_recordedFilePath!).delete();
      } catch (_) {}
    }
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _errorMessage != null
            ? _buildError()
            : !_isInitialized
                ? _buildLoading()
                : _buildRecordingUI(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _cancel,
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildRecordingUI() {
    return Column(
      children: [
        // Top bar with cancel and switch camera
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _cancel,
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              if (_cameras.length > 1 && !_hasRecorded)
                IconButton(
                  onPressed: _isRecording ? null : _switchCamera,
                  icon: Icon(
                    Icons.flip_camera_ios,
                    color: _isRecording ? Colors.white38 : Colors.white,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),

        const Spacer(),

        // Camera preview in circle with progress ring
        Center(
          child: SizedBox(
            width: _previewDiameter + 12,
            height: _previewDiameter + 12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring (shows elapsed recording time)
                if (_isRecording || _hasRecorded)
                  SizedBox(
                    width: _previewDiameter + 12,
                    height: _previewDiameter + 12,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: _elapsedSeconds / _maxDurationSeconds,
                        color: Colors.red,
                        backgroundColor: Colors.white24,
                        strokeWidth: 4,
                      ),
                    ),
                  ),

                // Circular camera preview
                ClipOval(
                  child: SizedBox(
                    width: _previewDiameter,
                    height: _previewDiameter,
                    child: _cameraController != null &&
                            _cameraController!.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!
                                  .value.previewSize!.height,
                              height:
                                  _cameraController!.value.previewSize!.width,
                              child: CameraPreview(_cameraController!),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                // Circular border
                Container(
                  width: _previewDiameter,
                  height: _previewDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording ? Colors.red : Colors.white24,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Timer display
        Text(
          _formatDuration(_elapsedSeconds),
          style: TextStyle(
            color: _isRecording ? Colors.red : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        const Spacer(),

        // Bottom controls
        Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: _hasRecorded ? _buildPostRecordControls() : _buildRecordButton(),
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 28 : 56,
                height: _isRecording ? 28 : 56,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.withValues(
                          alpha: _pulseAnimation.value,
                        )
                      : Colors.red,
                  borderRadius: BorderRadius.circular(
                    _isRecording ? 6 : 28,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostRecordControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Discard button
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _discardRecording,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white12,
                minimumSize: const Size(56, 56),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discard',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),

        // Send button
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _confirmAndSend,
              style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(64, 64),
              ),
              icon: const Icon(Icons.send, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for the circular progress ring around the camera preview.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
