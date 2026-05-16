import 'dart:async';

import 'package:flutter/material.dart';

class WorldBossTimer extends StatefulWidget {
  const WorldBossTimer({super.key});

  @override
  State<WorldBossTimer> createState() => _WorldBossTimerState();
}

class _WorldBossTimerState extends State<WorldBossTimer> {
  // ValueNotifier to precisely target rebuilds.
  final ValueNotifier<int> _millisecondsRemaining = ValueNotifier<int>(
    600000,
  ); // 10 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // @AETHER: We use a 100ms periodic timer, but crucially we only update a ValueNotifier.
    // This prevents the entire widget tree from rebuilding 10 times a second.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (_millisecondsRemaining.value > 0) {
        _millisecondsRemaining.value -= 100;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _millisecondsRemaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // @AETHER: We wrap the timer text in a RepaintBoundary. Since it changes
    // every 100ms, this isolates its painting from the rest of the UI.
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: _millisecondsRemaining,
        builder: (BuildContext context, int value, Widget? child) {
          final double seconds = value / 1000.0;
          return Text(
            'World Boss in: ${seconds.toStringAsFixed(1)}s',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          );
        },
      ),
    );
  }
}
