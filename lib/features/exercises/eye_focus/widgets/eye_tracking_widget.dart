import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/eye_tracking_exercise.dart';

class EyeTrackingWidget extends StatefulWidget {
  final EyeTrackingExercise exercise;
  final VoidCallback onComplete;

  const EyeTrackingWidget({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<EyeTrackingWidget> createState() => _EyeTrackingWidgetState();
}

class _EyeTrackingWidgetState extends State<EyeTrackingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _setupAnimation();
    _startExercise();
  }

  void _setupAnimation() {
    switch (widget.exercise.pattern) {
      case TrackingPattern.horizontal:
        _animation = Tween<Offset>(
          begin: const Offset(-0.8, 0),
          end: const Offset(0.8, 0),
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        break;
      case TrackingPattern.vertical:
        _animation = Tween<Offset>(
          begin: const Offset(0, -0.8),
          end: const Offset(0, 0.8),
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        break;
      case TrackingPattern.diagonal:
        _animation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(-0.8, -0.8),
              end: const Offset(0.8, 0.8),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0.8, -0.8),
              end: const Offset(-0.8, 0.8),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50.0,
          ),
        ]).animate(_controller);
        break;
      case TrackingPattern.circular:
        _animation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0.8, 0),
              end: const Offset(0, 0.8),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0, 0.8),
              end: const Offset(-0.8, 0),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(-0.8, 0),
              end: const Offset(0, -0.8),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0, -0.8),
              end: const Offset(0.8, 0),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25.0,
          ),
        ]).animate(_controller);
        break;
      case TrackingPattern.random:
        _animation = TweenSequence<Offset>([
          for (int i = 0; i < 4; i++)
            TweenSequenceItem(
              tween: Tween<Offset>(
                begin: Offset(
                  -0.8 + Random().nextDouble() * 1.6,
                  -0.8 + Random().nextDouble() * 1.6,
                ),
                end: Offset(
                  -0.8 + Random().nextDouble() * 1.6,
                  -0.8 + Random().nextDouble() * 1.6,
                ),
              ).chain(CurveTween(curve: Curves.easeInOut)),
              weight: 25.0,
            ),
        ]).animate(_controller);
        break;
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  void _startExercise() {
    _remainingSeconds = widget.exercise.durationInSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Kalan Süre: $_remainingSeconds saniye',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: SlideTransition(
              position: _animation,
              child: Container(
                width: widget.exercise.targetSize,
                height: widget.exercise.targetSize,
                decoration: BoxDecoration(
                  color: widget.exercise.targetColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
