import 'package:flutter/material.dart';

class ICloudSyncSection extends StatefulWidget {
  const ICloudSyncSection({super.key});

  @override
  State<ICloudSyncSection> createState() => _ICloudSyncSectionState();
}

class _ICloudSyncSectionState extends State<ICloudSyncSection> {
  bool _icloudEnabled = false;
  bool _syncing = false;
  String _status = 'Not synced';

  void _toggleICloud(bool value) {
    setState(() {
      _icloudEnabled = value;
      if (value) {
        _syncWithICloud();
      } else {
        _status = 'iCloud sync disabled';
      }
    });
  }

  Future<void> _syncWithICloud() async {
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
                'iCloud Sync',
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
                title: const Text('Enable iCloud Sync'),
                value: _icloudEnabled,
                onChanged: _toggleICloud,
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
