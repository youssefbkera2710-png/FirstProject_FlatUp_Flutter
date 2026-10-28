import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/provines_models.dart';

class ActiveFiltersIndicator extends StatelessWidget {
  final LocalizationService localizations;
  final RangeValues priceRange;
  final ProvinesModels? selectedProvince;
  final String? selectedPropertyType;
  final int? selectedRoomsCount;
  final String? selectedRentType;
  final bool filtersApplied;
  final String userStatus;
  final Function() onClearFilters;
  final String Function(String) getPropertyTypeName;
  final String Function(String) getRentTypeName;

  const ActiveFiltersIndicator({
    Key? key,
    required this.localizations,
    required this.priceRange,
    this.selectedProvince,
    this.selectedPropertyType,
    this.selectedRoomsCount,
    this.selectedRentType,
    required this.filtersApplied,
    required this.userStatus,
    required this.onClearFilters,
    required this.getPropertyTypeName,
    required this.getRentTypeName,
  }) : super(key: key);

  String _getActiveFiltersText() {
    List<String> filters = [];

    if (selectedProvince != null) {
      filters.add(
        '${localizations.translate('province')}: ${selectedProvince!.name}',
      );
    }

    if (selectedPropertyType != null) {
      filters.add(
        '${localizations.translate('propertyType')}: ${getPropertyTypeName(selectedPropertyType!)}',
      );
    }

    if (selectedRoomsCount != null) {
      filters.add(
        '${localizations.translate('room')}: ${selectedRoomsCount == 5 ? "5 ${localizations.translate('room_or_more')} " : "$selectedRoomsCount"}',
      );
    }

    if (userStatus == 'tenant' && selectedRentType != null) {
      filters.add(
        '${localizations.translate('rentType')}: ${getRentTypeName(selectedRentType!)}',
      );
    }

    if (userStatus == 'tenant' &&
        filtersApplied &&
        (priceRange.start > 0 || priceRange.end < 1000000)) {
      filters.add(
        '${localizations.translate('priceRange')}: ${priceRange.start.round()} - ${priceRange.end.round()} ${localizations.translate('currency')}',
      );
    }

    return filters.isNotEmpty
        ? '${localizations.translate('activeFilters')}: ${filters.join(' | ')}'
        : localizations.translate('noActiveFilters');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _getActiveFiltersText(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClearFilters,
            child: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
