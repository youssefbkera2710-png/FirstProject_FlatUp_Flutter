import 'package:flutter/services.dart';

class Textnumber extends TextInputFormatter {
  final int maxDigits ;
  final bool enableFormat;

  Textnumber({
     required this.maxDigits,
    this.enableFormat = true,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // إزالة أي شيء غير رقم
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // تحديد الحد الأعلى
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // إذا التنسيق غير مفعّل → رجّع الأرقام كما هي
    if (!enableFormat) {
      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    // تنسيق تلقائي
    String formatted = '';
    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)} ${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
