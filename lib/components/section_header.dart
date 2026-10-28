
import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final LocalizationService localizations;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.secondary,
            ),
          ),
          IconButton(
            onPressed: onSeeAll,
            tooltip: localizations.translate('filter'),
            icon: Icon(
              Icons.filter_alt
            ),
           color: colors.secondary,
          ),
        ],
      ),
    );
  }
}