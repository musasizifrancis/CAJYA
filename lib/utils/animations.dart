import 'package:flutter/material.dart';

class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeInAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({required this.child});

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: 0.6 + (_controller.value * 0.4), child: child);
      },
      child: widget.child,
    );
  }
}

// Aliases and additional animation widgets
typedef FadeInWidget = FadeInAnimation;

enum SlideDirection { up, down, left, right }

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;

  const SlideInWidget({
    required this.child,
    this.direction = SlideDirection.up,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  _SlideInWidgetState createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    
    Offset begin = Offset.zero;
    switch (widget.direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }
    
    _offsetAnimation = Tween<Offset>(begin: begin, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}

class ScaleInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ScaleInWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  _ScaleInWidgetState createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
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
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
