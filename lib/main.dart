import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final darkMode = await _settingsService.getDarkMode();
    setState(() {
      _isDarkMode = darkMode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WindowPane',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 41, 93, 135),
          brightness: Brightness.light,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 41, 93, 135),
          brightness: Brightness.dark,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(onThemeChanged: _loadTheme),
    );
  }
}