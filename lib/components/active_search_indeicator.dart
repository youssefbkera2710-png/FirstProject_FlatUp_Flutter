import 'package:flat_up/Helper/localization_service.dart';
import 'package:flutter/material.dart';

class ActiveSearchIndicator extends StatelessWidget {
  final String searchQuery;
  final Function() onClear;

  const ActiveSearchIndicator({
    Key? key,
    required this.searchQuery,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${localizationService.translate('search')}: "$searchQuery"',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
