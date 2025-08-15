import 'package:flutter/material.dart';
import 'package:printing_app/core/theme/apppaleet.dart';

class InstructionsCard extends StatelessWidget {
  final Animation<double> animation;

  const InstructionsCard({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: animation.value * 2 * 3.14159,
              colors: AppPalette.sweepGradient,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppPalette.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How to use?',
                    style: TextStyle(
                      color: AppPalette.whiteText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Click on "+" button on right side and then add your image files (PDF, DOCX, TXT) and select number of copies and then hit print button.',
                    style: TextStyle(
                      color: AppPalette.darkGrayText,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}