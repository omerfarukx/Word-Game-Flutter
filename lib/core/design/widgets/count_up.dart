import 'package:flutter/material.dart';

/// Counts a number up from zero to its target when it first appears — used for
/// the big score on end-of-game screens so the result lands with a flourish.
///
/// If [value] isn't a plain integer (e.g. a time like "1:23" or text), it's
/// shown as-is with no animation, so the same widget is safe everywhere.
class CountUp extends StatefulWidget {
  const CountUp(
    this.value, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final String value;
  final TextStyle style;
  final Duration duration;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp>
    with SingleTickerProviderStateMixin {
  late final int? _target = _intOf(widget.value);
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  static int? _intOf(String s) =>
      RegExp(r'^-?\d+$').hasMatch(s.trim()) ? int.tryParse(s.trim()) : null;

  @override
  void initState() {
    super.initState();
    if (_target != null && _target != 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_target == null || _target == 0) {
      return Text(widget.value, style: widget.style);
    }
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final shown = (_target * _curve.value).round();
        return Text('$shown', style: widget.style);
      },
    );
  }
}
