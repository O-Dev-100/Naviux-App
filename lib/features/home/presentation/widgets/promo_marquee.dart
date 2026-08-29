import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../../../core/constants/app_constants.dart';

class PromoMarquee extends StatelessWidget {
  const PromoMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppColors.primary,
      child: Marquee(
        text:
            '10% de descuento en tu primera compra NAVIUX10 • Gastos de envío gratis en península • Plazo de devolución 30 días',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 50.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
