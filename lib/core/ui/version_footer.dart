import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';

class VersionFooter extends StatelessWidget {
  const VersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'v${AppConfig.version} (${AppConfig.buildNumber})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Déploiement : ${AppConfig.deployDate}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4E5073),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
