import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_entry.dart';

class GridScreen extends StatelessWidget {
  final List<PhotoEntry> photos;
  final Function(int) onPhotoTapped;
  final bool isCelsius;
  final bool is24Hour;

  const GridScreen({
    super.key,
    required this.photos,
    required this.onPhotoTapped,
    required this.isCelsius,
    required this.is24Hour,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(
        child: Text(
          'No photos to display',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final timeFormat = is24Hour
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');
        final dateFormat = DateFormat('MMMM d, yyyy');

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onPhotoTapped(index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.file(
                    File(photo.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeFormat.format(photo.timestamp)} ${dateFormat.format(photo.timestamp)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}