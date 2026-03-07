import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Listing> _listings = [];
  List<Listing> get listings => _filteredListings;
  List<Listing> get allListings => _listings;
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<Listing> _filteredListings = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => ['All', ...{
    ..._listings.map((l) => l.category)
  }];

  void fetchListings() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _firestoreService.getListings().listen((data) {
      _listings = data;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredListings = _listings.where((listing) {
      final matchesCategory = _selectedCategory == 'All' || listing.category == _selectedCategory;
      final matchesSearch = listing.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> addListing(Listing listing) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addListing(listing);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateListing(id, data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteListing(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteListing(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
