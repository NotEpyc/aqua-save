import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/notification.dart';

class NotificationService {
  static final _database = FirebaseDatabase.instance.ref();
  static final _notificationsRef = _database.child('notifications');

  static Future<void> checkAndCreateNotifications({
    required double masterFlow,
    required double totalConsumption,
    required Map<String, double> roomFlows,
    double leakThreshold = 0.5,
    double highConsumptionThreshold = 1000.0,
  }) async {
    try {
      final now = DateTime.now();
      final totalRoomFlow = roomFlows.values.fold<double>(0, (sum, flow) => sum + flow);
      final flowDifference = (masterFlow - totalRoomFlow).abs();

      // Check for leaks
      if (flowDifference > leakThreshold && masterFlow > 0) {
        await _createNotification(
          title: 'Potential Leak Detected',
          message: 'Flow difference of ${flowDifference.toStringAsFixed(2)} L/min detected. '
              'Please check your plumbing system.',
          type: NotificationType.leak,
          timestamp: now,
        );
      }

      // Check total consumption
      if (totalConsumption > highConsumptionThreshold) {
        await _createNotification(
          title: 'High Water Consumption',
          message: 'Total consumption has reached ${totalConsumption.toStringAsFixed(0)}L. '
              'Consider water conservation measures.',
          type: NotificationType.usage,
          timestamp: now,
        );
      }

      // Clean old notifications
      await cleanOldNotifications(30);
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  static Future<void> _createNotification({
    required String title,
    required String message,
    required NotificationType type,
    required DateTime timestamp,
  }) async {
    try {
      final notification = WaterNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: timestamp,
        type: type,
      );

      await _notificationsRef.push().set(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  static Future<void> cleanOldNotifications(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final snapshot = await _notificationsRef.get();
      if (snapshot.value != null) {
        final notifications = snapshot.value as Map<dynamic, dynamic>;
        notifications.forEach((key, value) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(value['timestamp'] as int);
          if (timestamp.isBefore(cutoffDate)) {
            _notificationsRef.child(key).remove();
          }
        });
      }
    } catch (e) {
      print('Error cleaning notifications: $e');
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.child(notificationId).update({'is_read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}