import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

enum NotificationType {
  leak,
  usage,
  valve,
  info,
}

class WaterNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  WaterNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  factory WaterNotification.fromJson(String id, Map<String, dynamic> json) {
    return WaterNotification(
      id: id,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.info,
      ),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'type': type.toString().split('.').last,
    'is_read': isRead,
  };

  static Future<void> checkAndCreateNotifications({
    required double masterFlow,
    required double totalConsumption,
    required Map<String, double> roomFlows,
    double leakThreshold = 0.5,
    double highConsumptionThreshold = 1000.0, // 1000L threshold
  }) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('notifications');
      final now = DateTime.now();

      // Check for leaks
      final totalRoomFlow = roomFlows.values.fold<double>(0, (sum, flow) => sum + flow);
      final flowDifference = (masterFlow - totalRoomFlow).abs();
      
      if (flowDifference > leakThreshold && masterFlow > 0) {
        await ref.push().set(WaterNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Potential Leak Detected',
          message: 'Flow difference of ${flowDifference.toStringAsFixed(2)} L/min detected. Please check your plumbing system.',
          timestamp: now,
          type: NotificationType.leak,
        ).toJson());
      }

      // Check total consumption
      if (totalConsumption > highConsumptionThreshold) {
        await ref.push().set(WaterNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'High Water Consumption',
          message: 'Total consumption has reached ${totalConsumption.toStringAsFixed(0)}L. Consider water conservation measures.',
          timestamp: now,
          type: NotificationType.usage,
        ).toJson());
      }

      // Clean old notifications (keep last 30 days)
      await _cleanOldNotifications(30);
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  static Future<void> _cleanOldNotifications(int daysToKeep) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('notifications');
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final snapshot = await ref.get();
      if (snapshot.value != null) {
        final notifications = snapshot.value as Map<dynamic, dynamic>;
        notifications.forEach((key, value) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(value['timestamp'] as int);
          if (timestamp.isBefore(cutoffDate)) {
            ref.child(key).remove();
          }
        });
      }
    } catch (e) {
      print('Error cleaning notifications: $e');
    }
  }
}

// Example usage in your StreamBuilder where you process flow data
void processFlowData(AsyncSnapshot snapshot) async {
  if (snapshot.hasData) {
    final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
    final masterFlow = (data['master_flowmeter']['flow_rate'] as num).toDouble();
    final totalConsumption = (data['master_flowmeter']['total_usage'] as num).toDouble();
    
    final roomFlows = <String, double>{
      'room_1': (data['room_1']['flow_rate'] as num).toDouble(),
      'room_2': (data['room_2']['flow_rate'] as num).toDouble(),
    };

    // Check for notifications
    await WaterNotification.checkAndCreateNotifications(
      masterFlow: masterFlow,
      totalConsumption: totalConsumption,
      roomFlows: roomFlows,
      leakThreshold: 0.5, // 0.5 L/min difference threshold
      highConsumptionThreshold: 1000.0, // 1000L consumption threshold
    );

    // ... rest of your code ...
  }
}