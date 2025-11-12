import 'package:flutter/material.dart';

class DestinationSearchScreen extends StatefulWidget {
  final List<String> destinations;

  const DestinationSearchScreen({super.key, required this.destinations});

  @override
  State<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  late List<String> _filteredDestinations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDestinations = widget.destinations;
    _searchController.addListener(_filterDestinations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDestinations = widget.destinations.where((dest) {
        return dest.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for a destination...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredDestinations.length,
        itemBuilder: (context, index) {
          final destination = _filteredDestinations[index];
          return ListTile(
            title: Text(destination),
            onTap: () {
              Navigator.pop(context, destination);
            },
          );
        },
      ),
    );
  }
}
