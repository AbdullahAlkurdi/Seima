import 'package:flutter/material.dart';
import 'package:mindora/app/theme/spacing.dart';

enum MindoraLoadingVariant { fullPage, compact, overlay }

class MindoraLoadingView extends StatefulWidget {
  final MindoraLoadingVariant variant;
  final String? message;
  final double? progress;

  const MindoraLoadingView({
    super.key,
    this.variant = MindoraLoadingVariant.fullPage,
    this.message,
    this.progress,
  });

  @override
  State<MindoraLoadingView> createState() => _MindoraLoadingViewState();
}

class _MindoraLoadingViewState extends State<MindoraLoadingView>
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
      case MindoraLoadingVariant.fullPage:
        return Scaffold(
          backgroundColor: cs.surface,
          body: Center(child: _buildContent(context, cs)),
        );
      case MindoraLoadingVariant.compact:
        return _buildContent(context, cs);
      case MindoraLoadingVariant.overlay:
        return Container(
          color: cs.surface.withValues(alpha: 0.85),
          child: Center(child: _buildContent(context, cs)),
        );
    }
  }

  Widget _buildContent(BuildContext context, ColorScheme cs) {
    final isCompact = widget.variant == MindoraLoadingVariant.compact;
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
              'assets/Mindora_Icon.png',
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
