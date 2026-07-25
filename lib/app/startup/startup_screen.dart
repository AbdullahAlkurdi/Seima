import 'package:flutter/material.dart';

class StartupScreen extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const StartupScreen({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final effectiveOpacity = _controller.value < 0.7
            ? _opacity.value
            : _exitOpacity.value;

        return Stack(
          children: [
            if (_controller.value < 0.7)
              Opacity(
                opacity: _opacity.value,
                child: Transform.scale(scale: _scale.value, child: child),
              )
            else
              child ?? const SizedBox.shrink(),
            if (_controller.value < 1.0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: cs.surface,
                    child: Center(
                      child: Opacity(
                        opacity: effectiveOpacity,
                        child: Image.asset(
                          'assets/Seima_Icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
