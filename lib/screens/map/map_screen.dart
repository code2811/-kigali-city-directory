import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/listings_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-1.9577, 30.1127),
                zoom: 12,
              ),
              markers: listingsProvider.allListings
                  .map(
                    (listing) => Marker(
                      markerId: MarkerId(listing.id),
                      position: LatLng(listing.latitude, listing.longitude),
                      infoWindow:
                          InfoWindow(title: listing.name, snippet: listing.category),
                    ),
                  )
                  .toSet(),
            ),
    );
  }
}
