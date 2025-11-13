import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_entry.dart';
import '../services/database_service.dart';

class ListScreen extends StatelessWidget {
  final List<PhotoEntry> photos;
  final VoidCallback onPhotoDeleted;
  final Function(int) onPhotoTapped;
  final bool isCelsius;
  final bool is24Hour;

  const ListScreen({
    super.key,
    required this.photos,
    required this.onPhotoDeleted,
    required this.onPhotoTapped,
    required this.isCelsius,
    required this.is24Hour,
  });

  void _deletePhoto(BuildContext context, PhotoEntry photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deletePhoto(photo.id!);
              onPhotoDeleted();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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

    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final timeFormat = is24Hour
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');
        final dateFormat = DateFormat('MMMM d, yyyy');

        return Dismissible(
          key: Key(photo.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            _deletePhoto(context, photo);
            return false;
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photo.imagePath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              photo.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${timeFormat.format(photo.timestamp)} ${dateFormat.format(photo.timestamp)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onPhotoTapped(index),
            onLongPress: () => _deletePhoto(context, photo),
          ),
        );
      },
    );
  }
}