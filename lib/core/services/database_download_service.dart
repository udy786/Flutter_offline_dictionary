import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseDownloadService {
  static final DatabaseDownloadService _instance = DatabaseDownloadService._internal();
  factory DatabaseDownloadService() => _instance;
  DatabaseDownloadService._internal();

  // Firebase Storage path to your database file
  static const String _databaseFileName = 'dictionary.db';
  static const String _firebaseStoragePath = 'database/dictionary.db';

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

  /// Download database from Firebase Storage with progress tracking
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

      debugPrint('DatabaseDownloadService: Starting download from Firebase Storage');
      debugPrint('DatabaseDownloadService: Storage path: $_firebaseStoragePath');
      debugPrint('DatabaseDownloadService: Local path: $path');

      // Get reference to Firebase Storage file
      final ref = FirebaseStorage.instance.ref().child(_firebaseStoragePath);

      // Get metadata to know total file size
      final metadata = await ref.getMetadata();
      final totalBytes = metadata.size ?? 0;

      if (totalBytes == 0) {
        debugPrint('DatabaseDownloadService: Warning - Could not determine file size from metadata');
      } else {
        debugPrint('DatabaseDownloadService: File size: ${totalBytes ~/ (1024 * 1024)}MB');
      }

      // Download with progress tracking
      final downloadTask = ref.writeToFile(file);

      // Listen to progress
      await for (final snapshot in downloadTask.snapshotEvents) {
        if (snapshot.state == TaskState.running) {
          // Handle case where totalBytes might be 0 to avoid NaN
          final progress = snapshot.totalBytes > 0
              ? snapshot.bytesTransferred / snapshot.totalBytes
              : 0.0;

          // Only yield valid progress values
          if (!progress.isNaN && !progress.isInfinite) {
            debugPrint('DatabaseDownloadService: Downloaded ${snapshot.bytesTransferred ~/ (1024 * 1024)}MB / ${snapshot.totalBytes ~/ (1024 * 1024)}MB (${(progress * 100).toStringAsFixed(1)}%)');
            yield progress;
          }
        } else if (snapshot.state == TaskState.success) {
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
          return;
        } else if (snapshot.state == TaskState.error) {
          throw Exception('Download failed: ${snapshot.state}');
        } else if (snapshot.state == TaskState.canceled) {
          throw Exception('Download canceled');
        } else if (snapshot.state == TaskState.paused) {
          debugPrint('DatabaseDownloadService: Download paused');
        }
      }

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
