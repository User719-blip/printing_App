import 'package:flutter/material.dart';
import 'package:printing_app/core/theme/apppaleet.dart';


class PlusWidget extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const PlusWidget({
    super.key,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // Square with rounded corners
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: animation.value * 2 * 3.14159,
              colors: AppPalette.sweepGradient,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppPalette.darkGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: AppPalette.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onPressed,
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    Icons.add,
                    color: AppPalette.whiteText,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}