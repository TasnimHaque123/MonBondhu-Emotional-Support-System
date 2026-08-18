import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  List<Doctor> get _filteredDoctors {
    List<Doctor> results = DoctorDirectory.doctors;

    // Apply specialty filter
    if (_selectedFilter != 'All') {
      results = DoctorDirectory.filterBySpecialty(_selectedFilter);
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((d) =>
        d.name.toLowerCase().contains(q) ||
        d.nameBn.contains(q) ||
        d.location.toLowerCase().contains(q) ||
        d.locationBn.contains(q)
      ).toList();
    }

    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, size: 28),
            SizedBox(width: 8),
            Text('Find a Doctor'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location / নাম বা স্থান খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Psychiatrist'),
                const SizedBox(width: 8),
                _buildFilterChip('Psychologist'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: doctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found.\nকোনো ডাক্তার পাওয়া যায়নি।',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? label : 'All');
      },
      selectedColor: Colors.teal.shade100,
      checkmarkColor: Colors.teal,
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Fallback to clipboard if dialer cannot be opened
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer. $phoneNumber copied to clipboard.')),
        );
      }
    }
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.person, color: Colors.teal.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        doctor.nameBn,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Specialty
            Row(
              children: [
                Icon(Icons.medical_services, size: 18, color: Colors.blue.shade400),
                const SizedBox(width: 8),
                Text('${doctor.specialty} / ${doctor.specialtyBn}'),
              ],
            ),
            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Expanded(child: Text(doctor.locationBn)),
              ],
            ),
            const SizedBox(height: 6),

            // Availability
            if (doctor.availability != null)
              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: Colors.green.shade400),
                  const SizedBox(width: 8),
                  Text(doctor.availability!),
                ],
              ),

            const SizedBox(height: 12),

            // Contact button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(doctor.phone),
                icon: const Icon(Icons.phone),
                label: Text('Call: ${doctor.phone}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
