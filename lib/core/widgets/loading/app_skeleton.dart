import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';

class AppSkeletonShimmer extends StatefulWidget {
  const AppSkeletonShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final bool enabled;
  final Duration duration;

  @override
  State<AppSkeletonShimmer> createState() => _AppSkeletonShimmerState();
}

class _AppSkeletonShimmerState extends State<AppSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppSkeletonShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    }

    if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return _AppSkeletonShimmerScope(
      animation: _controller,
      child: widget.child,
    );
  }
}

class _AppSkeletonShimmerScope extends InheritedWidget {
  const _AppSkeletonShimmerScope({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  static _AppSkeletonShimmerScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AppSkeletonShimmerScope>();
  }

  @override
  bool updateShouldNotify(_AppSkeletonShimmerScope oldWidget) {
    return animation != oldWidget.animation;
  }
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final shimmerScope = _AppSkeletonShimmerScope.maybeOf(context);

    if (shimmerScope == null) {
      return _SkeletonBoxContent(
        width: width,
        height: height,
        borderRadius: borderRadius,
        margin: margin,
      );
    }

    return AnimatedBuilder(
      animation: shimmerScope.animation,
      builder: (context, child) {
        return _SkeletonBoxContent(
          width: width,
          height: height,
          borderRadius: borderRadius,
          margin: margin,
          shimmerValue: shimmerScope.animation.value,
        );
      },
    );
  }
}

class _SkeletonBoxContent extends StatelessWidget {
  const _SkeletonBoxContent({
    required this.height,
    required this.borderRadius,
    this.width,
    this.margin,
    this.shimmerValue,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final double? shimmerValue;

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.border.withValues(alpha: 0.72);
    final highlightColor = AppColors.background.withValues(alpha: 0.96);

    final value = shimmerValue;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: value == null ? baseColor : null,
        gradient: value == null
            ? null
            : LinearGradient(
                begin: Alignment(-1.2 + value * 2.4, -0.3),
                end: Alignment(-0.2 + value * 2.4, 0.3),
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.25, 0.5, 0.75],
              ),
      ),
    );
  }
}

class AppSkeletonLine extends StatelessWidget {
  const AppSkeletonLine({super.key, this.width, this.height = 12, this.margin});

  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      width: width,
      height: height,
      borderRadius: 999,
      margin: margin,
    );
  }
}

class AppSkeletonCircle extends StatelessWidget {
  const AppSkeletonCircle({super.key, required this.size, this.margin});

  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }
}
