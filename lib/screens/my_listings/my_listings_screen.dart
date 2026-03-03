import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../directory/edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ListingsProvider>(context, listen: false).fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = Provider.of<ListingsProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final myListings = listingsProvider.allListings.where((l) => l.createdBy == user?.uid).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myListings.isEmpty
              ? const Center(child: Text('No listings found.'))
              : ListView.builder(
                  itemCount: myListings.length,
                  itemBuilder: (context, index) {
                    final listing = myListings[index];
                    return ListTile(
                      title: Text(listing.name),
                      subtitle: Text(listing.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditListingScreen(listing: listing),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
