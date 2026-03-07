import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

import '../models/review.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Listing>> getListings() {
    return _db.collection('listings').orderBy('timestamp', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Listing>> getUserListings(String uid) {
    return _db.collection('listings').where('createdBy', isEqualTo: uid).orderBy('timestamp', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addListing(Listing listing) async {
    await _db.collection('listings').add(listing.toMap());
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _db.collection('listings').doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _db.collection('listings').doc(id).delete();
  }

  Stream<List<Review>> getReviews(String listingId) {
    return _db
        .collection('listings')
        .doc(listingId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<void> addOrUpdateReview(String listingId, Review review) async {
    await _db
        .collection('listings')
        .doc(listingId)
        .collection('reviews')
        .doc(review.userId)
        .set(review.toMap());
  }

  Future<void> deleteReview(String listingId, String userId) async {
    await _db
        .collection('listings')
        .doc(listingId)
        .collection('reviews')
        .doc(userId)
        .delete();
  }
}
