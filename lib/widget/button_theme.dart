import 'package:flat_up/Helper/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// ل اسامة بال drawer 

class ButtonTheme extends StatelessWidget {
  const ButtonTheme({super.key});
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDark ? "Dark Mode" : "Light Mode"),
        backgroundColor: colors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "هذا ويدجت يتغير لونه حسب الثيم!",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            IconButton(
              iconSize: 40,
              onPressed: () => themeController.toggleTheme(),
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            ),
          ],
        ),
      ),
    );
  }
}
