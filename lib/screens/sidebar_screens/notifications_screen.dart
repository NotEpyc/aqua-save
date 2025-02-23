import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/notification.dart';
import 'package:aquasave/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all as read
              FirebaseDatabase.instance
                  .ref()
                  .child('notifications')
                  .get()
                  .then((snapshot) {
                if (snapshot.value != null) {
                  final data = snapshot.value as Map<dynamic, dynamic>;
                  data.forEach((key, _) {
                    FirebaseDatabase.instance
                        .ref()
                        .child('notifications/$key/is_read')
                        .set(true);
                  });
                }
              });
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref()
            .child('notifications')
            .orderByChild('timestamp')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = <WaterNotification>[];
          
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            data.forEach((key, value) {
              if (value is Map<dynamic, dynamic>) {
                notifications.add(WaterNotification.fromJson(
                  key.toString(),
                  Map<String, dynamic>.from(value),
                ));
              }
            });

            // Add null checks and safe access to flow data
            try {
              final masterFlowmeter = data['master_flowmeter'] as Map<dynamic, dynamic>?;
              final masterFlow = masterFlowmeter?['flow_rate'] != null 
                  ? (masterFlowmeter!['flow_rate'] as num).toDouble() 
                  : 0.0;
              final totalConsumption = masterFlowmeter?['total_usage'] != null 
                  ? (masterFlowmeter!['total_usage'] as num).toDouble() 
                  : 0.0;
              
              final roomFlows = <String, double>{};
              
              // Safely access room flow rates
              if (data['room_1'] is Map) {
                roomFlows['room_1'] = ((data['room_1'] as Map)['flow_rate'] as num?)?.toDouble() ?? 0.0;
              }
              if (data['room_2'] is Map) {
                roomFlows['room_2'] = ((data['room_2'] as Map)['flow_rate'] as num?)?.toDouble() ?? 0.0;
              }

              // Only call notification service if we have valid data
              NotificationService.checkAndCreateNotifications(
                masterFlow: masterFlow,
                totalConsumption: totalConsumption,
                roomFlows: roomFlows,
              );
            } catch (e) {
              print('Error processing flow data: $e');
              // Optionally show error in UI or handle differently
            }
          }

          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) => 
              _buildNotificationCard(context, notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, 
    WaterNotification notification
  ) {
    final Icon icon;
    final Color color;

    switch (notification.type) {
      case NotificationType.leak:
        icon = const Icon(Icons.warning, color: Colors.red);
        color = Colors.red.withOpacity(0.1);
        break;
      case NotificationType.usage:
        icon = Icon(Icons.water_drop, color: Colors.blue[700]);
        color = Colors.blue.withOpacity(0.1);
        break;
      case NotificationType.valve:
        icon = const Icon(Icons.settings, color: Colors.orange);
        color = Colors.orange.withOpacity(0.1);
        break;
      case NotificationType.info:
        icon = Icon(Icons.info, color: Colors.grey[700]);
        color = Colors.grey.withOpacity(0.1);
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: notification.isRead ? null : color,
        leading: icon,
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, y HH:mm').format(notification.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            FirebaseDatabase.instance
                .ref()
                .child('notifications/${notification.id}/is_read')
                .set(true);
          }
        },
      ),
    );
  }
}