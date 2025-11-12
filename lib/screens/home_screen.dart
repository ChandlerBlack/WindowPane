import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_entry.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';


class HomeScreen extends StatefulWidget {
  final List<PhotoEntry> photos;
  final VoidCallback onPhotoUpdated;
  final bool isCelsius;
  final bool is24Hour;
  final int? initialIndex;

  const HomeScreen({
    super.key,
    required this.photos,
    required this.onPhotoUpdated,
    required this.isCelsius,
    required this.is24Hour,
    this.initialIndex,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _editDescription(PhotoEntry photo) {
    final controller = TextEditingController(text: photo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Description'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter description',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedPhoto = PhotoEntry(
                id: photo.id,
                imagePath: photo.imagePath,
                description: controller.text,
                timestamp: photo.timestamp,
                latitude: photo.latitude,
                longitude: photo.longitude,
                address: photo.address,
                temperature: photo.temperature,
                weatherCondition: photo.weatherCondition,
              );
              await DatabaseService.instance.updatePhoto(updatedPhoto);
              widget.onPhotoUpdated();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Center(
        child: Text(
          'No photos yet.\nTap the + button to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        final timeFormat = widget.is24Hour
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');
        final dateFormat = DateFormat('MMMM d, yyyy');
        final temp = _settingsService
            .convertTemperature(photo.temperature, widget.isCelsius)
            .round();
        final unit = _settingsService.getTemperatureUnit(widget.isCelsius);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Photo
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(photo.imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => _editDescription(photo),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      photo.description,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time and Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format(photo.timestamp)} ${dateFormat.format(photo.timestamp)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        photo.address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Weather
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny),
                    const SizedBox(width: 8),
                    Text(
                      '$temp$unit ${photo.weatherCondition}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}