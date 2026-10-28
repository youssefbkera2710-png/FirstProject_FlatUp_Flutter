
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// // سيليكتور لاختيار عناصر قادمة من الباك اند 


class SellectorWidget extends StatelessWidget {
  const SellectorWidget({
    super.key,
    required this.labelText,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  final String? labelText;
  final String? selectedValue;
  final List<String> items; // ← ← الليست صارت ديناميكية
  final Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    LocalizationService localization = LocalizationService.of(context);

    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            icon: Icon(Icons.keyboard_arrow_down, color: kSecondaryColorLight),

            labelText: labelText,
            labelStyle: TextStyle(
              color: isDark
                  ? const Color.fromARGB(255, 131, 136, 144)
              // : kPrimaryColorLight2, // <-- اللون اللي بدك إياه
                  : kPrimaryColorLight1,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
              ),
            ),
          ),

          value: selectedValue,

          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),

          onChanged: (value) {
            onSelected(value);
          },

          autovalidateMode: AutovalidateMode.onUserInteraction,

          validator: (data) {
            if (data == null || data.isEmpty) {
              return localization.translate('field_required');
            }
            return null;
          },
        ),
      ],
    );
  }
}

// List<String> backendProvinces = response.data["provinces"];
// String? selectedProvince;

//     List<String> backendProvinces = [
//   "الخيار الأول",
//   "الخيار الثاني",
//   "الخيار الثالث",
// ];


//    SizedBox(
//                       width: 180,

//                     child : SellectorWidget(
//   labelText: "Your governorate",
//   selectedValue: selectedProvince,
//   items: backendProvinces,  // ← هون عم تمرّر الليست الديناميكية
//   onSelected: (value) {
//     setState(() {
//       selectedProvince = value;
//     });
//   },
// ),),