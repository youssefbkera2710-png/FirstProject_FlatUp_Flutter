import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Servicse/deleteReview_services.dart';
import 'package:flat_up/Servicse/postAddReview_services.dart';
import 'package:flat_up/Servicse/postUpdateReview_services.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textfiled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Servicse/postAllReviewApartment_services.dart';
import 'package:flat_up/components/reviewCard.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flat_up/widget/starRating_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  final int apartmentId;
  const ReviewPage({super.key, required this.apartmentId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isEditing = false;
  int? editingIndex;
  double selectedRating = 0.0;
  int? userId;
  bool isLoading = true;
  bool isLoadingMore = false;
  List reviews = [];
  int currentPage = 1;
  int lastPage = 1;

  @override
  void initState() {
    super.initState();
    loadUserId();
    fetchReviews();

    _scrollController.addListener(() {
      if (isLoadingMore) return;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          currentPage < lastPage) {
        currentPage++;
        fetchReviews(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('id');
    });
  }

  void updateReview() async {
    final localizations = LocalizationService.of(context);

    if (selectedRating < 1) {
      SnackBarWidget(
        context,
        localizations.translate('select_valid_rating'),
        SnackType.error,
      );
      return;
    }

    final reviewId = reviews[editingIndex!]['id'];

    try {
      final response = await PostupdatereviewServices().updateReview(
        reviewId: reviewId,
        rateValue: selectedRating,
        comment: commentController.text,
      );

      setState(() {
        reviews[editingIndex!] = response['data'];
        isEditing = false;
        editingIndex = null;
        selectedRating = 1;
        commentController.clear();
      });

      SnackBarWidget(
        context,
        localizations.translate('review_updated_successfully'),
        SnackType.success,
      );
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
  }

  void startEditReview(int index) {
    setState(() {
      isEditing = true;
      editingIndex = index;
      selectedRating = (reviews[index]['rating'] ?? 1).toDouble();
      commentController.text = reviews[index]['comment'] ?? '';
    });

    // ينزل على الفورم
    Future.delayed(const Duration(milliseconds: 300), () {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void confirmDeleteReview(int index) {
    final localizations = LocalizationService.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_delete')),
          content: Text(localizations.translate('confirm_delete_review')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // cancel
              },
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                deleteReview(index); // call api
              },
              child: Text(
                localizations.translate('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// GET REVIEWS
  void fetchReviews({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => isLoadingMore = true);
    } else {
      setState(() => isLoading = true);
      currentPage = 1;
    }

    try {
      final response = await PostAllReviewApartmentServices().getReviews(
        apartmentId: widget.apartmentId,
        page: currentPage,
      );

      final data = response['data'];

      setState(() {
        lastPage = data['pagination']['last_page'];

        if (loadMore) {
          reviews.addAll(data['reviews']);
        } else {
          reviews = data['reviews'];
        }
      });
    } catch (e) {
      if (e.toString() ==
          "ClientException with SocketException: Failed host lookup: 'flatup.next99.net' (OS Error: No address associated with hostname, errno = 7), uri=$kBaseUrl/all-reviews")
        SnackBarWidget(
          context,
          "Connect to the internet and try again",
          SnackType.error,
        );
      else
        SnackBarWidget(
          context,
          e.toString().replaceAll('Exception: ', ''),
          SnackType.error,
        );
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void submitReview() async {
    final localizations = LocalizationService.of(context);

    if (selectedRating == 0) {
      SnackBarWidget(
        context,
        localizations.translate('select_rating_first'),
        SnackType.error,
      );
      return;
    }

    try {
      final response = await PostaddreviewServices().createReview(
        apartmentId: widget.apartmentId,
        rateValue: selectedRating,
        comment: commentController.text,
      );
      final newReview = response['data'];
      setState(() {
        reviews.insert(0, newReview);
        selectedRating = 0;
        commentController.clear();
      });

      SnackBarWidget(
        context,
        localizations.translate('review_added_successfully'),
        SnackType.success,
      );
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
  }

  void deleteReview(int index) async {
    final int reviewId = reviews[index]['id'];
    final localizations = LocalizationService.of(context);

    try {
      await DeletereviewServices().deleteReview(reviewId: reviewId);

      setState(() => reviews.removeAt(index));

      SnackBarWidget(
        context,
        localizations.translate('review_deleted'),
        SnackType.success,
      );
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
  }

  void editReview(int index) async {
    final int reviewId = reviews[index]['id'];
    final localizations = LocalizationService.of(context);
    try {
      final response = await PostupdatereviewServices().updateReview(
        reviewId: reviewId,
        rateValue: selectedRating,
        comment: commentController.text,
      );
      setState(() {
        reviews[index] = response['data'];
        selectedRating = 0.0;
        commentController.clear();
      });

      SnackBarWidget(
        context,
        localizations.translate('review_updated'),
        SnackType.success,
      );
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
  }

  Widget _emptyState() {
    final localizations = LocalizationService.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border_outlined,
            size: 150,
            color: kPrimaryColorLight1,
          ),
          Text(
            localizations.translate('no_reviews_yet'),
            style: TextStyle(fontSize: 26, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final localizations = LocalizationService.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          localizations.translate('reviews'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < reviews.length) {
                        return ReviewCard(
                          review: reviews[index],
                          userId: userId ?? 0,
                          onDelete: () => confirmDeleteReview(index),
                          onEdit: () => startEditReview(index),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1F1F1F) : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing
                      ? localizations.translate('edit_previous_review')
                      : localizations.translate('rate_previous_tenant'),
                ),
                const SizedBox(height: 6),
                StarratingWidget(rating: selectedRating, size: 34),
                Slider(
                  value: selectedRating < 1 ? 1 : selectedRating,
                  min: 1,
                  max: 5,
                  divisions: 40,
                  label: selectedRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => selectedRating = value);
                  },
                ),
                CostumTextfiledWidget(
                  controller: commentController,
                  enableValidation: false,
                  hintText: localizations.translate('write_your_comment'),
                  borderRadius: 12,
                ),

                const SizedBox(height: 10),
                Align(
                  child: CostumButtonWidget(
                    width: 250,
                    onTap: () {
                      if (isEditing) {
                        updateReview();
                      } else {
                        submitReview();
                      }
                    },
                    namebutton: isEditing
                        ? localizations.translate('edit_review')
                        : localizations.translate('submit_review'),
                    colorDecoration: isDark
                        ? kPrimaryColorDark1
                        : kPrimaryColorLight1,
                    colorText: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
