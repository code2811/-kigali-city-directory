import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

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
}
