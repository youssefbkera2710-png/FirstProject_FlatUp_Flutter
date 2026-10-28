import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RadiochooseWidget extends FormField<String> {
  RadiochooseWidget({
    super.key,
    required Function(String) onSelected,
    super.initialValue,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         validator: (value) {
           if (value == null || value.isEmpty) {
             return 'field_required';
           }
           return null;
         },

         builder: (state) {
           return _RadioChooseContent(
             selectedValue: state.value,
             onSelected: (value) {
               state.didChange(value);
               state.validate(); // ← يمسح الخطأ فورًا
               onSelected(value);
             },
             errorText: state.errorText,
           );
         },
       );
}

class _RadioChooseContent extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onSelected;
  final String? errorText;
  const _RadioChooseContent({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    this.errorText,
  });

  @override
  State<_RadioChooseContent> createState() => _RadioChooseContentState();
}

class _RadioChooseContentState extends State<_RadioChooseContent> {
  Widget buildOption({required String title, required String value}) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    bool isSelected = widget.selectedValue == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onSelected(value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (Colors.grey.shade400)
                : (isDark ? kPrimaryColorDark1 : kPrimaryColorLight2),
            border: Border.all(
              color: isSelected
                  ? (Colors.grey.shade400)
                  : widget.errorText != null
                  ? isDark
                        ? Color.fromARGB(255, 196, 84, 122)
                        : Color(0xffC82436) // في حال وجود خطأ
                  : isDark
                  ? Colors.white
                  : Colors.black,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (v) => widget.onSelected(value),
                activeColor: isDark ? Colors.white : Colors.black,
              ),
              SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDark ? Colors.white54 : kPrimaryColorLight1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LocalizationService localization = LocalizationService.of(context);

    return Column(
      children: [
        Row(
          children: [
            buildOption(
              title: localization.translate('tenant'),
              value: "tenant",
            ),
            buildOption(
              title: localization.translate('landlord'),
              value: "landlord",
            ),
          ],
        ),

        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              localization.translate(widget.errorText!),
              style: const TextStyle(
                color: Color.fromARGB(255, 196, 84, 122),
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
