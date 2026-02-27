import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;
  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _address;
  late String _contactNumber;
  late String _description;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _name = widget.listing.name;
    _category = widget.listing.category;
    _address = widget.listing.address;
    _contactNumber = widget.listing.contactNumber;
    _description = widget.listing.description;
    _latitude = widget.listing.latitude;
    _longitude = widget.listing.longitude;
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = Provider.of<ListingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Place or Service Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (val) => _category = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (val) => _address = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _contactNumber,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                onChanged: (val) => _contactNumber = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => _description = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _latitude.toString(),
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _latitude = double.tryParse(val) ?? _latitude,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid latitude' : null,
              ),
              TextFormField(
                initialValue: _longitude.toString(),
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _longitude = double.tryParse(val) ?? _longitude,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid longitude' : null,
              ),
              const SizedBox(height: 20),
              if (listingsProvider.error != null)
                Text(listingsProvider.error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: listingsProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await listingsProvider.updateListing(widget.listing.id, {
                            'name': _name,
                            'category': _category,
                            'address': _address,
                            'contactNumber': _contactNumber,
                            'description': _description,
                            'latitude': _latitude,
                            'longitude': _longitude,
                          });
                          if (listingsProvider.error == null) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: listingsProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Listing'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: listingsProvider.isLoading
                    ? null
                    : () async {
                        await listingsProvider.deleteListing(widget.listing.id);
                        if (listingsProvider.error == null) {
                          Navigator.pop(context);
                        }
                      },
                child: listingsProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Delete Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
