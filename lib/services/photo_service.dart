import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/client.dart';

/// Service for handling photo uploads to R2 via signed URLs.
///
/// Provides immediate upload after capture and returns the public URL
/// for storage in the database.
class PhotoService {
  final ApiClient _api;

  PhotoService(this._api);

  /// Uploads a photo to R2 via signed URL and returns the public URL.
  ///
  /// [localFilePath] - Path to the local photo file
  /// [reportId] - The report ID to upload the photo to
  /// [uploadToken] - The upload token from report creation or task detail
  ///
  /// Returns the public R2 URL if upload succeeds, or the local path if upload fails
  /// (for offline fallback).
  Future<String> uploadPhotoAndGetUrl(
    String localFilePath,
    String reportId,
    String uploadToken, {
    int slot = 0,
  }) async {
    try {
      final photoFile = File(localFilePath);
      if (!await photoFile.exists()) {
        debugPrint('PhotoService: File not found: $localFilePath');
        return localFilePath;
      }
      final bytes = await photoFile.readAsBytes();

      // Step 1: Get presigned PUT URL from backend
      final uploadUrlResp = await _api.getPhotoUploadUrl(
        reportId,
        uploadToken,
        slot: slot,
      );
      final putUrl = uploadUrlResp.putUrl;
      if (putUrl == null || putUrl.isEmpty) {
        debugPrint('PhotoService: No putUrl in response');
        return localFilePath;
      }

      // Step 2: PUT raw bytes to R2 via presigned URL
      await _api.putPhoto(
        reportId: reportId,
        putUrl: putUrl,
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      // The public URL is derived from the putUrl pattern:
      // putUrl is like https://pub-xxx.r2.dev/.../photo.jpg?sig=...
      // We extract the base URL without query params
      final uri = Uri.parse(putUrl);
      final publicUrl = uri.replace(queryParameters: {}).toString();

      debugPrint('PhotoService: Upload succeeded, public URL: $publicUrl');
      return publicUrl;
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
