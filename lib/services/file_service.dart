import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileService {
  static const _uuid = Uuid();

  /// Pick an audio file and copy it to app documents/audio/.
  /// Returns a map with filePath (relative), fileExt, and originalName,
  /// or null if the user cancelled.
  static Future<Map<String, String>?> pickAndCopyAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.path == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    // Extract extension
    final originalName = file.name;
    final dotIndex = originalName.lastIndexOf('.');
    final ext = dotIndex != -1
        ? originalName.substring(dotIndex + 1).toLowerCase()
        : 'mp3';

    final newFileName = '${_uuid.v4()}.$ext';
    final newPath = '${audioDir.path}/$newFileName';

    await File(file.path!).copy(newPath);

    return {
      'filePath': 'audio/$newFileName',
      'fileExt': ext,
      'originalName': originalName,
    };
  }

  /// Get absolute path from relative path within app documents.
  static Future<String> getFullPath(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$relativePath';
  }

  /// Delete an audio file from app documents.
  static Future<void> deleteAudioFile(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently handle file deletion errors
    }
  }

  /// Check if an audio file exists.
  static Future<bool> audioFileExists(String relativePath) async {
    final fullPath = await getFullPath(relativePath);
    return File(fullPath).exists();
  }
}
