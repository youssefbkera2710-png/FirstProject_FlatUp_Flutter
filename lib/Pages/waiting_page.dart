import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Servicse/getMyProfile_services.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({Key? key}) : super(key: key);

  static String id = 'WaitingPage';

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? role;
  bool isLoadingStatus = false; // للتحكم بدائرة سحب التحديث
  UserModels? _user;

  @override
  void initState() {
    super.initState();
    loadRole(); ///////////
    startAnimation();
    checkStatusAndProfie();
  }

  /// تحميل role من SharedPreferences
  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'User';
    });
  }

  Future<void> _saveApprovedProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null)
      return;
    else {
      await prefs.setInt('id', _user!.id!);
      await prefs.setString('first_name', _user!.firstName ?? '');
      await prefs.setString('last_name', _user!.lastName ?? '');
      await prefs.setString('city', _user!.city ?? '');
      await prefs.setString('phone', _user!.phoneNumber ?? '');
      await prefs.setString('national_id', _user!.nationalId ?? '');
      await prefs.setString(
        'profile_image_url',
        // _user!.profileImageUrl ?? '',
        _user!.profileImageUrl ?? '',
      );
      await prefs.setString('profile_image', _user!.profileImage ?? '');
      if (_user?.birthDate != null) {
        await prefs.setString(
          'birth_date',
          DateFormat('yyyy-MM-dd').format(_user!.birthDate!),
        );
      }

      if (_user?.provinceId != null) {
        await prefs.setInt('province_id', _user!.provinceId!);
      }
      await prefs.setString('province_name', _user!.provinceName ?? '');
    }
  }

  /// تشغيل حركة النقاط
  void startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  /// إيقاف حركة النقاط
  void stopAnimation() {
    _controller.stop();
  }

  Future<void> checkStatusAndProfie() async {
    setState(() => isLoadingStatus = true);
    try {
      final user = await GetmyprofileServices().getProfile();
      _user = user; //
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status', _user?.status ?? 'pending_approval');
      if (_user?.status == "approved") {
        await _saveApprovedProfileLocally();
        profileStatus = ProfileStatus.approved;
        stopAnimation();
      } else if (_user?.status == "rejected") {
        profileStatus = ProfileStatus.rejected;
        stopAnimation();
      } else {
        profileStatus = ProfileStatus.pending;
        if (!_controller.isAnimating) startAnimation();
      }
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      setState(() => isLoadingStatus = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;
    final localizations = LocalizationService.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, LoginPage.id);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('email');
              await prefs.remove('token');
              await prefs.remove('is_profile_complete');
              await prefs.remove('step');
              await prefs.remove('status');
              await prefs.remove('role');
            },
          ),
          backgroundColor: colors.primary,
          title: Text(
            localizations.translate('hey'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,

        /// ⬇⬇ RefreshIndicator
        body: RefreshIndicator(
          onRefresh: checkStatusAndProfie,
          color: colors.primary,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${localizations.translate('roleLabel')} ${role == "tenant" ? localizations.translate('tenant') : localizations.translate('landlord')}',
                        style: TextStyle(
                          fontFamily: 'CarterOne',
                          fontSize: 32,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        profileStatus == ProfileStatus.approved
                            ? localizations.translate('approvedMessage')
                            : profileStatus == ProfileStatus.rejected
                            ? localizations.translate('requestRejected')
                            : localizations.translate('waitingMessage'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: profileStatus == ProfileStatus.rejected
                              ? Colors.red
                              : isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 40),

                      /// نقاط تدور
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (_, child) {
                            return CustomPaint(
                              painter: _DotsPainter(
                                _controller.value,
                                color: isDark
                                    ? kPrimaryColorDark1
                                    : kPrimaryColorLight1,
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 50),

                      /// زر (يُفعل فقط إذا on)
                      CostumButtonWidget(
                        namebutton: profileStatus == ProfileStatus.approved
                            ? localizations.translate('buttonApproved')
                            : profileStatus == ProfileStatus.rejected
                            ? localizations.translate('rejected')
                            : localizations.translate('loading'),
                        width: 200,
                        colorDecoration: profileStatus == ProfileStatus.approved
                            ? (Colors.lightGreen)
                            : profileStatus == ProfileStatus.rejected
                            ? Colors.red.shade700
                            : (isDark
                                  ? const Color.fromARGB(75, 150, 151, 149)
                                  : const Color.fromARGB(95, 215, 153, 173)),
                        colorText: const Color.fromARGB(182, 255, 255, 255),

                        onTap: profileStatus == ProfileStatus.approved
                            ? () async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.setString('status', 'approved');
                                await prefs.setString('step', 'done');

                                Navigator.pushReplacementNamed(
                                  context,
                                  HomevendorPage.id,
                                );
                              }
                            : profileStatus == ProfileStatus.rejected
                            ? () async {
                                Navigator.pushReplacementNamed(
                                  context,
                                  LoginPage.id,
                                );
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('email');
                                await prefs.remove('token');
                                await prefs.remove('is_profile_complete');
                                await prefs.remove('step');
                                await prefs.remove('status');
                                await prefs.remove('role');
                              }
                            : null,
                      ),
                      SizedBox(height: 20),
                      Text(
                        profileStatus == ProfileStatus.approved
                            ? localizations.translate('loginActive')
                            : profileStatus == ProfileStatus.rejected
                            ? localizations.translate('accountRejected')
                            : localizations.translate('loginSoon'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: profileStatus == ProfileStatus.rejected
                              ? Colors.redAccent
                              : isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////
/// رسّام النقاط المتحركة
///////////////////////////////////////////////////////////
class _DotsPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DotsPainter(this.progress, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    final dotRadius = 6.0;
    final totalDots = 8;

    for (int i = 0; i < totalDots; i++) {
      final angle = (2 * pi / totalDots) * i + progress * 2 * pi;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      final opacity =
          (sin(progress * 2 * pi + (i / totalDots) * 2 * pi) + 1) / 2;
      canvas.drawCircle(
        Offset(dx, dy),
        dotRadius,
        paint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum ProfileStatus { pending, approved, rejected }

ProfileStatus profileStatus = ProfileStatus.pending;
