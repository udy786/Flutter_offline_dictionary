import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../app/theme/colors.dart';
import '../../../core/services/database_download_service.dart';

class DatabaseDownloadScreen extends StatefulWidget {
  final VoidCallback onDownloadComplete;
  final VoidCallback? onDownloadStarted;

  const DatabaseDownloadScreen({
    super.key,
    required this.onDownloadComplete,
    this.onDownloadStarted,
  });

  @override
  State<DatabaseDownloadScreen> createState() => _DatabaseDownloadScreenState();
}

class _DatabaseDownloadScreenState extends State<DatabaseDownloadScreen> {
  double _progress = 0.0;
  bool _isDownloading = false;
  String? _errorMessage;
  bool _isOnWifi = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isOnWifi = connectivityResult == ConnectivityResult.wifi;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnWifi = false;
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (widget.onDownloadStarted != null) {
      widget.onDownloadStarted!();
      return;
    }

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      final downloadService = DatabaseDownloadService();

      await for (final progress in downloadService.downloadDatabase()) {
        if (mounted) {
          setState(() {
            _progress = progress.isNaN || progress.isInfinite
                ? 0.0
                : progress.clamp(0.0, 1.0);
          });
        }
      }

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          widget.onDownloadComplete();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.screenBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // App icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2196F3),
                            Color(0xFF1565C0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Text(
                      'WordBridge',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryC,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'English - Hindi Dictionary',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Download card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.subtleShadow,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Download icon
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_download_rounded,
                              size: 32,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Download Required',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryC,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The dictionary database (460 MB) needs to be downloaded for offline use.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Connection status
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isOnWifi
                                  ? const Color(0xFF4CAF50).withOpacity(0.08)
                                  : const Color(0xFFFF9800).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isOnWifi
                                      ? Icons.wifi_rounded
                                      : Icons.signal_cellular_alt_rounded,
                                  size: 18,
                                  color: _isOnWifi
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isOnWifi
                                      ? 'Connected to WiFi'
                                      : 'Using cellular data',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _isOnWifi
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF9800),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (!_isOnWifi) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Large download — WiFi recommended',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress (when downloading)
                    if (_isDownloading) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.subtleShadow,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor:
                                    const Color(0xFF2196F3).withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2196F3)),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_progress * 100).toStringAsFixed(1)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF2196F3),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(_progress * 460).toStringAsFixed(0)} MB / 460 MB',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please keep the app open...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Colors.red.shade400, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Download Failed',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Download button
                    if (!_isDownloading)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startDownload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Download Database (460 MB)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Feature list
                    if (!_isDownloading) ...[
                      _FeatureRow(
                        icon: Icons.cloud_off_rounded,
                        text: 'Download once, use offline forever',
                      ),
                      const SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.translate_rounded,
                        text: '1.4M+ English words + 35K+ Hindi words',
                      ),
                      const SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.wifi_off_rounded,
                        text: 'No internet needed after download',
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ),
      ],
    );
  }
}
