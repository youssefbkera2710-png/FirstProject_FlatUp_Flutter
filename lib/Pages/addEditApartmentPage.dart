import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/apiException.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Servicse/getAllProvines_services.dart';
import 'package:flat_up/Servicse/postAddProductServices.dart';
import 'package:flat_up/Servicse/post_update_apartment_services.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';
import 'package:flat_up/widget/dropSellectProvines.dart';
import 'package:flat_up/widget/sellector_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class AddEditApartmentPage extends StatefulWidget {
  final ApartmentModel? apartment;

  const AddEditApartmentPage({super.key, this.apartment});

  static const String id = 'AddEditApartmentPage';

  @override
  State<AddEditApartmentPage> createState() => _AddEditApartmentPageState();
}

class _AddEditApartmentPageState extends State<AddEditApartmentPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  bool isLoadingProvinces = false;
  bool isEditMode = false;
  bool isInitializingPage = true;

  List<ProvinesModels> provinces = [];
  ProvinesModels? selectedProvince;

  TextEditingController titleController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController roomsController = TextEditingController();
  TextEditingController bathroomsController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController balconiesController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? rentType;
  String? propertyType;
  bool hasRoof = false;
  bool hasElectricityMeter = false;
  bool hasWaterCounter = false;
  bool isFurnished = false;
  bool hasSolarEnergy = false;
  bool isDeluxe = false;

  List<String> propertyTypes = [
    "apartment",
    "house",
    "villa",
    "studio",
    "shop",
    "office",
    "warehouse",
  ];

  List<String> rentTypes = ["monthly", "yearly"];

  // ✅ متغيرات الصور المنفصلة
  XFile? selectedMainImage; // صورة رئيسية جديدة
  List<XFile> selectedAdditionalImages = []; // صور إضافية جديدة

  // ✅ صور قديمة (للتعديل فقط)
  String? oldMainImageUrl; // رابط الصورة الرئيسية القديمة
  List<String> oldAdditionalImageUrls = []; // روابط الصور الإضافية القدية

  // ✅ متغير لتتبع حالة الصورة الرئيسية (تم الحذف أم لا)
  bool isMainImageDeleted = false;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    isEditMode = widget.apartment != null;

    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() {
      isInitializingPage = true;
    });

    await _loadProvinces(); // تحميل المحافظات أولاً

    if (isEditMode) {
      _populateFormData(); // تعبئة الحقول
    }

    setState(() {
      isInitializingPage = false;
    });
  }

  Future<void> _loadProvinces() async {
    try {
      setState(() {
        isLoadingProvinces = true;
      });

      provinces = await GetallprovinesServices().getProvines();
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      if (mounted) {
        final localizations = LocalizationService.of(context);
        SnackBarWidget(
          context,
          localizations.translate('loading_provinces_error'),
          SnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProvinces = false;
        });
      }
    }
  }

  void _populateFormData() {
    if (widget.apartment == null) return;

    final apartment = widget.apartment!;

    setState(() {
      titleController.text = apartment.title ?? '';
      areaController.text = apartment.area.toString();
      cityController.text = apartment.city ?? '';
      priceController.text = apartment.price.toString();
      roomsController.text = apartment.roomsCount?.toString() ?? '';
      bathroomsController.text = apartment.bathroomsCount?.toString() ?? '';
      floorController.text = apartment.floor?.toString() ?? '';
      balconiesController.text = apartment.balconiesCount?.toString() ?? '';
      descriptionController.text = apartment.description ?? '';

      rentType = apartment.rentType;
      propertyType = apartment.propertyType;
      hasRoof = apartment.hasRoof ?? false;
      hasElectricityMeter = apartment.hasElectricityMeter ?? false;
      hasWaterCounter = apartment.hasWaterCounter ?? false;
      isFurnished = apartment.isFurnished ?? false;
      hasSolarEnergy = apartment.hasSolarEnergy ?? false;
      isDeluxe = apartment.isDeluxe ?? false;

      if (apartment.province.id != 0 && provinces.isNotEmpty) {
        try {
          selectedProvince = provinces.firstWhere(
            (province) => province.id == apartment.province.id,
          );
        } catch (e) {
          selectedProvince = provinces.isNotEmpty ? provinces.first : null;
        }
      }

      // ✅ فصل الصور القديمة
      oldMainImageUrl = apartment.mainImage; // الصورة الرئيسية القديمة
      oldAdditionalImageUrls.clear(); // مسح الصور الإضافية القديمة

      if (apartment.images != null) {
        for (var image in apartment.images!) {
          // إذا كانت الصورة ليست الرئيسية، نضيفها للصور الإضافية
          if (image.path != apartment.mainImage) {
            oldAdditionalImageUrls.add(image.path);
          }
        }
      }

      // ✅ تهيئة حالة الصورة الرئيسية
      isMainImageDeleted = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    areaController.dispose();
    cityController.dispose();
    priceController.dispose();
    roomsController.dispose();
    bathroomsController.dispose();
    floorController.dispose();
    balconiesController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ✅ اختيار صورة رئيسية واحدة فقط
  Future<void> pickMainImage() async {
    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (pickedImage != null) {
        setState(() {
          selectedMainImage = pickedImage;
          isMainImageDeleted = false; // ✅ إعادة تعيين حالة الحذف
        });
      }
    } catch (e) {
      debugPrint('Error picking main image: $e');
      if (mounted) {
        final localizations = LocalizationService.of(context);
        SnackBarWidget(
          context,
          localizations.translate('picking_image_error'),
          SnackType.error,
        );
      }
    }
  }

  // ✅ اختيار صور إضافية متعددة
  Future<void> pickAdditionalImages() async {
    try {
      final pickedImages = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          selectedAdditionalImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      debugPrint('Error picking additional images: $e');
      if (mounted) {
        final localizations = LocalizationService.of(context);
        SnackBarWidget(
          context,
          localizations.translate('picking_images_error'),
          SnackType.error,
        );
      }
    }
  }

  void removeMainImage() {
    final localization = LocalizationService.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('delete_main_image')),
        content: Text(localization.translate('confirm_delete_main_image')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (isEditMode && oldMainImageUrl != null) {
                  // ✅ في حالة التعديل: وضع علامة أن الصورة الرئيسية القديمة محذوفة
                  isMainImageDeleted = true;
                  selectedMainImage = null;
                } else {
                  // ✅ في حالة الإضافة: حذف الصورة المختارة فقط
                  selectedMainImage = null;
                }
              });
            },
            child: Text(
              localization.translate('delete'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void removeAdditionalImage(int index) {
    setState(() {
      if (index < 0 || index >= selectedAdditionalImages.length) return;
      selectedAdditionalImages.removeAt(index);
    });
  }

  void removeOldAdditionalImage(int index) {
    setState(() {
      if (index < 0 || index >= oldAdditionalImageUrls.length) return;
      oldAdditionalImageUrls.removeAt(index);
    });
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

  String _getRentTypeName(String type, LocalizationService localizations) {
    Map<String, String> rentTypeNames = {
      'monthly': localizations.translate('monthly'),
      'yearly': localizations.translate('yearly'),
    };

    return rentTypeNames[type] ?? type;
  }

  bool _validateForm() {
    final localizations = LocalizationService.of(context);

    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedProvince == null) {
      SnackBarWidget(
        context,
        localizations.translate('select_province_error'),
        SnackType.error,
      );
      return false;
    }

    if (rentType == null) {
      SnackBarWidget(
        context,
        localizations.translate('select_rent_type_error'),
        SnackType.error,
      );
      return false;
    }

    if (propertyType == null) {
      SnackBarWidget(
        context,
        localizations.translate('select_property_type_error'),
        SnackType.error,
      );
      return false;
    }

    // ✅ التحقق من الصور في حالة الإضافة
    if (!isEditMode) {
      if (selectedMainImage == null) {
        SnackBarWidget(
          context,
          localizations.translate('select_main_image_error'),
          SnackType.error,
        );
        return false;
      }
    } else {
      // ✅ في حالة التعديل: يجب أن يكون هناك صورة رئيسية (قديمة أو جديدة)
      // إلا إذا تم حذف الصورة القديمة عمداً
      if (selectedMainImage == null && oldMainImageUrl == null) {
        SnackBarWidget(
          context,
          localizations.translate('must_select_main_image'),
          SnackType.error,
        );
        return false;
      }

      // ✅ إذا تم حذف الصورة الرئيسية القديمة ولم يتم إضافة صورة جديدة
      if (isMainImageDeleted && selectedMainImage == null) {
        SnackBarWidget(
          context,
          localizations.translate('deleted_old_main_image'),
          SnackType.error,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _submitForm() async {
    final localizations = LocalizationService.of(context);

    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> response;

      if (!isEditMode) {
        // ✅ حالة الإضافة الجديدة
        if (selectedMainImage == null) {
          SnackBarWidget(
            context,
            localizations.translate('must_select_main_image'),
            SnackType.error,
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // تحويل الصور الإضافية إلى Files
        List<File> additionalImagesAsFiles = selectedAdditionalImages
            .map((xfile) => File(xfile.path))
            .toList();

        response = await PostAddProductServices().addProduct(
          title: titleController.text,
          description: descriptionController.text,
          area: double.parse(
            areaController.text.isNotEmpty ? areaController.text : '0',
          ),
          rent_type: rentType!,
          city: cityController.text,
          price: double.parse(
            priceController.text.isNotEmpty ? priceController.text : '0',
          ),
          rooms_count: int.parse(
            roomsController.text.isNotEmpty ? roomsController.text : '0',
          ),
          bathrooms_count: int.parse(
            bathroomsController.text.isNotEmpty
                ? bathroomsController.text
                : '0',
          ),
          province: selectedProvince!,
          property_type: propertyType!,
          balconies_count: int.parse(
            balconiesController.text.isNotEmpty
                ? balconiesController.text
                : '0',
          ),
          has_roof: hasRoof,
          floor: floorController.text,
          has_electricity_meter: hasElectricityMeter,
          has_water_counter: hasWaterCounter,
          is_furnished: isFurnished,
          has_solar_energy: hasSolarEnergy,
          is_deluxe: isDeluxe,
          mainImage: File(selectedMainImage!.path), // ✅ الصورة الرئيسية
          additionalImages: additionalImagesAsFiles, // ✅ الصور الإضافية
        );
      } else {
        // ✅ حالة التعديل
        final service = PostUpdateApartmentServices();

        // تحويل الصور الإضافية الجديدة إلى Files
        List<File> newAdditionalImagesAsFiles = selectedAdditionalImages
            .map((xfile) => File(xfile.path))
            .toList();

        // ✅ معالجة الصورة الرئيسية بشكل مختلف
        File? newMainImageFile;
        String? mainImageUrlToKeep;

        if (selectedMainImage != null) {
          // حالة: إرسال صورة رئيسية جديدة
          newMainImageFile = File(selectedMainImage!.path);
        } else if (oldMainImageUrl != null && !isMainImageDeleted) {
          // حالة: الاحتفاظ بالصورة الرئيسية القديمة
          mainImageUrlToKeep = oldMainImageUrl;
        } else {
          // حالة: تم حذف الصورة الرئيسية القديمة ولم يتم إضافة جديدة
        }

        response = await service.updateApartment(
          apartmentId: widget.apartment!.id,
          title: titleController.text,
          description: descriptionController.text,
          area: double.parse(
            areaController.text.isNotEmpty ? areaController.text : '0',
          ),
          rentType: rentType!,
          city: cityController.text,
          price: double.parse(
            priceController.text.isNotEmpty ? priceController.text : '0',
          ),
          roomsCount: int.parse(
            roomsController.text.isNotEmpty ? roomsController.text : '0',
          ),
          bathroomsCount: int.parse(
            bathroomsController.text.isNotEmpty
                ? bathroomsController.text
                : '0',
          ),
          province: selectedProvince!,
          propertyType: propertyType!,
          balconiesCount: int.parse(
            balconiesController.text.isNotEmpty
                ? balconiesController.text
                : '0',
          ),
          hasRoof: hasRoof,
          floor: floorController.text,
          hasElectricityMeter: hasElectricityMeter,
          hasWaterCounter: hasWaterCounter,
          isFurnished: isFurnished,
          hasSolarEnergy: hasSolarEnergy,
          isDeluxe: isDeluxe,
          oldMainImageUrl:
              mainImageUrlToKeep, // ✅ رابط الصورة الرئيسية القديمة (إذا لم تحذف)
          oldAdditionalImages:
              oldAdditionalImageUrls, // ✅ روابط الصور الإضافية القديمة
          newMainImage:
              newMainImageFile, // ✅ الصورة الرئيسية الجديدة (إذا أضيفت)
          newAdditionalImages:
              newAdditionalImagesAsFiles, // ✅ الصور الإضافية الجديدة
        );
      }

      SnackBarWidget(
        context,
        response['message'] ??
            (isEditMode
                ? localizations.translate('update_success')
                : localizations.translate('add_success')),
        SnackType.success,
      );

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      final message = e.message;
      SnackBarWidget(context, message, SnackType.warning);
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildMainImageSection(LocalizationService localizations) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('main_image'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),

        // ✅ عرض الصورة الرئيسية (قديمة أو جديدة) بنفس حجم الصور الإضافية (100x100)
        Container(
          width: 100, // نفس حجم الصور الإضافية
          height: 100,
          child: Stack(
            children: [
              // ✅ عرض الصورة الرئيسية
              if ((oldMainImageUrl != null && !isMainImageDeleted) ||
                  selectedMainImage != null)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: selectedMainImage != null
                        ? Image.file(
                            File(selectedMainImage!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            oldMainImageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      localizations.translate('main'),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                )
              else
                // ✅ زر اختيار صورة رئيسية
                GestureDetector(
                  onTap: pickMainImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.black54,
                        ),
                        SizedBox(height: 4),
                        Text(
                          localizations.translate('add_main_image'),
                          style: TextStyle(fontSize: 10, color: colors.primary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // ✅ علامة "الصورة الرئيسية" فقط إذا كانت هناك صورة
              if ((oldMainImageUrl != null && !isMainImageDeleted) ||
                  selectedMainImage != null)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      localizations.translate('main'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // ✅ زر حذف الصورة الرئيسية (يظهر فقط إذا كانت هناك صورة)
              if ((oldMainImageUrl != null && !isMainImageDeleted) ||
                  selectedMainImage != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: removeMainImage,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection(LocalizationService localizations) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 20),
        Text(
          localizations.translate('additional_images'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // ✅ زر إضافة صور إضافية
            GestureDetector(
              onTap: pickAdditionalImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 30,
                      color: Colors.black54,
                    ),
                    SizedBox(height: 4),
                    Text(
                      localizations.translate('add_image'),
                      style: TextStyle(fontSize: 12, color: colors.primary),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ عرض الصور الإضافية القديمة
            ...oldAdditionalImageUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${localizations.translate('old')} ${index + 1}",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        localizations.translate('old'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => removeOldAdditionalImage(index),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            }),

            // ✅ عرض الصور الإضافية الجديدة
            ...selectedAdditionalImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(image.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        localizations.translate('new'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => removeAdditionalImage(index),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildImagesSection(LocalizationService localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),

        // ✅ الصورة الرئيسية في الأعلى على اليسار
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة الرئيسية
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildMainImageSection(localizations)],
            ),

            SizedBox(width: 10),

            // الصور الإضافية بجانبها
            Expanded(child: _buildAdditionalImagesSection(localizations)),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields(LocalizationService localizations) {
    final translatedPropertyTypes = propertyTypes
        .map((type) => _getPropertyTypeName(type, localizations))
        .toList();
    final translatedRentTypes = rentTypes
        .map((type) => _getRentTypeName(type, localizations))
        .toList();

    return Column(
      children: [
        // ✅ قسم الصور في الأعلى
        _buildImagesSection(localizations),

        SizedBox(height: 25),

        CostumTextfiledWidget(
          hintText: localizations.translate('apartment_title'),
          controller: titleController,
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('area'),
          controller: areaController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),

        SizedBox(height: 20),

        Dropsellectprovines(
          labelText: localizations.translate('province'),
          selectedValue: selectedProvince,
          items: provinces,
          onSelected: (value) {
            setState(() {
              selectedProvince = value;
            });
          },
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('city'),
          controller: cityController,
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('price'),
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('rooms_count'),
          controller: roomsController,
          keyboardType: TextInputType.number,
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('bathrooms_count'),
          controller: bathroomsController,
          keyboardType: TextInputType.number,
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('floor'),
          controller: floorController,
          keyboardType: TextInputType.number,
        ),

        SizedBox(height: 20),

        CostumTextfiledWidget(
          hintText: localizations.translate('balconies_count'),
          controller: balconiesController,
          keyboardType: TextInputType.number,
        ),

        SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: SellectorWidget(
            labelText: '${localizations.translate('rent_type')}',
            selectedValue: rentType != null
                ? _getRentTypeName(rentType!, localizations)
                : null,
            items: translatedRentTypes,
            onSelected: (String? value) {
              if (value != null) {
                final index = translatedRentTypes.indexOf(value);
                setState(() {
                  rentType = rentTypes[index];
                });
              }
            },
          ),
        ),

        SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: SellectorWidget(
            labelText: "${localizations.translate('property_type')}",
            selectedValue: propertyType != null
                ? _getPropertyTypeName(propertyType!, localizations)
                : null,
            items: translatedPropertyTypes,
            onSelected: (value) {
              if (value != null) {
                final index = translatedPropertyTypes.indexOf(value);
                setState(() {
                  propertyType = propertyTypes[index];
                });
              }
            },
          ),
        ),

        SizedBox(height: 20),

        Text(
          localizations.translate('additional_features'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        Row(
          children: [
            Checkbox(
              value: hasRoof,
              onChanged: (value) {
                setState(() {
                  hasRoof = value ?? false;
                });
              },
            ),
            Text(localizations.translate('has_roof')),
          ],
        ),

        Row(
          children: [
            Checkbox(
              value: hasSolarEnergy,
              onChanged: (value) {
                setState(() {
                  hasSolarEnergy = value ?? false;
                });
              },
            ),
            Text(localizations.translate('has_solar_energy')),
          ],
        ),

        Row(
          children: [
            Checkbox(
              value: isFurnished,
              onChanged: (value) {
                setState(() {
                  isFurnished = value ?? false;
                });
              },
            ),
            Text(localizations.translate('furnished')),
          ],
        ),

        Row(
          children: [
            Checkbox(
              value: hasElectricityMeter,
              onChanged: (value) {
                setState(() {
                  hasElectricityMeter = value ?? false;
                });
              },
            ),
            Text(localizations.translate('has_electricity_meter')),
          ],
        ),

        Row(
          children: [
            Checkbox(
              value: hasWaterCounter,
              onChanged: (value) {
                setState(() {
                  hasWaterCounter = value ?? false;
                });
              },
            ),
            Text(localizations.translate('has_water_counter')),
          ],
        ),

        Row(
          children: [
            Checkbox(
              value: isDeluxe,
              onChanged: (value) {
                setState(() {
                  isDeluxe = value ?? false;
                });
              },
            ),
            Text(localizations.translate('deluxe')),
          ],
        ),

        SizedBox(height: 20),

        Text(
          "${localizations.translate('description')} ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: CostumTextfiledWidget(
            hintText: localizations.translate('description_hint'),
            controller: descriptionController,
            borderRadius: 12,
            minLinesCustom: 5,
          ),
        ),

        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context);
    final colors = Theme.of(context).colorScheme;
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    return ModalProgressHUD(
      inAsyncCall: isLoading || isInitializingPage || isLoadingProvinces,
      progressIndicator: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(kLogoApp, width: 120, height: 100),
          const SizedBox(height: 16),
          const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
      child: Scaffold(
        backgroundColor: colors.onPrimary,
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: Text(
            isEditMode
                ? localizations.translate('edit_apartment')
                : localizations.translate('add_new_apartment'),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormFields(localizations),

                Align(
                  child: CostumButtonWidget(
                    onTap: _submitForm,
                    namebutton: isEditMode
                        ? localizations.translate('update_apartment')
                        : localizations.translate('add_apartment'),
                    width: 250,
                    colorDecoration: isDark
                        ? kPrimaryColorDark1
                        : kPrimaryColorLight1,
                    colorText: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
