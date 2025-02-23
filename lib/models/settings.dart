import 'package:firebase_database/firebase_database.dart';

class Settings {
  final double leakThreshold;
  final bool notificationsEnabled;
  final Map<String, bool> valveControls;

  Settings({
    required this.leakThreshold,
    required this.notificationsEnabled,
    required this.valveControls,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    final defaultValveControls = {
      'master_valve': false,
      'room_1_valve': false,
      'room_2_valve': false,
    };

    return Settings(
      leakThreshold: (json['leak_threshold'] as num?)?.toDouble() ?? 10.0,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      valveControls: Map<String, bool>.from(json['valve_controls'] ?? defaultValveControls),
    );
  }

  Map<String, dynamic> toJson() => {
    'leak_threshold': leakThreshold,
    'notifications_enabled': notificationsEnabled,
    'valve_controls': valveControls,
  };

  // Add method to update valve state in database
  Future<void> updateValveState(String valveId, bool isOn) async {
    try {
      final ref = FirebaseDatabase.instance.ref();
      
      // Update valve state in water_management
      await ref
          .child('water_management/solenoid_valves/$valveId')
          .set(isOn ? 'ON' : 'OFF');
      
      // Update valve state in settings
      await ref
          .child('settings/valve_controls/$valveId')
          .set(isOn);
          
      print('Valve state updated: $valveId -> ${isOn ? 'ON' : 'OFF'}');
    } catch (e) {
      print('Error updating valve state: $e');
      rethrow;
    }
  }

  // Add method to get valve state
  bool getValveState(String valveId) {
    return valveControls[valveId] ?? false;
  }
}