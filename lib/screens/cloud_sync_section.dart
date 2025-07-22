import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class CloudSyncSection extends StatefulWidget {
  const CloudSyncSection({super.key});

  @override
  State<CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends State<CloudSyncSection> {
  bool _cloudEnabled = false;
  bool _syncing = false;
  String _status = 'Not synced';
  drive.DriveApi? _driveApi;

  void _toggleCloud(bool value) async {
    setState(() {
      _cloudEnabled = value;
    });
    if (value) {
      if (Platform.isAndroid) {
        await _signInWithGoogle();
        await _syncWithGoogleDrive();
      } else if (Platform.isIOS) {
        await _syncWithICloud();
      }
    } else {
      setState(() {
        _status = Platform.isIOS
            ? 'iCloud sync disabled'
            : 'Google Drive sync disabled';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.standard(
      scopes: [drive.DriveApi.driveFileScope],
    );
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _status = 'Google sign-in cancelled';
        });
        return;
      }
      final authHeaders = await account.authHeaders;
      final client = GoogleAuthClient(authHeaders);
      setState(() {
        _driveApi = drive.DriveApi(client);
        _status = 'Signed in as ${account.email}';
      });
    } catch (e) {
      setState(() {
        _status = 'Google sign-in failed: $e';
      });
    }
  }

  Future<void> _syncWithGoogleDrive() async {
    setState(() {
      _syncing = true;
      _status = 'Syncing with Google Drive...';
    });
    try {
      // Example: create a file in Google Drive
      if (_driveApi != null) {
        var file = drive.File();
        file.name = 'card_storage_backup.txt';
        file.mimeType = 'text/plain';
        await _driveApi!.files.create(
          file,
          uploadMedia: drive.Media(
            Stream.value([104, 101, 108, 108, 111]), // 'hello' as bytes
            5,
          ),
        );
        setState(() {
          _status = 'Synced to Google Drive!';
        });
      } else {
        setState(() {
          _status = 'Google Drive API not initialized.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Google Drive sync failed: $e';
      });
    }
    setState(() {
      _syncing = false;
    });
  }

  Future<void> _syncWithICloud() async {
    setState(() {
      _syncing = true;
      _status = 'Syncing with iCloud...';
    });
    final platform = MethodChannel('VaultDeck/icloud');
    try {
      // Example file content and name
      final result = await platform.invokeMethod('saveToICloud', {
        'fileName': 'card_storage_backup.txt',
        'content': 'hello', // Replace with your actual data
      });
      setState(() {
        _status = result ?? 'iCloud sync complete';
      });
    } catch (e) {
      setState(() {
        _status = 'iCloud sync failed: $e';
      });
    }
    setState(() {
      _syncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF23262F) : Colors.white;
    final isIOS = Platform.isIOS;
    final switchTitle = isIOS
        ? 'Enable iCloud Sync'
        : 'Enable Google Drive Sync';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
          child: Row(
            children: [
              const Icon(Icons.cloud_rounded, size: 22),
              const SizedBox(width: 8),
              Text(
                'Cloud Sync',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(switchTitle),
                value: _cloudEnabled,
                onChanged: _toggleCloud,
                secondary: const Icon(Icons.sync_rounded),
                tileColor: tileBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    if (_syncing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_syncing) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
