import 'dart:async';

import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/textNumber.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Servicse/postResendOtp_sevices.dart';
import 'package:flat_up/Servicse/postResetPassword_services.dart';

import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';

class Resetpasswordpage extends StatefulWidget {
  String? emaill;
  Resetpasswordpage({super.key, this.emaill});
  static String id = 'Resetpasswordpage';

  @override
  State<Resetpasswordpage> createState() => _ResetpasswordpageState();
}

class _ResetpasswordpageState extends State<Resetpasswordpage> {
  Timer? timer;
  int remainingSeconds = 100; //
  String? code;
  String? newPassword;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    remainingSeconds = 10;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds == 0) {
        t.cancel();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  String get timerText {
    int m = remainingSeconds ~/ 60;
    int s = remainingSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void resendOtp() async {
    setState(() => isLoading = true);
    try {
      final result = await PostresendotpSevices().resendOtp(
        email: widget.emaill!,
      );
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

  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;
    final localizations = LocalizationService.of(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: colors.onPrimary,
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: Text(
            localizations.translate('password_reset'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                Text(
                  localizations.translate('enter_code_verify'),
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                /// code
                CostumTextfiledWidget(
                  hintText: '### ###',
                  keyboardType: TextInputType.streetAddress,

                  inputFormatters: [Textnumber(maxDigits: 6)],
                  prefixIcon: Icons.code,
                  onChanged: (value) {
                    code = value.replaceAll(' ', '');
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  localizations.translate('enter_new_password'),
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                CostumTextfiledWidget(
                  hintText: localizations.translate('new_password'),
                  prefixIcon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,

                  obscureText: hidePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  onChanged: (value) => newPassword = value,
                ),

                const SizedBox(height: 30),
                Align(
                  child: CostumButtonWidget(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);

                        try {
                          final result = await PostresetpasswordServices()
                              .resetPassword(
                                email: widget.emaill!,
                                code: code!,
                                newPassword: newPassword!,
                              );
                          final message = result['message']?.toString() ?? '';
                          if (message.isNotEmpty) {
                            SnackBarWidget(context, message, SnackType.success);
                          }
                          Navigator.pushReplacementNamed(
                            context,
                            LoginPage.id,
                          ); //////////////////////////////////////////////////
                        } catch (e) {
                          SnackBarWidget(
                            context,
                            e.toString().replaceAll('Exception: ', ''),
                            SnackType.error,
                          );
                        }
                        setState(() => isLoading = false);
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
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? kPrimaryColorLight2
                            : kPrimaryColorLight1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: remainingSeconds == 0 ? resendOtp : null,
                  child: Text(
                    localizations.translate('resend_code'),
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

//  final emaillogin = Provider.of<EmailProvider>(context).email;
//  final password = Provider.of<PasswordProvider>(context).password;
