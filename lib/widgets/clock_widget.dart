import 'dart:async';
import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  final Color color;
  final double? fontSize;
  final FontWeight fontWeight;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const ClockWidget({
    super.key,
    this.color = Colors.white,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.only(top: 40, right: 40),
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    setState(() {
      _time = "$hour:$minute";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final fontSize = widget.fontSize ?? screen.height * 0.06;

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: Text(
          _time,
          style: TextStyle(
            color: widget.color,
            fontSize: fontSize,
            fontWeight: widget.fontWeight,
          ),
        ),
      ),
    );
  }
}
