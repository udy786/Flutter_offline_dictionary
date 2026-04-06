import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/colors.dart';
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

  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadError;

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
    } else {
      // Check if there's a partial download to auto-resume
      final partialPath = await downloadService.getDatabasePath();
      final partialFile =
          File('${partialPath.replaceAll('.db', '.db.part')}');
      if (await partialFile.exists()) {
        final partialSize = await partialFile.length();
        if (partialSize > 0) {
          // Auto-resume download
          setState(() {
            _isInitialized = true;
          });
          _onDownloadStarted();
          return;
        }
      }
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

  /// Called when user taps download — starts background download and shows home screen
  void _onDownloadStarted() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadError = null;
    });
    _runBackgroundDownload();
  }

  Future<void> _runBackgroundDownload() async {
    try {
      final downloadService = DatabaseDownloadService();

      await for (final progress in downloadService.downloadDatabase()) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress.isNaN || progress.isInfinite
                ? 0.0
                : progress.clamp(0.0, 1.0);
          });
        }
      }

      // Download complete
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _database = AppDatabase();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadError = e.toString();
        });
      }
    }
  }

  /// Retry download after error
  void _retryDownload() {
    _onDownloadStarted();
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
    }

    if (_isDownloading || _downloadError != null) {
      // Show home-like screen with download progress
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: _DownloadingHomeScreen(
          progress: _downloadProgress,
          isDownloading: _isDownloading,
          error: _downloadError,
          onRetry: _retryDownload,
        ),
      );
    }

    // Database needs to be downloaded — show download screen
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DatabaseDownloadScreen(
        onDownloadComplete: _onDatabaseDownloaded,
        onDownloadStarted: _onDownloadStarted,
      ),
    );
  }
}

/// Home-like screen shown while database is downloading in background
class _DownloadingHomeScreen extends StatelessWidget {
  final double progress;
  final bool isDownloading;
  final String? error;
  final VoidCallback onRetry;

  const _DownloadingHomeScreen({
    required this.progress,
    required this.isDownloading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Slim top download bar
            _buildTopBar(context, theme),

            // Main content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App bar matching real home screen
                  SliverAppBar(
                    expandedHeight: 140,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'WordBridge – Offline Dictionary',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),

                        // Search bar (disabled)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade100,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please wait for database download to complete'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(Icons.search,
                                        color: AppColors.textHint, size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Search for a word...',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Placeholder content
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.05),
                                AppColors.primary.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.auto_stories,
                                  color: AppColors.primary.withOpacity(0.3),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Dictionary will be ready soon',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '1.4M+ English words • 35K+ Hindi words',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeData theme) {
    if (error != null) {
      // Error bar
      return Material(
        color: AppColors.error,
        child: InkWell(
          onTap: onRetry,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Download failed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Retry',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Downloading bar
    final downloadedMB = (progress * 460).toStringAsFixed(0);
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Downloading dictionary...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%  •  $downloadedMB / 460 MB',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        // Thin progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.primary.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 3,
        ),
      ],
    );
  }
}
