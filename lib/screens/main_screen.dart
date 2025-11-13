import 'package:flutter/material.dart';
import '../models/photo_entry.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import 'home_screen.dart';
import 'list_screen.dart';
import 'grid_screen.dart';
import 'settings_screen.dart';
import 'camera_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const MainScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // start on home screen
  int _selectedPhotoIndex = 0; 
  final TextEditingController _searchController = TextEditingController();
  List<PhotoEntry> _photos = [];
  List<PhotoEntry> _filteredPhotos = [];
  bool _isDarkMode = false;
  bool _isCelsius = true;
  bool _is24Hour = false;
  final SettingsService _settingsService = SettingsService();


  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPhotos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final darkMode = await _settingsService.getDarkMode();
    final celsius = await _settingsService.getIsCelsius();
    final hour24 = await _settingsService.getIs24Hour();
    
    setState(() {
      _isDarkMode = darkMode;
      _isCelsius = celsius;
      _is24Hour = hour24;
    });
  }

  Future<void> _loadPhotos() async {
    final photos = await DatabaseService.instance.getAllPhotos();
    setState(() {
      _photos = photos;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchController.text.isEmpty) {
      _filteredPhotos = List.from(_photos);
    } else {
      _filteredPhotos = _photos.where((photo) {
        return photo.description
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          isCelsius: _isCelsius,
          is24Hour: _is24Hour,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadPhotos();
      setState(() {
        _selectedPhotoIndex = 0;
      });
    }
  }

  void _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: _isDarkMode,
          isCelsius: _isCelsius,
          is24Hour: _is24Hour,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadSettings();
      widget.onThemeChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ListScreen(
        photos: _filteredPhotos,
        onPhotoDeleted: _loadPhotos,
        onPhotoTapped: (index) {
          setState(() {
            _selectedPhotoIndex = index;
            _selectedIndex = 2;
          });
        },
        isCelsius: _isCelsius,
        is24Hour: _is24Hour,
      ),
      GridScreen(
        photos: _filteredPhotos,
        onPhotoTapped: (index) {
          setState(() {
            _selectedPhotoIndex = index;
            _selectedIndex = 2;
          });
        },
        isCelsius: _isCelsius,
        is24Hour: _is24Hour,
        onPhotoDeleted: _loadPhotos,
      ),
      HomeScreen(
        photos: _filteredPhotos,
        onPhotoUpdated: _loadPhotos,
        isCelsius: _isCelsius,
        is24Hour: _is24Hour,
        initialIndex: _selectedPhotoIndex,
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('WindowPane'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _applyFilter();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _applyFilter();
                  });
                },
              ),
            ),
          ),
        ),
        body: screens[_selectedIndex],
        floatingActionButton: _selectedIndex == 2
            ? FloatingActionButton(
                onPressed: _navigateToCamera,
                child: const Icon(Icons.add_a_photo),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Grid',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
    );
  }
}