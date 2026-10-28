import 'package:flat_up/Helper/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/constants/elementConstant.dart';

class ApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;
  final HomeController controller;
  final Function() onTap;
  final LocalizationService localization;

  const ApartmentCard({
    Key? key,
    required this.apartment,
    required this.controller,
    required this.onTap,
    required this.localization

  }) : super(key: key);

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('https://flatup.next99.net/storage/http')) {
      return url.replaceFirst('https://flatup.next99.net/storage/', '');
    }

    if (url.startsWith('https://flatup.next99.net/storage/https')) {
      return url.replaceFirst('https://flatup.next99.net/storage/', '');
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/storage/')) {
      return 'https://flatup.next99.net$url';
    }

    if (!url.startsWith('http')) {
      return 'https://flatup.next99.net/storage/$url';
    }

    return url;
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTenantPriceDisplay(ApartmentModel apartment) {
    if (apartment.hasPrice) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_money, color: Colors.green, size: 14),
          SizedBox(width: 4),
          Text(
            "${apartment.formattedPrice}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_money, color: Colors.grey, size: 14),
          SizedBox(width: 4),
          Text(
            localization.translate("undefined"),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLandlordRatingDisplay(ApartmentModel apartment) {
    if (apartment.averageRating != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 14),
          SizedBox(width: 4),
          Text(
            apartment.averageRating!.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, color: Colors.amber, size: 14),
          SizedBox(width: 4),
          Text(
            localization.translate('new'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDefaultDisplay(ApartmentModel apartment) {
    return _buildLandlordRatingDisplay(apartment);
  }



  String _getPropertyTypeName(String type, LocalizationService localizations) {
    Map<String, String> propertyTypeNames = {
      'shop': localizations.translate('shop'),
      'apartment': localizations.translate('apartment'),
      'warehouse': localizations.translate('warehouse'),
      'house': localizations.translate('house'),
      'villa': localizations.translate('villa'),
      'studio': localizations.translate('studio'),
      'office': localizations.translate('office'),
    };

    return propertyTypeNames[type] ?? type;
  }
  

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;
    String mainImageUrl = _fixImageUrl(apartment.mainImage);

    return InkWell(
      onTap: onTap,
      child: Card(
        color: isDark ? kPrimaryColorDark1 : kPrimaryColorLight2,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(mainImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.userStatus.value == 'tenant')
                              _buildTenantPriceDisplay(apartment)
                            else if (controller.userStatus.value == 'landlord')
                              _buildLandlordRatingDisplay(apartment)
                            else
                              _buildDefaultDisplay(apartment)
                          ],
                        ),
                      ),
                    ),
                    if (apartment.isFurnished)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            localization.translate('furnished'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${apartment.city} - ${apartment.province.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getPropertyTypeName(apartment.propertyType,localization),
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(apartment.createdAt),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}