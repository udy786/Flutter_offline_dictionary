import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DatabaseDownloadService {
  static final DatabaseDownloadService _instance = DatabaseDownloadService._internal();
  factory DatabaseDownloadService() => _instance;
  DatabaseDownloadService._internal();

  // GitHub Release download URL for your database file
  static const String _databaseFileName = 'dictionary.db';
  static const String _githubDownloadUrl = 'https://github.com/DarshanIncredere/dictionary-database-files/releases/download/v1.0.0/dictionary.db';

  /// Get the local path where the database should be stored
  Future<String> getDatabasePath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/$_databaseFileName';
  }

  /// Check if database exists locally
  Future<bool> isDatabaseDownloaded() async {
    final path = await getDatabasePath();
    final file = File(path);

    if (!await file.exists()) {
      return false;
    }

    // Check if file is not empty (at least 100MB to ensure it's valid)
    final fileSize = await file.length();
    if (fileSize < 100 * 1024 * 1024) {
      debugPrint('DatabaseDownloadService: Database file too small ($fileSize bytes), will re-download');
      return false;
    }

    debugPrint('DatabaseDownloadService: Database already exists at $path (${fileSize ~/ (1024 * 1024)}MB)');
    return true;
  }

  /// Download database from GitHub with progress tracking
  /// Returns a stream of download progress (0.0 to 1.0)
  Stream<double> downloadDatabase() async* {
    try {
      final path = await getDatabasePath();
      final file = File(path);

      // Delete existing file if it exists
      if (await file.exists()) {
        await file.delete();
      }

      // Ensure parent directory exists
      await file.parent.create(recursive: true);

      debugPrint('DatabaseDownloadService: Starting download from GitHub');
      debugPrint('DatabaseDownloadService: URL: $_githubDownloadUrl');
      debugPrint('DatabaseDownloadService: Local path: $path');

      // Make HTTP request with streaming
      final request = http.Request('GET', Uri.parse(_githubDownloadUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to download file. Status code: ${response.statusCode}');
      }

      // Get total file size from Content-Length header
      final totalBytes = response.contentLength ?? 0;

      if (totalBytes == 0) {
        debugPrint('DatabaseDownloadService: Warning - Could not determine file size from headers');
      } else {
        debugPrint('DatabaseDownloadService: File size: ${totalBytes ~/ (1024 * 1024)}MB');
      }

      // Download with progress tracking
      int bytesReceived = 0;
      final sink = file.openWrite();

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          bytesReceived += chunk.length;

          // Calculate and yield progress
          if (totalBytes > 0) {
            final progress = bytesReceived / totalBytes;
            debugPrint('DatabaseDownloadService: Downloaded ${bytesReceived ~/ (1024 * 1024)}MB / ${totalBytes ~/ (1024 * 1024)}MB (${(progress * 100).toStringAsFixed(1)}%)');
            yield progress;
          } else {
            // If we don't know total size, yield progress based on received bytes
            debugPrint('DatabaseDownloadService: Downloaded ${bytesReceived ~/ (1024 * 1024)}MB');
            yield 0.5; // Show some progress
          }
        }
      } finally {
        await sink.close();
      }

      debugPrint('DatabaseDownloadService: Download completed successfully');

      // Verify downloaded file
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('DatabaseDownloadService: Database saved to $path (${fileSize ~/ (1024 * 1024)}MB)');

        if (fileSize < 100 * 1024 * 1024) {
          throw Exception('Downloaded file is too small (${fileSize ~/ (1024 * 1024)}MB). Download may be corrupted.');
        }
      } else {
        throw Exception('File does not exist after download');
      }

      // Yield 1.0 and return to end the stream
      yield 1.0;
    } catch (e) {
      debugPrint('DatabaseDownloadService: Error downloading database: $e');
      rethrow;
    }
  }

  /// Delete local database (useful for testing or re-downloading)
  Future<void> deleteLocalDatabase() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('DatabaseDownloadService: Deleted local database');
      }
    } catch (e) {
      debugPrint('DatabaseDownloadService: Error deleting database: $e');
    }
  }

  /// Get database file size in MB
  Future<int?> getDatabaseSizeMB() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes ~/ (1024 * 1024);
      }
      return null;
    } catch (e) {
      debugPrint('DatabaseDownloadService: Error getting database size: $e');
      return null;
    }
  }
}
