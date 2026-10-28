import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Pages/resetPasswordPage.dart';
import 'package:flat_up/Pages/verify_page.dart';

import 'package:flat_up/Servicse/postForgetPassword_services.dart';

import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';

class ForgetpasswordPage extends StatefulWidget {
  const ForgetpasswordPage({super.key});
  static String id = 'ForgetPassword';

  @override
  State<ForgetpasswordPage> createState() => _ForgetpasswordPageState();
}

class _ForgetpasswordPageState extends State<ForgetpasswordPage> {
  String? email;

  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
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
            localizations.translate('forgetTitle'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.only(top: 40),
              children: [
                Text(
                  localizations.translate('enterEmail'),
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white : kPrimaryColorLight1,
                  ),
                ),

                const SizedBox(height: 20),

                /// 📧 Email
                CostumTextfiledWidget(
                  hintText: localizations.translate('emailHint'),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                  onChanged: (value) => email = value,
                ),

                const SizedBox(height: 12),
                Align(
                  child: CostumButtonWidget(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);

                        try {
                          final result = await PostforgetpasswordServices()
                              .forgetPassword(email: email!);
                          final message = result['message']?.toString() ?? '';
                          if (message.isNotEmpty) {
                            SnackBarWidget(context, message, SnackType.success);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Resetpasswordpage(emaill: email),
                            ),
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
                    namebutton: localizations.translate('sendCodeButton'),
                    width: 250,
                    colorDecoration: isDark
                        ? kPrimaryColorDark1
                        : kPrimaryColorLight1,
                    colorText: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),
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
