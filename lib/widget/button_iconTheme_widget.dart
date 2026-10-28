import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonIconthemeWidget extends StatelessWidget {
  const ButtonIconthemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = LocalizationService.of(context);
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        tooltip: localizationService.translate('theme'),
        iconSize: 30,
        onPressed: () => themeController.toggleTheme(),
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.grey : Colors.white,
        ),
      ),
    );
  }
}
