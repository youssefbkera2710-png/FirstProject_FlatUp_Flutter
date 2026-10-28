import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final bool isFeatured;

  const PropertyCard({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return Container(
      // تحديد حجم ثابت للبطاقة
      width: isFeatured ? 200 : double.infinity,
      height: isFeatured ? 180 : 160,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة العقار
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.home,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

            // تفاصيل العقار
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شقة جميلة للإيجار',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₺1,200/شهر',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
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