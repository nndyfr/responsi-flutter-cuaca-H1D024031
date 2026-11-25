import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherService = WeatherService();
    final storage = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(weatherService, storage)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
          SearchViewModel(weatherService, storage)..loadFavorites(),
        ),
      ],
      child: MaterialApp(
        title: 'Aplikasi Cuaca',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue.shade700,
            secondary: Colors.lightBlue.shade600,
            surface: Colors.blue.shade50,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F8FB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          textTheme: const TextTheme(
            displayMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            titleLarge: TextStyle(fontWeight: FontWeight.bold),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
