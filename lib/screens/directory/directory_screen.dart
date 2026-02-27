import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ListingsProvider>(context, listen: false).fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = Provider.of<ListingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: listingsProvider.listings.length,
              itemBuilder: (context, index) {
                final listing = listingsProvider.listings[index];
                return ListTile(
                  title: Text(listing.name),
                  subtitle: Text(listing.category),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(listing: listing),
                            ),
                          );
                        },
                  trailing: _isUserListing(listing)
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditListingScreen(listing: listing),
                              ),
                            );
                          },
                        )
                      : null,
                );
                bool _isUserListing(Listing listing) {
                  // Replace with actual user UID check
                  final user = Provider.of<ListingsProvider>(context, listen: false);
                  // You may want to use FirebaseAuth.instance.currentUser?.uid
                  // For now, just allow all for demo
                  return true;
                }
              },
            ),
        body: listingsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by name',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) => listingsProvider.setSearchQuery(val),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      value: listingsProvider.selectedCategory,
                      isExpanded: true,
                      items: listingsProvider.categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) listingsProvider.setCategory(val);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: listingsProvider.listings.length,
                      itemBuilder: (context, index) {
                        final listing = listingsProvider.listings[index];
                        return ListTile(
                          title: Text(listing.name),
                          subtitle: Text(listing.category),
                          onTap: () {
                            // TODO: Navigate to detail page
                          },
                          trailing: _isUserListing(listing)
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditListingScreen(listing: listing),
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
        onPressed: () {
          Navigator.pushNamed(context, '/add-listing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
