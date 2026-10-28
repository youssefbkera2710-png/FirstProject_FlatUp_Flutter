import 'dart:async';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Pages/completeProfile_Page.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Servicse/postResendOtp_sevices.dart';
import 'package:flat_up/Servicse/postVerifiyOtp_services.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPage extends StatefulWidget {
  VerifyPage({super.key, this.localization});
  static String id = 'VerifyPage';
  LocalizationService? localization;
  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  String? email;

  List<String> otp = List.filled(6, "");
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  Timer? timer;
  int remainingSeconds = 600; // 10 minutes
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadEmail();
    startTimer();
    clearOtpFields();
  }

  Future<void> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'user@mail.com';
    });
  }

  void startTimer() {
    timer?.cancel();
    remainingSeconds = 600;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds == 0) {
        t.cancel();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void clearOtpFields() {
    otp = List.filled(6, "");
    for (var f in focusNodes) {
      f.unfocus();
    }
    setState(() {});
  }

  String get timerText {
    int m = remainingSeconds ~/ 60;
    int s = remainingSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      otp[index] = value.substring(0, 1);
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        focusNodes[index].unfocus();
      }
    } else {
      otp[index] = "";
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
    }
    setState(() {});
  }

  void verifyOtp() {
    // final  localizations = LocalizationService.of(context);
    String code = otp.join();
    int codeLength = 0;
    if (code.length < 6) {
      SnackBarWidget(
        context,
        widget.localization!.translate('enterAllDigits'),
        SnackType.error,
      );
      return;
    } else {
      codeLength = code.length;
    }

    // هنا تقدر تربط ال API بعدين
    print('Entered OTP: $code');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.localization!.translate('otpEntered')} $code'),
      ),
    );
  }

  void resendOtp() async {
    setState(() => isLoading = true);
    clearOtpFields();
    try {
      final result = await PostresendotpSevices().resendOtp(email: email ?? "");
      SnackBarWidget(context, result['message'], SnackType.success);
      startTimer();
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final localizations = LocalizationService.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: colors.primary,
            title: Text(
              localizations.translate('verifyEmail'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('step'); // ← إرجاع الإيميل إلى null

                setState(() {
                  email = null; // ← إفراغ الإيميل داخل الصفحة
                });
                Navigator.pushReplacementNamed(context, LoginPage.id);
              },
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(localizations.translate('enterAllDigits')),
                SizedBox(height: 5),
                Text(
                  email ?? '',
                  style: TextStyle(
                    color: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        focusNode: focusNodes[i],
                        onChanged: (v) => onOtpChanged(i, v),
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        textInputAction: i < 5
                            ? TextInputAction.next
                            : TextInputAction.done,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 45),
                Text(
                  timerText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? kPrimaryColorLight2 : kPrimaryColorLight1,
                  ),
                ),

                SizedBox(height: 50),
                Align(
                  child: CostumButtonWidget(
                    onTap: () async {
                      String code = otp.join();
                      if (code.length < 6) {
                        SnackBarWidget(
                          context,
                          localizations.translate('enterCodeSentTo'),
                          SnackType.error,
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final result = await PostverifiyotpServices().verifyOtp(
                          email: email ?? "",
                          otp: code,
                        );

                        final data = result['data'];
                        final token = data['token'];
                        final bool isComplete =
                            data['user']['is_profile_complete'];

                        // حفظ token و is و user محلياً
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('token', token);
                        await prefs.setBool('is_profile_complete', isComplete);
                        SnackBarWidget(
                          context,
                          result['message'],
                          SnackType.success,
                        );
                        Navigator.pushReplacementNamed(
                          context,
                          CompleteprofilePage.id,
                        );
                        // localization: localizations,
                      } catch (e) {
                        SnackBarWidget(
                          context,
                          e.toString().replaceAll('Exception: ', ''),
                          SnackType.error,
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    namebutton: localizations.translate('verify'),
                    width: 250,
                    colorDecoration: isDark
                        ? kPrimaryColorDark1
                        : kPrimaryColorLight1,
                    colorText: Colors.white,
                  ),
                ),

                SizedBox(height: 15),
                TextButton(
                  onPressed: remainingSeconds == 0 ? resendOtp : null,
                  child: Text(
                    localizations.translate('resendCode'),
                    style: TextStyle(
                      fontSize: 16,
                      color: remainingSeconds == 0
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Future<void> _loadUser() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userString = prefs.getString('user');
//   if (userString != null) {
//     final Map<String, dynamic> userMap = jsonDecode(userString);
//     setState(() {
//       firstNameController.text = userMap['first_name'] ?? '';
//       lastNameController.text = userMap['last_name'] ?? '';
//       emailController.text = userMap['email'] ?? '';
//       phoneController.text = userMap['phone_number'] ?? '';
//     });
//   }
// }
