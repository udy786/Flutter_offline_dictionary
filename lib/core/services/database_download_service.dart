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
  static const String _partialFileName = 'dictionary.db.part';
  static const String _githubDownloadUrl = 'https://github.com/DarshanIncredere/dictionary-database-files/releases/download/v1.0.0/dictionary.db';

  /// Get the local path where the database should be stored
  Future<String> getDatabasePath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/$_databaseFileName';
  }

  /// Get the partial download file path
  Future<String> _getPartialPath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/$_partialFileName';
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

  /// Download database from GitHub with progress tracking and resume support
  /// Returns a stream of download progress (0.0 to 1.0)
  Stream<double> downloadDatabase() async* {
    try {
      final dbPath = await getDatabasePath();
      final partialPath = await _getPartialPath();
      final partialFile = File(partialPath);
      final dbFile = File(dbPath);

      // Ensure parent directory exists
      await partialFile.parent.create(recursive: true);

      // Check if we have a partial download to resume
      int existingBytes = 0;
      if (await partialFile.exists()) {
        existingBytes = await partialFile.length();
        debugPrint('DatabaseDownloadService: Found partial download, resuming from ${existingBytes ~/ (1024 * 1024)}MB');
      }

      debugPrint('DatabaseDownloadService: Starting download from GitHub');
      debugPrint('DatabaseDownloadService: URL: $_githubDownloadUrl');

      // Make HTTP request with Range header for resume
      final request = http.Request('GET', Uri.parse(_githubDownloadUrl));
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
        debugPrint('DatabaseDownloadService: Requesting Range: bytes=$existingBytes-');
      }

      final response = await request.send();

      // 206 = Partial Content (resume supported), 200 = Full download
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Failed to download file. Status code: ${response.statusCode}');
      }

      int totalBytes;
      int bytesReceived;

      if (response.statusCode == 206) {
        // Server supports resume — continuing from existingBytes
        totalBytes = existingBytes + (response.contentLength ?? 0);
        bytesReceived = existingBytes;
        debugPrint('DatabaseDownloadService: Resuming download. Already have ${existingBytes ~/ (1024 * 1024)}MB, total ${totalBytes ~/ (1024 * 1024)}MB');
      } else {
        // Server sent full file (doesn't support Range or fresh download)
        totalBytes = response.contentLength ?? 0;
        bytesReceived = 0;
        existingBytes = 0;
        // Delete partial file since we're starting fresh
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
        debugPrint('DatabaseDownloadService: Full download. File size: ${totalBytes ~/ (1024 * 1024)}MB');
      }

      // Yield initial progress if resuming
      if (bytesReceived > 0 && totalBytes > 0) {
        yield bytesReceived / totalBytes;
      }

      // Open file in append mode (for resume) or write mode (for fresh)
      final sink = partialFile.openWrite(mode: existingBytes > 0 ? FileMode.append : FileMode.write);

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          bytesReceived += chunk.length;

          // Calculate and yield progress
          if (totalBytes > 0) {
            final progress = bytesReceived / totalBytes;
            yield progress;
          } else {
            yield 0.5;
          }
        }
      } finally {
        await sink.close();
      }

      debugPrint('DatabaseDownloadService: Download completed successfully');

      // Verify downloaded file
      if (await partialFile.exists()) {
        final fileSize = await partialFile.length();
        debugPrint('DatabaseDownloadService: Downloaded file size: ${fileSize ~/ (1024 * 1024)}MB');

        if (fileSize < 100 * 1024 * 1024) {
          throw Exception('Downloaded file is too small (${fileSize ~/ (1024 * 1024)}MB). Download may be corrupted.');
        }

        // Rename partial file to final database file
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        await partialFile.rename(dbPath);
        debugPrint('DatabaseDownloadService: Database saved to $dbPath');
      } else {
        throw Exception('File does not exist after download');
      }

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
      // Also delete partial file
      final partialPath = await _getPartialPath();
      final partialFile = File(partialPath);
      if (await partialFile.exists()) {
        await partialFile.delete();
        debugPrint('DatabaseDownloadService: Deleted partial download');
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
