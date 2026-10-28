import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/elementConstant.dart';
import 'package:provider/provider.dart';
import '../Helper/themes.dart';

class ProfileImageFormField extends FormField<File> {
  ProfileImageFormField({
    Key? key,
    File? initialValue,
    String? imageUrl,
    bool enabled = true,
    FormFieldSetter<File>? onSaved,
    FormFieldValidator<File>? validator,
    ValueChanged<File?>? onChanged,
  }) : super(
         key: key,
         initialValue: initialValue,
         onSaved: onSaved,
         validator: validator,
         builder: (state) {
           final themeController = state.context.read<Themes>();
           final isDark = themeController.isDark;

           ImageProvider? backgroundImage;

           // أولوية الصورة:
           // 1- صورة مختارة محلياً
           // 2- صورة من السيرفر
           if (state.value != null) {
             backgroundImage = FileImage(state.value!);
           } else if (imageUrl != null && imageUrl.isNotEmpty) {
             backgroundImage =CachedNetworkImageProvider(imageUrl);;
           }

           return Column(
             children: [
               GestureDetector(
                 onTap: enabled
                     ? () async {
                         final picked = await ImagePicker().pickImage(
                           source: ImageSource.gallery,
                         );

                         if (picked != null) {
                           final file = File(picked.path);

                           state.didChange(file);
                           state.validate();
                           if (onChanged != null) {
                              onChanged(file);
                            }
                         }
                       }
                     : null,
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     CircleAvatar(
                       radius: 60,
                       backgroundColor: isDark
                           ? Colors.grey[800]
                           : Colors.grey[300],
                       backgroundImage: backgroundImage,
                       child: backgroundImage == null
                           ? Icon(
                               Icons.person,
                               size: 60,
                               color: isDark ? Colors.white : Colors.black,
                             )
                           : null,
                     ),

                     // أيقونة القلم (تظهر فقط إذا enabled)
                     if (enabled)
                       Positioned(
                         bottom: 4,
                         right: 4,
                         child: Container(
                           decoration: BoxDecoration(
                             color: isDark
                                 ? kPrimaryColorDark1
                                 : kPrimaryColorLight1,
                             shape: BoxShape.circle,
                             boxShadow: const [
                               BoxShadow(color: Colors.black26, blurRadius: 4),
                             ],
                           ),
                           padding: const EdgeInsets.all(6),
                           child: Icon(
                             Icons.edit,
                             size: 18,
                             color: isDark ? Colors.white : Colors.black,
                           ),
                         ),
                       ),
                   ],
                 ),
               ),

               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: isDark
                           ? const Color(0xffD0667A)
                           : const Color(0xffC82436),
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
