import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/provines_models.dart';

class Dropsellectprovines extends StatelessWidget {
  const Dropsellectprovines({
    super.key,
    this.labelText,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    this.onSaved,
    this.enabled = true,
  });

  final String? labelText;
  final ProvinesModels? selectedValue;
  final List<ProvinesModels> items;
  final Function(ProvinesModels?) onSelected;
  final Function(ProvinesModels?)? onSaved;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    LocalizationService localization = LocalizationService.of(context);

    return DropdownButtonFormField<ProvinesModels>(
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
          .toList(),
      onChanged: enabled ? (value) => onSelected(value) : null,
      onSaved: enabled
          ? (value) {
              if (onSaved != null) {
                onSaved!(value);
              } else {
                onSelected(value);
              }
            }
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: enabled
          ? (data) {
              if (data == null)
                return localization.translate('select_province_error');
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDark
              ? const Color.fromARGB(255, 131, 136, 144)
              : kPrimaryColorLight1,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
