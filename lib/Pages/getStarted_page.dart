import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/widget/animatedCircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetstartedPage extends StatefulWidget {
  const GetstartedPage({Key? key}) : super(key: key);
  static String id = 'GetstartedPage';

  @override
  State<GetstartedPage> createState() => _GetstartedPageState();
}

class _GetstartedPageState extends State<GetstartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    kPrimaryColorLight1, // pink coral
                    Colors.grey.shade800,
                    _controller.value,
                  )!,
                  Color.lerp(
                    Colors.grey.shade700,
                    kPrimaryColorLight1,
                    _controller.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                AnimatedcircleWidget(top: 100, left: -50, size: 200),
                AnimatedcircleWidget(bottom: -60, right: -40, size: 180),
                AnimatedcircleWidget(top: 250, right: -30, size: 120),
                _content(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _content() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(child: _logo()),
            const SizedBox(height: 20),
            Center(
              child: const Text(
                'Flat Up',
                style: TextStyle(
                  fontFamily: 'CarterOne',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'إدارة عقاراتك\nبذكاء وسهولة',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'تابع الشقق، المستأجرين، العقود والمدفوعات\nفي مكان واحد باحترافية',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColorLight1,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_seen_get_started', true);

                Navigator.pushReplacementNamed(context, LoginPage.id);
              },

              child: const Text(
                'ابدأ ..',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(196, 255, 255, 255),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _logo() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12), // أو circle
            image: DecorationImage(
              image: AssetImage(kIconApp),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // const Text(
        //   'Flat Up',
        //   style: TextStyle(
        //     fontSize: 22,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //     letterSpacing: 1.2,
        //   ),
        // ),
      ],
    ),
  );
}
