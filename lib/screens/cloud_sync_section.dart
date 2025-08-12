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
          _status = 'Successfully synced ${_cloudSyncService.getCardCount()} cards!';
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
          _status = 'Successfully synced ${_cloudSyncService.getCardCount()} cards!';
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
    final tileBg = isDark ? const Color(0xFF23262F) : Colors.white;
    final isIOS = Platform.isIOS;
    final switchTitle = isIOS
        ? 'Enable iCloud Sync'
        : 'Enable Google Drive Sync';
    final screenWidth = MediaQuery.of(context).size.width;
    
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
        Center(
          child: Container(
            width: screenWidth > 500 ? 500 : screenWidth * 0.98,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      switchTitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  value: _cloudSyncService.cloudEnabled,
                  onChanged: _toggleCloud,
                  secondary: const Icon(Icons.sync_rounded),
                  tileColor: tileBg,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                if (_cloudSyncService.cloudEnabled && _cloudSyncService.currentUserEmail != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Signed in as: ${_cloudSyncService.currentUserEmail}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
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
                        child: GestureDetector(
                          onTap: _status.contains('failed') || _status.contains('error') 
                              ? _showErrorDetails 
                              : null,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _status,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _status.contains('failed') || _status.contains('error')
                                    ? Colors.red
                                    : null,
                                decoration: _status.contains('failed') || _status.contains('error')
                                    ? TextDecoration.underline
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      if (_cloudSyncService.cloudEnabled && !_syncing)
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _manualSync,
                          tooltip: 'Manual sync',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
