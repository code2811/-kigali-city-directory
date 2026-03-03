import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/listing.dart';
import '../../models/review.dart';
import '../../providers/reviews_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    throw Exception('Could not launch map navigation');
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsProvider()..fetchReviews(listing.id),
      child: Scaffold(
        appBar: AppBar(title: Text(listing.name)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(listing.latitude, listing.longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('location'),
                      position: LatLng(listing.latitude, listing.longitude),
                      infoWindow: InfoWindow(title: listing.name),
                    ),
                  },
                  zoomControlsEnabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${listing.category}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Address: ${listing.address}'),
                    const SizedBox(height: 8),
                    Text('Contact: ${listing.contactNumber}'),
                    const SizedBox(height: 8),
                    Text('Description: ${listing.description}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      onPressed: () => _launchMaps(listing.latitude, listing.longitude),
                    ),
                    const SizedBox(height: 24),
                    Consumer<ReviewsProvider>(
                      builder: (context, reviewsProvider, _) {
                        if (reviewsProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  reviewsProvider.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text('(${reviewsProvider.reviewCount} reviews)'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _ReviewList(listingId: listing.id),
                            const SizedBox(height: 8),
                            _AddOrEditReviewButton(listing: listing),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final String listingId;
  const _ReviewList({required this.listingId});

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewsProvider>().reviews;
    if (reviews.isEmpty) {
      return const Text('No reviews yet. Be the first to review!');
    }
    return Column(
      children: reviews.map((review) => ListTile(
        leading: Icon(Icons.person),
        title: Row(
          children: [
            ...List.generate(review.rating, (i) => Icon(Icons.star, color: Colors.amber, size: 16)),
            ...List.generate(5 - review.rating, (i) => Icon(Icons.star_border, size: 16)),
            const SizedBox(width: 8),
            Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Text(review.comment),
        trailing: Text(
          '${review.timestamp.day}/${review.timestamp.month}/${review.timestamp.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      )).toList(),
    );
  }
}

class _AddOrEditReviewButton extends StatelessWidget {
  final Listing listing;
  const _AddOrEditReviewButton({required this.listing});

  Review? _findExistingReview(List<Review> reviews, String? userId) {
    if (userId == null) return null;
    for (final review in reviews) {
      if (review.userId == userId) {
        return review;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final reviewsProvider = context.watch<ReviewsProvider>();
    final existingReview = _findExistingReview(reviewsProvider.reviews, user?.uid);
    return ElevatedButton.icon(
      icon: Icon(existingReview == null ? Icons.rate_review : Icons.edit),
      label: Text(existingReview == null ? 'Add Review' : 'Edit Your Review'),
      onPressed: user == null
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) => _ReviewDialog(
                  listingId: listing.id,
                  userId: user.uid,
                  userName: user.displayName ?? 'Anonymous',
                  existingReview: existingReview,
                ),
              );
            },
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final String listingId;
  final String userId;
  final String userName;
  final Review? existingReview;
  const _ReviewDialog({required this.listingId, required this.userId, required this.userName, this.existingReview});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _controller.text = widget.existingReview!.comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingReview == null ? 'Add Review' : 'Edit Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _rating = i + 1),
            )),
          ),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Comment'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        if (widget.existingReview != null)
          TextButton(
            onPressed: () async {
              await context.read<ReviewsProvider>().deleteReview(widget.listingId, widget.userId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final review = Review(
              id: widget.userId,
              userId: widget.userId,
              userName: widget.userName,
              rating: _rating,
              comment: _controller.text.trim(),
              timestamp: DateTime.now(),
            );
            await context.read<ReviewsProvider>().addOrUpdateReview(widget.listingId, review);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
