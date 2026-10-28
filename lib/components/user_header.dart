import 'package:flat_up/Pages/informationsProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserHeader extends StatefulWidget {
  final LocalizationService localizations;

  const UserHeader({super.key, required this.localizations});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  String? firstName;
  String? lastName;
  String? profileImageUrl;
  String? nameUser;
  String? role;

  @override
  void initState() {
    super.initState();
    loadRole();
    loadfullNameAndProfile();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'User';
    });
  }

  Future<void> loadfullNameAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'User';
      lastName = prefs.getString('last_name') ?? 'User';
      nameUser = "$firstName $lastName";
      profileImageUrl =
          prefs.getString('profile_image_url') ?? 'assets/images/IconApp.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizationService = LocalizationService.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => InformationsprofilePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              child: ClipOval(
                child: profileImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profileImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(strokeWidth: 2),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, size: 60),
                      )
                    : const Icon(Icons.person, size: 100),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${nameUser ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ' ${role == "tenant" ? localizationService.translate('tenant') : localizationService.translate('landlord')}',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
