import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = '';
  String _address = '';
  String _contactNumber = '';
  String _description = '';
  double? _latitude;
  double? _longitude;

  @override
  Widget build(BuildContext context) {
    final listingsProvider = Provider.of<ListingsProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Place or Service Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category (e.g., Hospital, Restaurant)'),
                onChanged: (val) => _category = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (val) => _address = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact Number'),
                onChanged: (val) => _contactNumber = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => _description = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _latitude = double.tryParse(val),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid latitude' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _longitude = double.tryParse(val),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid longitude' : null,
              ),
              const SizedBox(height: 20),
              if (listingsProvider.error != null)
                Text(listingsProvider.error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: listingsProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() && user != null) {
                          final listing = Listing(
                            id: '',
                            name: _name,
                            category: _category,
                            address: _address,
                            contactNumber: _contactNumber,
                            description: _description,
                            latitude: _latitude!,
                            longitude: _longitude!,
                            createdBy: user.uid,
                            timestamp: Timestamp.now(),
                          );
                          await listingsProvider.addListing(listing);
                          if (listingsProvider.error == null) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: listingsProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
