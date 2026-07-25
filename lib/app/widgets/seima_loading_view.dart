import 'package:flutter/material.dart';
import 'package:seima/app/theme/spacing.dart';

enum SeimaLoadingVariant { fullPage, compact, overlay }

class SeimaLoadingView extends StatefulWidget {
  final SeimaLoadingVariant variant;
  final String? message;
  final double? progress;

  const SeimaLoadingView({
    super.key,
    this.variant = SeimaLoadingVariant.fullPage,
    this.message,
    this.progress,
  });

  @override
  State<SeimaLoadingView> createState() => _SeimaLoadingViewState();
}

class _SeimaLoadingViewState extends State<SeimaLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (widget.variant) {
      case SeimaLoadingVariant.fullPage:
        return Scaffold(
          backgroundColor: cs.surface,
          body: Center(child: _buildContent(context, cs)),
        );
      case SeimaLoadingVariant.compact:
        return _buildContent(context, cs);
      case SeimaLoadingVariant.overlay:
        return Container(
          color: cs.surface.withValues(alpha: 0.85),
          child: Center(child: _buildContent(context, cs)),
        );
    }
  }

  Widget _buildContent(BuildContext context, ColorScheme cs) {
    final isCompact = widget.variant == SeimaLoadingVariant.compact;
    final iconSize = isCompact ? 48.0 : 80.0;

    return Semantics(
      label: widget.message ?? 'Loading',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) =>
                Transform.scale(scale: _pulse.value, child: child),
            child: Image.asset(
              'assets/startup_logo.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
          if (widget.progress != null) ...[
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: isCompact ? 120 : 200,
              child: LinearProgressIndicator(value: widget.progress),
            ),
          ],
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              widget.message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
