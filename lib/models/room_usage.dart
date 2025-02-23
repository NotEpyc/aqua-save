import 'package:firebase_database/firebase_database.dart';

class RoomUsage {
  final String roomId;
  final List<UsageData> dailyUsage;
  final List<UsageData> weeklyUsage;
  final List<UsageData> monthlyUsage;
  final bool valveStatus; // Add valve status

  RoomUsage({
    required this.roomId,
    required this.dailyUsage,
    required this.weeklyUsage,
    required this.monthlyUsage,
    this.valveStatus = false, // Default to closed
  });

  // Add methods to calculate weekly and monthly usage
  List<UsageData> calculateWeeklyUsage() {
    if (dailyUsage.isEmpty) return [];
    
    // Sort daily usage by timestamp
    final sorted = List<UsageData>.from(dailyUsage)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group by week
    final Map<int, double> weeklyMap = {};
    for (var usage in sorted) {
      final weekStart = usage.timestamp.subtract(
        Duration(days: usage.timestamp.weekday - 1)
      );
      final weekKey = weekStart.millisecondsSinceEpoch;
      weeklyMap[weekKey] = (weeklyMap[weekKey] ?? 0) + usage.usage;
    }

    return weeklyMap.entries.map((entry) => UsageData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(entry.key),
      usage: entry.value,
    )).toList();
  }

  List<UsageData> calculateMonthlyUsage() {
    if (dailyUsage.isEmpty) return [];
    
    // Sort daily usage by timestamp
    final sorted = List<UsageData>.from(dailyUsage)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group by month
    final Map<int, double> monthlyMap = {};
    for (var usage in sorted) {
      final monthStart = DateTime(
        usage.timestamp.year,
        usage.timestamp.month,
        1
      );
      final monthKey = monthStart.millisecondsSinceEpoch;
      monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + usage.usage;
    }

    return monthlyMap.entries.map((entry) => UsageData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(entry.key),
      usage: entry.value,
    )).toList();
  }

  // Update the factory constructor to use the calculation methods
  factory RoomUsage.fromJson(String roomId, Map<Object?, Object?> json) {
    try {
      print('Incoming json: $json');

      // Parse valve status
      final String? valveState = json['valve_status'] as String?;
      final bool isValveOpen = valveState?.toUpperCase() == 'ON';

      final dailyData = _parseUsageArray(json['daily_usage']);
      final roomUsage = RoomUsage(
        roomId: roomId,
        dailyUsage: dailyData,
        weeklyUsage: [], 
        monthlyUsage: [],
        valveStatus: isValveOpen,
      );

      return RoomUsage(
        roomId: roomId,
        dailyUsage: dailyData,
        weeklyUsage: roomUsage.calculateWeeklyUsage(),
        monthlyUsage: roomUsage.calculateMonthlyUsage(),
        valveStatus: isValveOpen,
      );
    } catch (e, stackTrace) {
      print('Error parsing RoomUsage: $e');
      print('Stack trace: $stackTrace');
      return RoomUsage(
        roomId: roomId,
        dailyUsage: [],
        weeklyUsage: [],
        monthlyUsage: [],
        valveStatus: false,
      );
    }
  }

  // Helper method to parse usage arrays
  static List<UsageData> _parseUsageArray(dynamic rawData) {
    if (rawData == null || rawData is! List) {
      print('No usage data found or invalid format');
      return [];
    }

    return rawData.map((item) {
      if (item is Map<Object?, Object?>) {
        return UsageData.fromJson(Map<String, dynamic>.from(item));
      }
      print('Invalid item format: $item');
      return UsageData(timestamp: DateTime.now(), usage: 0.0);
    }).toList();
  }

  // Add method to toggle valve
  Future<void> toggleValve(bool newState) async {
    try {
      final ref = FirebaseDatabase.instance.ref();
      final String valveId = roomId == 'master' ? 'master_valve' : '${roomId}_valve';
      await ref.child('water_management/solenoid_valves/$valveId').set(newState ? 'ON' : 'OFF');
    } catch (e) {
      print('Error toggling valve: $e');
      rethrow;
    }
  }
}

class UsageData {
  final DateTime timestamp;
  final double usage;

  UsageData({
    required this.timestamp,
    required this.usage,
  });

  factory UsageData.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing UsageData: $json');
      return UsageData(
        timestamp: json['timestamp'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
        usage: (json['usage'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error parsing UsageData: $e');
      return UsageData(
        timestamp: DateTime.now(),
        usage: 0.0,
      );
    }
  }
}