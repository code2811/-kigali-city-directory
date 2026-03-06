import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Mobile only
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

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsProvider()..fetchReviews(listing.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text(listing.name),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map placeholder — works on web and mobile (before emulator is ready)
              GestureDetector(
                onTap: () => _openInMaps(listing.latitude, listing.longitude),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[100]!, Colors.green[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines to simulate a map
                      CustomPaint(
                        size: const Size(double.infinity, 250),
                        painter: _MapGridPainter(),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.location_pin, size: 48, color: Colors.red),
                                  const SizedBox(height: 4),
                                  Text(
                                    listing.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${listing.latitude.toStringAsFixed(4)}, ${listing.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to open in Google Maps',
                                    style: TextStyle(fontSize: 12, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Chip(
                      label: Text(
                        listing.category,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green[700],
                    ),
                    const SizedBox(height: 12),

                    // Info cards
                    _InfoRow(icon: Icons.location_on, label: 'Address', value: listing.address),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.phone, label: 'Contact', value: listing.contactNumber),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.description, label: 'Description', value: listing.description),
                    const SizedBox(height: 16),

                    // Navigate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation),
                        label: const Text('Get Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _launchMaps(listing.latitude, listing.longitude),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Reviews section
                    const Text(
                      'Reviews',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

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
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  reviewsProvider.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
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

// Simple map grid painter for visual effect
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[300]!.withOpacity(0.4)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
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
      children: reviews
          .map((review) => ListTile(
                leading: const Icon(Icons.person),
                title: Row(
                  children: [
                    ...List.generate(
                      review.rating,
                      (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                    ...List.generate(
                      5 - review.rating,
                      (i) => const Icon(Icons.star_border, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(review.comment),
                trailing: Text(
                  '${review.timestamp.day}/${review.timestamp.month}/${review.timestamp.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ))
          .toList(),
    );
  }
}

class _AddOrEditReviewButton extends StatelessWidget {
  final Listing listing;
  const _AddOrEditReviewButton({required this.listing});

  Review? _findExistingReview(List<Review> reviews, String? userId) {
    if (userId == null) return null;
    for (final review in reviews) {
      if (review.userId == userId) return review;
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
  const _ReviewDialog({
    required this.listingId,
    required this.userId,
    required this.userName,
    this.existingReview,
  });

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
            children: List.generate(
              5,
              (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              ),
            ),
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
              await context
                  .read<ReviewsProvider>()
                  .deleteReview(widget.listingId, widget.userId);
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
            await context
                .read<ReviewsProvider>()
                .addOrUpdateReview(widget.listingId, review);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}