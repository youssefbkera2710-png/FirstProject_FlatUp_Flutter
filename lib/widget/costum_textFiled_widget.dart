import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CostumTextfiledWidget extends StatefulWidget {
  const CostumTextfiledWidget({
    super.key,
    this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.nextFocus,
    this.currentFocus,
    this.borderRadius,
    this.minLinesCustom,
    this.controller,
    this.isNationalId = false,
    this.enableValidation = true,
    this.readOnly,
    this.enabledWrite,
  });
  final bool enableValidation;
  final String? hintText;
  final Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? nextFocus;
  final FocusNode? currentFocus;
  final double? borderRadius;
  final int? minLinesCustom;
  final TextEditingController? controller;
  final bool isNationalId;
  final bool? readOnly; // جديد
  final bool? enabledWrite;

  @override
  State<CostumTextfiledWidget> createState() => _CostumTextfiledWidgetState();
}

class _CostumTextfiledWidgetState extends State<CostumTextfiledWidget> {
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    LocalizationService localization = LocalizationService.of(context);
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return TextFormField(
      ///////////////////////////////
      focusNode: widget.currentFocus,
      textInputAction: widget.nextFocus == null
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        } else {
          widget.currentFocus?.unfocus();
        }
      },

      ///////////////////////////////
      controller: widget.controller,
      minLines: widget.obscureText ? 1 : widget.minLinesCustom ?? 1,
      maxLines: widget.obscureText ? 1 : null,

      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabledWrite ?? true, // ✅ يتحكم بالكتابة كلياً
      validator: widget.enableValidation
          ? (value) {
              if (value == null || value.isEmpty) {
                return localization.translate('field_required');
              }
              if (widget.keyboardType == TextInputType.phone &&
                  value.replaceAll(' ', '').length < 10) {
                return localization.translate('phone_min_digits');
              }
              if (widget.keyboardType == TextInputType.phone &&
                  !value.startsWith('09')) {
                return localization.translate('phone_invalid');
              }
              if (widget.keyboardType == TextInputType.streetAddress &&
                  value.replaceAll(' ', '').length < 6) {
                return 'must be at least 6 digits';
              }
              if (widget.isNationalId && value.length < 11) {
                return localization.translate('number_min_digits');
              }
              if (widget.keyboardType == TextInputType.visiblePassword &&
                  value.length < 8) {
                return localization.translate('password_min_chars');
              }
              // if (widget.keyboardType == TextInputType.emailAddress &&
              //     !value.endsWith('@')) {
              //   return localization.translate('email_gmail_only');
              // }
              if (widget.keyboardType == TextInputType.emailAddress &&
                  !emailRegex.hasMatch(value.trim())) {
                return localization.translate('email_gmail_only');
              }

              return null;
            }
          : null,
      readOnly: widget.readOnly ?? false, // إذا ما مررته، الحقل قابل للتعديل
      onChanged: widget.onChanged,
      cursorColor: Theme.of(context).colorScheme.secondary,
      decoration: InputDecoration(
        labelText: widget.hintText,
        labelStyle: TextStyle(
          color: isDark
              ? const Color.fromARGB(255, 131, 136, 144)
              // : kPrimaryColorLight2, // <-- اللون اللي بدك إياه
              : kPrimaryColorLight1,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: isDark ? kPrimaryColorDark1 : Colors.black),

        // ---------------------------
        //       PREFIX ICON
        // ---------------------------
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: isDark ? Colors.white : Colors.black,
              )
            : null,
        // ---------------------------
        //       SUFFIX ICON
        // ---------------------------
        suffixIcon: widget.suffixIcon != null
            ? IconTheme(
                data: IconThemeData(
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: widget.suffixIcon!,
              )
            : null,
        // ---------------------------
        //         BORDER
        // ---------------------------
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(
            color: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
          ),
        ),
      ),
    );
  }
}
