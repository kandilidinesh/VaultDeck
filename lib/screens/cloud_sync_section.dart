import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class CloudSyncSection extends StatefulWidget {
  const CloudSyncSection({super.key});

  @override
  State<CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends State<CloudSyncSection> {
  bool _cloudEnabled = false;
  bool _syncing = false;
  String _status = 'Not synced';

  void _toggleCloud(bool value) {
    setState(() {
      _cloudEnabled = value;
      if (value) {
        _syncWithCloud();
      } else {
        _status = Platform.isIOS
            ? 'iCloud sync disabled'
            : 'Google Drive sync disabled';
      }
    });
  }

  Future<void> _syncWithCloud() async {
    setState(() {
      _syncing = true;
      _status = 'Syncing...';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _syncing = false;
      _status = 'Last synced: just now';
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
                    Text(_status, style: Theme.of(context).textTheme.bodySmall),
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
