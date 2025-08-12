import 'dart:io' show Platform, SocketException;
import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async' show TimeoutException;
import '../models/card_model.dart';
import 'card_storage.dart';

class CloudSyncService {
  static const String _syncFileName = 'vaultdeck_cards.enc';
  static const String _folderName = 'VaultDeck';
  static const String _settingsBox = 'settingsBox';
  static const String _cloudSyncEnabledKey = 'cloudSyncEnabled';
  static const String _lastSyncTimeKey = 'lastSyncTime';
  static const String _cloudUserEmailKey = 'cloudUserEmail';
  static const String _encryptionKeyKey = 'encryptionKey';

  drive.DriveApi? _driveApi;
  String? _currentUserEmail;
  DateTime? _lastSyncTime;
  bool _cloudEnabled = false;
  String? _encryptionKey;
  String? _folderId;

  // Singleton pattern
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  // Getters
  bool get cloudEnabled => _cloudEnabled;
  String? get currentUserEmail => _currentUserEmail;
  DateTime? get lastSyncTime => _lastSyncTime;
  drive.DriveApi? get driveApi => _driveApi;

  Future<void> initialize() async {
    await _loadCloudSyncState();
  }

  Future<void> _loadCloudSyncState() async {
    final box = await Hive.openBox(_settingsBox);
    _cloudEnabled = box.get(_cloudSyncEnabledKey, defaultValue: false);
    _lastSyncTime = box.get(_lastSyncTimeKey) != null
        ? DateTime.parse(box.get(_lastSyncTimeKey))
        : null;
    _currentUserEmail = box.get(_cloudUserEmailKey);
    _encryptionKey = box.get(_encryptionKeyKey);
  }

  Future<void> _saveCloudSyncState() async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_cloudSyncEnabledKey, _cloudEnabled);
    if (_lastSyncTime != null) {
      await box.put(_lastSyncTimeKey, _lastSyncTime!.toIso8601String());
    }
    if (_currentUserEmail != null) {
      await box.put(_cloudUserEmailKey, _currentUserEmail);
    }
    if (_encryptionKey != null) {
      await box.put(_encryptionKeyKey, _encryptionKey);
    }
  }

  String _generateEncryptionKey() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        32,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String _encryptData(String data) {
    if (_encryptionKey == null) {
      _encryptionKey = _generateEncryptionKey();
    }

    // Simple XOR encryption (for demonstration - in production, use proper encryption)
    final keyBytes = utf8.encode(_encryptionKey!);
    final dataBytes = utf8.encode(data);
    final encryptedBytes = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encryptedBytes);
  }

  String _decryptData(String encryptedData) {
    if (_encryptionKey == null) {
      throw CloudSyncException('Encryption key not found');
    }

    final keyBytes = utf8.encode(_encryptionKey!);
    final encryptedBytes = base64.decode(encryptedData);
    final decryptedBytes = <int>[];

    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }

  Future<String?> _getOrCreateFolder() async {
    if (_driveApi == null) return null;

    try {
      // First, try to find existing folder
      final existingFolders = await _driveApi!.files.list(
        q: "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      );

      if (existingFolders.files != null && existingFolders.files!.isNotEmpty) {
        return existingFolders.files!.first.id;
      }

      // Create new folder if not found
      final folder = drive.File()
        ..name = _folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      throw CloudSyncException(
        'Failed to create or access VaultDeck folder: ${e.toString()}',
      );
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'NO_ICLOUD':
          return 'iCloud Drive is not available. Please check your iCloud settings and ensure you\'re signed in.';
        case 'NETWORK_ERROR':
          return 'Network connection is required for cloud sync. Please check your internet connection.';
        case 'AUTHENTICATION_FAILED':
          return 'Authentication failed. Please try signing in again.';
        case 'PERMISSION_DENIED':
          return 'Permission denied. Please check your cloud storage permissions.';
        case 'STORAGE_FULL':
          return 'Cloud storage is full. Please free up some space and try again.';
        case 'FILE_NOT_FOUND':
          return 'Sync file not found. This may be your first sync.';
        case 'QUOTA_EXCEEDED':
          return 'Cloud storage quota exceeded. Please upgrade your storage plan.';
        default:
          return 'Cloud sync failed. Please try again later.';
      }
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    } else if (error is TimeoutException) {
      return 'Sync timed out. Please check your connection and try again.';
    } else if (error is CloudSyncException) {
      return error.message;
    } else {
      // For any other unexpected errors, show a generic message
      return 'Something went wrong. Please try again later.';
    }
  }

  Future<bool> enableCloudSync() async {
    if (Platform.isAndroid) {
      return await _enableGoogleDriveSync();
    } else if (Platform.isIOS) {
      return await _enableICloudSync();
    }
    return false;
  }

  Future<bool> _enableGoogleDriveSync() async {
    try {
      final signedIn = await _signInWithGoogle();
      if (signedIn && _driveApi != null) {
        final syncSuccess = await _syncWithGoogleDrive();
        if (syncSuccess) {
          _cloudEnabled = true;
          await _saveCloudSyncState();
        }
        return syncSuccess;
      }
      return false;
    } catch (e) {
      throw CloudSyncException(_getUserFriendlyErrorMessage(e));
    }
  }

  Future<bool> _enableICloudSync() async {
    try {
      final syncSuccess = await _syncWithICloud();
      if (syncSuccess) {
        _cloudEnabled = true;
        await _saveCloudSyncState();
      }
      return syncSuccess;
    } catch (e) {
      throw CloudSyncException(_getUserFriendlyErrorMessage(e));
    }
  }

  Future<void> disableCloudSync() async {
    if (Platform.isAndroid && _driveApi != null) {
      try {
        final googleSignIn = GoogleSignIn.standard();
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore sign out errors
      }
    }

    _cloudEnabled = false;
    _currentUserEmail = null;
    _driveApi = null;
    await _saveCloudSyncState();
  }

  Future<bool> _signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.standard(
      scopes: [drive.DriveApi.driveFileScope],
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw CloudSyncException('Sign-in was cancelled');
      }

      final authHeaders = await account.authHeaders;
      final client = GoogleAuthClient(authHeaders);

      _driveApi = drive.DriveApi(client);
      _currentUserEmail = account.email;

      return true;
    } catch (e) {
      if (e is CloudSyncException) {
        rethrow;
      }
      throw CloudSyncException(_getUserFriendlyErrorMessage(e));
    }
  }

  Future<bool> _syncWithGoogleDrive() async {
    if (_driveApi == null) {
      throw CloudSyncException(
        'Google Drive authentication is required. Please try again.',
      );
    }

    try {
      // Get or create the VaultDeck folder
      _folderId = await _getOrCreateFolder();
      if (_folderId == null) {
        throw CloudSyncException(
          'Failed to create secure folder for your data',
        );
      }

      final cards = CardStorage.getAllCards();
      final jsonData = _createSyncData(cards);

      // Encrypt the data before uploading
      final encryptedData = _encryptData(jsonData);
      final bytes = utf8.encode(encryptedData);

      // Check if file already exists in the folder
      final existingFiles = await _driveApi!.files.list(
        q: "name='$_syncFileName' and '$_folderId' in parents and trashed=false",
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        // Update existing file
        final fileId = existingFiles.files!.first.id;
        await _driveApi!.files.update(
          drive.File(),
          fileId!,
          uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
        );
      } else {
        // Create new file in the folder
        final file = drive.File()
          ..name = _syncFileName
          ..mimeType =
              'application/octet-stream' // Binary file type
          ..parents = [_folderId!];

        await _driveApi!.files.create(
          file,
          uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
        );
      }

      _lastSyncTime = DateTime.now();
      await _saveCloudSyncState();
      return true;
    } catch (e) {
      // Check if it's an authentication error
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        // Clear the API and force re-authentication
        _driveApi = null;
        _currentUserEmail = null;
        throw CloudSyncException(
          'Authentication expired. Please try syncing again.',
        );
      }
      throw CloudSyncException(_getUserFriendlyErrorMessage(e));
    }
  }

  Future<bool> _syncWithICloud() async {
    try {
      final cards = CardStorage.getAllCards();
      final jsonData = _createSyncData(cards);

      // Encrypt the data before uploading
      final encryptedData = _encryptData(jsonData);

      final platform = MethodChannel('VaultDeck/icloud');
      await platform.invokeMethod('saveToICloud', {
        'fileName': _syncFileName,
        'content': encryptedData,
      });

      _lastSyncTime = DateTime.now();
      await _saveCloudSyncState();
      return true;
    } catch (e) {
      throw CloudSyncException(_getUserFriendlyErrorMessage(e));
    }
  }

  String _createSyncData(List<CardModel> cards) {
    final cardData = cards
        .map(
          (card) => {
            'cardHolderName': card.cardHolderName,
            'cardNumber': card.cardNumber,
            'expiryDate': card.expiryDate,
            'cardType': card.cardType,
            'cvv': card.cvv,
            'pin': card.pin,
            'nickname': card.nickname,
            'bankName': card.bankName,
            'notes': card.notes,
          },
        )
        .toList();

    return jsonEncode({
      'version': '1.0',
      'lastSync': DateTime.now().toIso8601String(),
      'cards': cardData,
    });
  }

  Future<bool> performSync() async {
    if (!_cloudEnabled) {
      throw CloudSyncException('Cloud sync is not enabled');
    }

    if (Platform.isAndroid) {
      // Check if we need to re-authenticate
      if (_driveApi == null || _currentUserEmail == null) {
        // Re-authenticate with Google
        final signedIn = await _signInWithGoogle();
        if (!signedIn) {
          throw CloudSyncException('Failed to re-authenticate with Google');
        }
      }
      return await _syncWithGoogleDrive();
    } else if (Platform.isIOS) {
      return await _syncWithICloud();
    }

    return false;
  }

  String getLastSyncStatus() {
    if (_lastSyncTime == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inDays > 0) {
      return 'Last synced ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return 'Last synced ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return 'Last synced ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Last synced just now';
    }
  }

  int getCardCount() {
    return CardStorage.getAllCards().length;
  }
}

class CloudSyncException implements Exception {
  final String message;
  CloudSyncException(this.message);

  @override
  String toString() => message;
}

// GoogleAuthClient implementation for googleapis
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
