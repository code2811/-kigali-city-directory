import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/firestore_service.dart';

class ReviewsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  int get reviewCount => _reviews.length;

  void fetchReviews(String listingId) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getReviews(listingId).listen((data) {
      _reviews = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addOrUpdateReview(String listingId, Review review) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addOrUpdateReview(listingId, review);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReview(String listingId, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteReview(listingId, userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
