import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:flat_up/widget/dropSellectProvines.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatefulWidget {
  final LocalizationService localizations;
  final RangeValues priceRange;
  final ProvinesModels? selectedProvince;
  final String? selectedPropertyType;
  final int? selectedRoomsCount;
  final String? selectedRentType;
  final bool filtersApplied;
  final List<ProvinesModels> backendProvinces;
  final bool loadingProvinces;
  final String userStatus;
  final String? searchQuery;
  final Function(RangeValues, ProvinesModels?, String?, int?, String?)
  onApplyFilters;
  final String Function(String) getPropertyTypeName;
  final String Function(String) getRentTypeName;

  const FilterBottomSheet({
    Key? key,
    required this.localizations,
    required this.priceRange,
    this.selectedProvince,
    this.selectedPropertyType,
    this.selectedRoomsCount,
    this.selectedRentType,
    required this.filtersApplied,
    required this.backendProvinces,
    required this.loadingProvinces,
    required this.userStatus,
    this.searchQuery,
    required this.onApplyFilters,
    required this.getPropertyTypeName,
    required this.getRentTypeName,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _tempPriceRange;
  late ProvinesModels? _tempProvince;
  late String? _tempPropertyType;
  late int? _tempRoomsCount;
  late String? _tempRentType;

  @override
  void initState() {
    super.initState();
    _tempPriceRange = widget.priceRange;
    _tempProvince = widget.selectedProvince;
    _tempPropertyType = widget.selectedPropertyType;
    _tempRoomsCount = widget.selectedRoomsCount;
    _tempRentType = widget.selectedRentType;
  }

  String _getTempFiltersText() {
    List<String> filters = [];

    if (_tempProvince != null) {
      filters.add(
        '${widget.localizations.translate('province')}: ${_tempProvince!.name}',
      );
    }

    if (_tempPropertyType != null) {
      filters.add(
        '${widget.localizations.translate('propertyType')}: ${widget.getPropertyTypeName(_tempPropertyType!)}',
      );
    }

    if (_tempRoomsCount != null) {
      filters.add(
        '${widget.localizations.translate('room')}: ${_tempRoomsCount == 5 ? "5 ${widget.localizations.translate('room_or_more')}" : "$_tempRoomsCount"}',
      );
    }

    if (widget.userStatus == 'tenant' && _tempRentType != null) {
      filters.add(
        '${widget.localizations.translate('rentType')}: ${widget.getRentTypeName(_tempRentType!)}',
      );
    }

    if (widget.userStatus == 'tenant' &&
        (_tempPriceRange.start > 0 || _tempPriceRange.end < 1000000)) {
      filters.add(
        '${widget.localizations.translate('priceRange')}: ${_tempPriceRange.start.round()} - ${_tempPriceRange.end.round()} ل.س',
      );
    }

    return filters.isNotEmpty
        ? '${widget.localizations.translate('temporary_filters')}: ${filters.join(' | ')}'
        : widget.localizations.translate('noActiveFilters');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // قائمة أنواع العقارات
    List<String> propertyTypes = [
      'shop',
      'apartment',
      'warehouse',
      'house',
      'villa',
      'studio',
      'office',
    ];

    // قائمة أنواع الإيجار
    List<String> rentTypes = ['monthly', 'yearly'];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // رأس البوتوم شيت
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.localizations.translate('filter'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.primary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[300]),

                // مؤشر البحث الحالي
                if (widget.searchQuery != null &&
                    widget.searchQuery!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ' ${widget.localizations.translate('search')}:  "${widget.searchQuery}"',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // فلترة بالسعر (للمستأجر فقط)
                if (widget.userStatus == 'tenant') ...[
                  Text(
                    widget.localizations.translate('priceRange'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  RangeSlider(
                    values: _tempPriceRange,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      '${_tempPriceRange.start.round()} ${widget.localizations.translate('currency')}',
                      '${_tempPriceRange.end.round()} ${widget.localizations.translate('currency')}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _tempPriceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          '${_tempPriceRange.start.round()} ${widget.localizations.translate('currency')}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: colors.primary,
                      ),
                      Chip(
                        label: Text(
                          '${_tempPriceRange.end.round()} ${widget.localizations.translate('currency')}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: colors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],

                // فلترة بالمحافظة (لجميع المستخدمين)
                Text(
                  widget.localizations.translate('province'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                SizedBox(height: 10),

                // استخدام مكون Dropsellectprovines المخصص بدلاً من DropdownButton
                if (widget.loadingProvinces)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            widget.localizations.translate(
                              'loading_governorates',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (widget.backendProvinces.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        widget.localizations.translate('no_governorates'),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Dropsellectprovines(
                    labelText: widget.localizations.translate('selectProvince'),
                    selectedValue: _tempProvince,
                    items: widget.backendProvinces,
                    onSelected: (value) {
                      setState(() {
                        _tempProvince = value;
                      });
                    },
                  ),
                SizedBox(height: 20),

                // فلترة بنوع العقار (لجميع المستخدمين)
                Text(
                  widget.localizations.translate('propertyType'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _tempPropertyType,
                      isExpanded: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      hint: Text(
                        widget.localizations.translate('selectPropertyType'),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(widget.localizations.translate('all')),
                        ),
                        ...propertyTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(widget.getPropertyTypeName(type)),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _tempPropertyType = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // فلترة بعدد الغرف (لجميع المستخدمين)
                Text(
                  widget.localizations.translate('Number of Rooms'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _tempRoomsCount,
                      isExpanded: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      hint: Text(
                        widget.localizations.translate('selectRoomsCount'),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(widget.localizations.translate('all')),
                        ),
                        DropdownMenuItem<int?>(
                          value: 1,
                          child: Text(
                            '1 ${widget.localizations.translate('room')}',
                          ),
                        ),
                        DropdownMenuItem<int?>(
                          value: 2,
                          child: Text(
                            '2 ${widget.localizations.translate('room')}',
                          ),
                        ),
                        DropdownMenuItem<int?>(
                          value: 3,
                          child: Text(
                            '3 ${widget.localizations.translate('room')}',
                          ),
                        ),
                        DropdownMenuItem<int?>(
                          value: 4,
                          child: Text(
                            '4 ${widget.localizations.translate('room')}',
                          ),
                        ),
                        DropdownMenuItem<int?>(
                          value: 5,
                          child: Text(
                            '5 ${widget.localizations.translate('room_or_more')}',
                          ),
                        ),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          _tempRoomsCount = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // فلترة بنوع الإيجار (للمستأجر فقط)
                if (widget.userStatus == 'tenant') ...[
                  Text(
                    widget.localizations.translate('rentType'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _tempRentType,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        hint: Text(
                          widget.localizations.translate('selectRentType'),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(widget.localizations.translate('all')),
                          ),
                          ...rentTypes.map((type) {
                            return DropdownMenuItem<String?>(
                              value: type,
                              child: Text(widget.getRentTypeName(type)),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _tempRentType = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // مؤشر الفلترة المطبقة
                if ((_tempPriceRange != null &&
                        (_tempPriceRange.start > 0 ||
                            _tempPriceRange.end < 1000000)) ||
                    _tempProvince != null ||
                    _tempPropertyType != null ||
                    _tempRoomsCount != null ||
                    _tempRentType != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, color: colors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTempFiltersText(),
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),

                // أزرار التطبيق والإلغاء
                Row(
                  children: [
                    // زر إعادة التعيين
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _tempPriceRange = const RangeValues(0, 1000000);
                            _tempProvince = null;
                            _tempPropertyType = null;
                            _tempRoomsCount = null;
                            _tempRentType = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: colors.primary),
                        ),
                        child: Text(
                          widget.localizations.translate('reset'),
                          style: TextStyle(color: colors.primary),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // زر تطبيق الفلترة
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilters(
                            _tempPriceRange,
                            _tempProvince,
                            _tempPropertyType,
                            _tempRoomsCount,
                            _tempRentType,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          widget.localizations.translate('applyFilters'),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
