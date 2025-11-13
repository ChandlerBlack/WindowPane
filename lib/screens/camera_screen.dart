import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../models/photo_entry.dart';

class CameraScreen extends StatefulWidget {
  final bool isCelsius;
  final bool is24Hour;

  const CameraScreen({
    super.key,
    required this.isCelsius,
    required this.is24Hour,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras = [];
  bool _isLoading = true;
  String _locationText = 'Getting location...';
  String _weatherText = 'Getting weather...';
  double? _latitude;
  double? _longitude;
  String? _address;
  double? _temperature;
  String? _weatherCondition;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _updateLocationAndWeather();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _updateLocationAndWeather() async {
    final locationService = LocationService();
    final weatherService = WeatherService();

    try {
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;

        _address = await locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final weather = await weatherService.getWeather(
          position.latitude,
          position.longitude,
        );

        _temperature = weather['temperature'];
        _weatherCondition = weather['condition'];

        if (mounted) {
          setState(() {
            _locationText = _address ?? 'Unknown location';
            final temp = _settingsService
                .convertTemperature(_temperature!, widget.isCelsius)
                .round();
            final unit = _settingsService.getTemperatureUnit(widget.isCelsius);
            _weatherText = '$temp$unit $_weatherCondition';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _weatherText = 'Weather unavailable';
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller!.takePicture();

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoPreviewScreen(
              imagePath: image.path,
              latitude: _latitude ?? 0,
              longitude: _longitude ?? 0,
              address: _address ?? 'Unknown location',
              temperature: _temperature ?? 0,
              weatherCondition: _weatherCondition ?? 'Unknown',
              isCelsius: widget.isCelsius,
              is24Hour: widget.is24Hour,
            ),
          ),
        );

        if (result == true && mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WindowPane'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _controller != null
                      ? CameraPreview(_controller!)
                      : const Center(child: Text('Camera not available')),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny),
                          const SizedBox(width: 8),
                          Text(
                            _weatherText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera),
                        label: const Text('TAKE PICTURE'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class PhotoPreviewScreen extends StatefulWidget {
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;
  final double temperature;
  final String weatherCondition;
  final bool isCelsius;
  final bool is24Hour;

  const PhotoPreviewScreen({
    super.key,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.temperature,
    required this.weatherCondition,
    required this.isCelsius,
    required this.is24Hour,
  });

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final SettingsService _settingsService = SettingsService();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePhoto() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    try {
      // Copy image to permanent storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(widget.imagePath);
      final permanentPath = path.join(appDir.path, fileName);
      await File(widget.imagePath).copy(permanentPath);

      final photo = PhotoEntry(
        imagePath: permanentPath,
        description: _descriptionController.text,
        timestamp: DateTime.now(),
        latitude: widget.latitude,
        longitude: widget.longitude,
        address: widget.address,
        temperature: widget.temperature,
        weatherCondition: widget.weatherCondition,
      );

      await DatabaseService.instance.insertPhoto(photo);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving photo: $e')),
        );
      }
    }
  }

  void _discard() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final temp = _settingsService
        .convertTemperature(widget.temperature, widget.isCelsius)
        .round();
    final unit = _settingsService.getTemperatureUnit(widget.isCelsius);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WindowPane'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny),
                    const SizedBox(width: 8),
                    Text(
                      '$temp$unit ${widget.weatherCondition}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _discard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(0, 50),
                        ),
                        child: const Text('DISCARD'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _savePhoto,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                        ),
                        child: const Text('SAVE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}