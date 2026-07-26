import 'package:flutter/material.dart';

class HeavenlyInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final double hoverScale;
  final bool enableHover;

  const HeavenlyInteraction({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
    this.hoverScale = 1.03,
    this.enableHover = true,
  });

  @override
  State<HeavenlyInteraction> createState() => _HeavenlyInteractionState();
}

class _HeavenlyInteractionState extends State<HeavenlyInteraction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1.0,
    );
    _scale = Tween<double>(begin: widget.scaleDown, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.reverse(); // Scale down
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.forward(); // Scale back up
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = ScaleTransition(
      scale: _scale,
      child: widget.child,
    );

    if (widget.enableHover) {
      result = AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuint,
        child: result,
      );
    }

    return MouseRegion(
      onEnter: widget.onTap != null && widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null && widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: result,
      ),
    );
  }
}
