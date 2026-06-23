import 'package:flutter/material.dart';

import '../utils/constants.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showTitle;

  const BrandLogo({
    super.key,
    this.size = 72,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navy,
                AppColors.navyMid,
                AppColors.sky,
              ],
            ),
          ),
          child: Icon(
            Icons.water_drop,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
              children: const [
                TextSpan(text: 'MD & V '),
                TextSpan(
                  text: 'Laundry',
                  style: TextStyle(color: AppColors.sky),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
