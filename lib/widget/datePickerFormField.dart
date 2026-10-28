import 'package:flat_up/constants/elementConstant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Helper/themes.dart';

class DatePickerFormField extends FormField<DateTime> {
  DatePickerFormField({
    Key? key,
    DateTime? initialValue,
    bool enabled = true,

    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    ValueChanged<DateTime>? onChanged,
    String ?label ,
  }) : super(
         key: key,
         initialValue: initialValue,
         onSaved: onSaved,
         validator: enabled ? validator : null,

         builder: (state) {
           final themeController = state.context.read<Themes>();
           final isDark = themeController.isDark;
           final TextEditingController _controller = TextEditingController(
             text: state.value != null
                 ? DateFormat('yyyy-MM-dd').format(state.value!)
                 : '',
           );
           Color borderColor() {
             if (!enabled) {
               return Colors.grey;
             }
             if (state.hasError) {
               return isDark
                   ? const Color(0xffD0667A)
                   : const Color(0xffC82436);
             }
             return isDark ? Colors.white : Colors.black;
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               TextFormField(
                 controller: _controller,
                 readOnly: true,
                 enabled: enabled,
                 onTap: !enabled
                     ? null
                     : () async {
                         DateTime? date = await showDatePicker(
                           context: state.context,
                           initialDate: state.value ?? DateTime(2000, 1, 1),
                           firstDate: DateTime(1900),
                           lastDate: DateTime.now(),
                         );
                         if (date != null) {
                           state.didChange(date);
                           _controller.text = DateFormat(
                             'yyyy-MM-dd',
                           ).format(date); // تحديث النص
                           state.validate();
                           if (onChanged != null) onChanged(date);
                         }
                       },
                 decoration: InputDecoration(
                   labelText: label,
                   labelStyle: TextStyle(
                     color: isDark
                         ? const Color.fromARGB(255, 131, 136, 144)
                         // : kPrimaryColorLight2, // <-- اللون اللي بدك إياه
                         : kPrimaryColorLight1,
                   ),
                   hintText: state.value != null
                       ? DateFormat('yyyy-MM-dd').format(state.value!)
                       : "Select Date",
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(24),
                     borderSide: BorderSide(color: borderColor()),
                   ),
                   enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(24),
                     borderSide: BorderSide(color: borderColor()),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(24),
                     borderSide: BorderSide(color: borderColor()),
                   ),
                 ),
               ),

               if (state.hasError && enabled)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(color: borderColor(), fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}
