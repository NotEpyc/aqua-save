import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  double _leakThreshold = 10.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _database.child('settings').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = _parseSettings(snapshot.data?.snapshot.value);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeakThresholdSection(settings),
                const SizedBox(height: 20),
                _buildNotificationsSection(settings),
                const SizedBox(height: 20),
                _buildValveControlSection(settings),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _database.child('settings/leak_threshold').set(_leakThreshold);
                    }
                  },
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Settings _parseSettings(dynamic data) {
    if (data is Map) {
      return Settings.fromJson(Map<String, dynamic>.from(data));
    }
    return Settings(
      leakThreshold: 10.0,
      notificationsEnabled: true,
      valveControls: {
        'master_valve': false,
        'room_1_valve': false,
        'room_2_valve': false,
        'room_3_valve': false,
      },
    );
  }

  Widget _buildLeakThresholdSection(Settings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leak Detection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: settings.leakThreshold.toString(),
              decoration: const InputDecoration(
                labelText: 'Leak Threshold (L/min)',
                helperText: 'Flow difference that triggers leak detection',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a threshold value';
                }
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
              onSaved: (value) {
                _leakThreshold = double.parse(value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(Settings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get alerts for leaks and high usage'),
              value: settings.notificationsEnabled,
              onChanged: (bool value) {
                _database.child('settings/notifications_enabled').set(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValveControlSection(Settings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual Valve Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...['master', 'room_1', 'room_2'].map((valve) {
              final valveId = '${valve}_valve';
              return SwitchListTile(
                title: Text(valve == 'master' 
                  ? 'Master Valve' 
                  : 'Room ${valve.split('_')[1]} Valve'
                ),
                value: settings.getValveState(valveId),
                onChanged: (bool value) async {
                  try {
                    await settings.updateValveState(valveId, value);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update valve: $e')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}