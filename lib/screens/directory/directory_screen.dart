import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/listings_provider.dart';
import 'edit_listing_screen.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: listingsProvider.setSearchQuery,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: listingsProvider.selectedCategory,
                    isExpanded: true,
                    items: listingsProvider.categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        listingsProvider.setCategory(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: listingsProvider.listings.isEmpty
                      ? const Center(child: Text('No listings found.'))
                      : ListView.builder(
                          itemCount: listingsProvider.listings.length,
                          itemBuilder: (context, index) {
                            final listing = listingsProvider.listings[index];
                            final isOwner = listing.createdBy == currentUserId;

                            return ListTile(
                              title: Text(listing.name),
                              subtitle: Text(listing.category),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ListingDetailScreen(listing: listing),
                                  ),
                                );
                              },
                              trailing: isOwner
                                  ? IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditListingScreen(listing: listing),
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-listing'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
