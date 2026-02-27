import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingsProvider = Provider.of<ListingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-1.9577, 30.1127), // Kigali center
                zoom: 12,
              ),
              markers: listingsProvider.listings
                  .map((listing) => Marker(
                        markerId: MarkerId(listing.id),
                        position: LatLng(listing.latitude, listing.longitude),
                        infoWindow: InfoWindow(title: listing.name, snippet: listing.category),
                      ))
                  .toSet(),
              zoomControlsEnabled: true,
            ),
    );
  }
}
