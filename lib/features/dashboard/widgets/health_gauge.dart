import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../maintenance/models/scheduled_service.dart';

/// Instrument-cluster style health ring — Green/Yellow/Red with a label, so
/// status is never conveyed by color alone (accessibility).
class HealthGauge extends StatelessWidget {
  const HealthGauge({super.key, required this.status, this.size = 160});

  final HealthStatus status;
  final double size;

  Color get _color => switch (status) {
        HealthStatus.good => AppColors.healthGood,
        HealthStatus.upcoming => AppColors.healthUpcoming,
        HealthStatus.overdue => AppColors.healthOverdue,
      };

  double get _value => switch (status) {
        HealthStatus.good => 1.0,
        HealthStatus.upcoming => 0.6,
        HealthStatus.overdue => 0.25,
      };

  String _label(AppLocalizations t) => switch (status) {
        HealthStatus.good => t.healthGood,
        HealthStatus.upcoming => t.healthUpcoming,
        HealthStatus.overdue => t.healthOverdue,
      };

  IconData get _icon => switch (status) {
        HealthStatus.good => Icons.check_circle_outline,
        HealthStatus.upcoming => Icons.access_time,
        HealthStatus.overdue => Icons.warning_amber_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(_value, _color,
            Theme.of(context).colorScheme.surfaceContainerHighest),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, color: _color, size: 30),
              const SizedBox(height: 4),
              Text(_label(t),
                  style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.color, this.track);

  final double value;
  final Color color;
  final Color track;

  static const _start = math.pi * 0.75; // 270°-sweep gauge
  static const _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, base);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep * value.clamp(0.0, 1.0), false, fg);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
