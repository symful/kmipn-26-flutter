import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

/// Service for handling photo uploads to R2 via signed URLs.
///
/// Provides immediate upload after capture and returns the R2 URL
/// for storage in the database.
class PhotoService {
  final ApiClient _api;

  PhotoService(this._api);

  /// Uploads a photo to R2 via signed URL and returns the public R2 URL.
  ///
  /// [localFilePath] - Path to the local photo file
  /// [idempotencyKey] - Unique key for the report this photo belongs to
  ///
  /// Returns the R2 URL if upload succeeds, or the local path if upload fails
  /// (for offline fallback).
  Future<String> uploadPhotoAndGetUrl(
    String localFilePath,
    String idempotencyKey,
  ) async {
    try {
      final photoFile = File(localFilePath);
      final photoBytes = await photoFile.readAsBytes();
      final filename = localFilePath.split('/').last;
      final uploadUrl = '/api/reports/$idempotencyKey/photos/upload-url';

      final result = await _api.uploadPhotoBytes(
        uploadUrl,
        photoBytes,
        filename,
      );

      // Use typed EvidenceResult.evidenceId field
      // The evidenceId contains the R2 URL for the uploaded photo
      final evidenceId = result.evidenceId;
      if (evidenceId.isNotEmpty) {
        return evidenceId;
      }

      // If evidenceId is empty, return local path for offline fallback
      debugPrint('PhotoService: No evidenceId in result, using local path');
      return localFilePath;
    } catch (e) {
      debugPrint(
        'PhotoService: Upload failed, using local path as fallback: $e',
      );
      // Return local path as offline fallback - sync will handle this case
      return localFilePath;
    }
  }

  /// Checks if a path is an R2/remote URL (vs local file path).
  bool isRemoteUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
