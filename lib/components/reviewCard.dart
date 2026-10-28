import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:flat_up/widget/starRating_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final int userId;

  const ReviewCard({
    super.key,
    required this.userId,
    required this.review,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  @override
  void initState() {
    super.initState();
  }

  double ratingPercent(double rating) {
    return (rating);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context);
    final double rating = (widget.review["rating"] ?? 0).toDouble();

    final date = DateFormat(
      'yyyy/MM/dd',
    ).format(DateTime.parse(widget.review["created_at"]));
    final updatedDate = DateFormat(
      'yyyy/MM/dd',
    ).format(DateTime.parse(widget.review["updated_at"]));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// الاسم + التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.review["user"]["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${localization.translate('created')} ${date}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// النجوم + النسبة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    StarratingWidget(rating: rating, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "${ratingPercent(rating).toStringAsFixed(1)}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${localization.translate('edited')} ${updatedDate}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            if (widget.review["comment"] != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.review["comment"],
                style: const TextStyle(fontSize: 14),
              ),
            ],

            if (widget.userId != null &&
                widget.review["user"]["id"] == widget.userId)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: widget.onEdit,
                      child: Text(
                        localization.translate('edit'),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onDelete,
                      child: Text(
                        localization.translate('delete'),
                        style: TextStyle(color: Colors.red),
                      ),
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
