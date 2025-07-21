import 'package:flutter/material.dart';

class ICloudSyncSection extends StatefulWidget {
  const ICloudSyncSection({Key? key}) : super(key: key);

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
    final tileBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.04)
        : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_rounded),
            title: const Text('iCloud Sync'),
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable iCloud Sync'),
            value: _icloudEnabled,
            onChanged: _toggleICloud,
            secondary: const Icon(Icons.sync_rounded),
            tileColor: tileBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
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
                Text(_status, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
