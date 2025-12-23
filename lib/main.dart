import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/database_download_service.dart';
import 'data/database/app_database.dart';
import 'presentation/screens/database_download/database_download_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdService().initialize();

  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppDatabase? _database;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkDatabaseAndInitialize();
  }

  Future<void> _checkDatabaseAndInitialize() async {
    final downloadService = DatabaseDownloadService();
    final isDatabaseReady = await downloadService.isDatabaseDownloaded();

    if (isDatabaseReady) {
      // Database exists, initialize it
      _database = AppDatabase();
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _onDatabaseDownloaded() {
    // After download, reinitialize
    setState(() {
      _database = AppDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading while checking database
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_database != null) {
      // Database is ready, show main app
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(_database!),
        ],
        child: const DictionaryApp(),
      );
    } else {
      // Database needs to be downloaded
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DatabaseDownloadScreen(
          onDownloadComplete: _onDatabaseDownloaded,
        ),
      );
    }
  }
}

