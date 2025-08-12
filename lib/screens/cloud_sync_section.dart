import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../services/cloud_sync_service.dart';

class CloudSyncSection extends StatefulWidget {
  const CloudSyncSection({super.key});

  @override
  State<CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends State<CloudSyncSection> {
  final CloudSyncService _cloudSyncService = CloudSyncService();
  bool _syncing = false;
  String _status = 'Not synced';
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _initializeCloudSync();
  }

  Future<void> _initializeCloudSync() async {
    await _cloudSyncService.initialize();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _status = _cloudSyncService.getLastSyncStatus();
      _showRetryButton = false;
    });
  }

  void _toggleCloud(bool value) async {
    if (value && !_cloudSyncService.cloudEnabled) {
      // Enable cloud sync
      await _enableCloudSync();
    } else if (!value && _cloudSyncService.cloudEnabled) {
      // Disable cloud sync
      await _disableCloudSync();
    }
  }

  Future<void> _enableCloudSync() async {
    setState(() {
      _syncing = true;
      _status = 'Setting up cloud sync...';
      _showRetryButton = false;
    });

    try {
      final success = await _cloudSyncService.enableCloudSync();
      if (success) {
        setState(() {
          _status =
              'Successfully synced ${_cloudSyncService.getCardCount()} cards!';
          _showRetryButton = false;
        });
      } else {
        setState(() {
          _status = 'Failed to enable cloud sync';
          _showRetryButton = true;
        });
      }
    } catch (e) {
      setState(() {
        _status = e.toString();
        _showRetryButton = _shouldShowRetryButton(e.toString());
      });
    } finally {
      setState(() {
        _syncing = false;
      });
    }
  }

  Future<void> _disableCloudSync() async {
    try {
      await _cloudSyncService.disableCloudSync();
      setState(() {
        _status = 'Cloud sync disabled';
        _showRetryButton = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to disable cloud sync: ${e.toString()}';
        _showRetryButton = false;
      });
    }
  }

  Future<void> _manualSync() async {
    if (!_cloudSyncService.cloudEnabled) return;

    setState(() {
      _syncing = true;
      _status = 'Syncing...';
      _showRetryButton = false;
    });

    try {
      final success = await _cloudSyncService.performSync();
      if (success) {
        setState(() {
          _status =
              'Successfully synced ${_cloudSyncService.getCardCount()} cards!';
          _showRetryButton = false;
        });
      } else {
        setState(() {
          _status = 'Sync failed';
          _showRetryButton = true;
        });
      }
    } catch (e) {
      setState(() {
        _status = e.toString();
        _showRetryButton = _shouldShowRetryButton(e.toString());
      });
    } finally {
      setState(() {
        _syncing = false;
      });
    }
  }

  bool _shouldShowRetryButton(String errorMessage) {
    // Show retry button for recoverable errors
    final retryableErrors = [
      'network',
      'connection',
      'timeout',
      'temporarily',
      'try again',
      'check your',
      'ensure you',
    ];

    final lowerError = errorMessage.toLowerCase();
    return retryableErrors.any((error) => lowerError.contains(error));
  }

  void _showErrorDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Sync Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_status),
            const SizedBox(height: 16),
            const Text(
              'Troubleshooting tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (Platform.isIOS) ...[
              const Text('• Check if iCloud Drive is enabled in Settings'),
              const Text('• Ensure you\'re signed in to iCloud'),
              const Text('• Check your internet connection'),
              const Text('• Try signing out and back into iCloud'),
            ] else ...[
              const Text('• Check your internet connection'),
              const Text('• Ensure you\'re signed in to Google'),
              const Text('• Check Google Drive permissions'),
              const Text('• Try signing out and back into Google'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (_showRetryButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manualSync();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final switchTitle = isIOS ? 'iCloud Sync' : 'Google Drive Sync';
    final switchSubtitle = isIOS
        ? 'Backup your cards to iCloud Drive'
        : 'Backup your cards to Google Drive';

    return Column(
      children: [
        // Cloud Sync Toggle
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cloudSyncService.cloudEnabled
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                  : (isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIOS ? Icons.cloud_rounded : Icons.cloud_done_rounded,
              color: _cloudSyncService.cloudEnabled
                  ? const Color(0xFF3B82F6)
                  : (isDark ? Colors.white70 : Colors.grey[700]),
              size: 24,
            ),
          ),
          title: Text(
            switchTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            switchSubtitle,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Switch(
            value: _cloudSyncService.cloudEnabled,
            onChanged: _toggleCloud,
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          ),
        ),

        // User Email (if signed in)
        if (_cloudSyncService.cloudEnabled &&
            _cloudSyncService.currentUserEmail != null) ...[
          Divider(
            height: 1,
            indent: 70,
            endIndent: 20,
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: isDark ? Colors.white70 : Colors.grey[700],
                size: 24,
              ),
            ),
            title: Text(
              'Account',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _cloudSyncService.currentUserEmail!,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],

        // Sync Status and Manual Sync
        if (_cloudSyncService.cloudEnabled) ...[
          Divider(
            height: 1,
            indent: 70,
            endIndent: 20,
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _syncing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white70 : Colors.grey[700]!,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.sync_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      size: 24,
                    ),
            ),
            title: Text(
              'Sync Status',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: GestureDetector(
              onTap: _status.contains('failed') || _status.contains('error')
                  ? _showErrorDetails
                  : null,
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.contains('failed') || _status.contains('error')
                      ? const Color(0xFFEF4444)
                      : (isDark ? Colors.white60 : Colors.grey[600]),
                  fontSize: 14,
                  decoration:
                      _status.contains('failed') || _status.contains('error')
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
            trailing: !_syncing
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      onPressed: _manualSync,
                      tooltip: 'Manual sync',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ],
    );
  }
}
