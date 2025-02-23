class WaterManagement {
  final FlowMeter masterFlowmeter;
  final Map<String, FlowMeter> rooms;
  final Map<String, String> solenoidValves;  // Add this field

  WaterManagement({
    required this.masterFlowmeter,
    required this.rooms,
    required this.solenoidValves,  // Add to constructor
  });

  factory WaterManagement.fromJson(Map<String, dynamic> json) {
    try {
      return WaterManagement(
        masterFlowmeter: FlowMeter.fromJson(
          Map<String, dynamic>.from(json['master_flowmeter'] ?? {
            'flow_rate': 0.0, 
            'total_usage': 0.0
          })
        ),
        rooms: {
          for (String room in ['room_1', 'room_2', 'room_3'])
            room: FlowMeter.fromJson(
              Map<String, dynamic>.from(json[room] ?? {
                'flow_rate': 0.0, 
                'total_usage': 0.0
              })
            )
        },
        solenoidValves: Map<String, String>.from(json['solenoid_valves'] ?? {
          'master_valve': 'OFF',
          'room_1_valve': 'OFF',
          'room_2_valve': 'OFF',
          'room_3_valve': 'OFF',
        }),
      );
    } catch (e) {
      print('Error parsing WaterManagement: $e');
      rethrow;
    }
  }
}

class WaterAnalytics {
  final FlowMeter masterFlowmeter;
  final Map<String, FlowMeter> rooms;

  WaterAnalytics({
    required this.masterFlowmeter,
    required this.rooms,
  });

  factory WaterAnalytics.fromJson(Map<String, dynamic> json) {
    try {
      return WaterAnalytics(
        masterFlowmeter: FlowMeter.fromJson(
          Map<String, dynamic>.from(json['master_flowmeter'] ?? {
            'flow_rate': 0.0, 
            'total_usage': 0.0
          })
        ),
        rooms: {
          // Remove room_3 from the list
          for (String room in ['room_1', 'room_2'])
            room: FlowMeter.fromJson(
              Map<String, dynamic>.from(json[room] ?? {
                'flow_rate': 0.0, 
                'total_usage': 0.0
              })
            )
        },
      );
    } catch (e) {
      print('Error parsing WaterAnalytics: $e');
      rethrow;
    }
  }
}

class FlowMeter {
  final double flowRate;
  final double totalUsage;

  FlowMeter({
    required this.flowRate,
    required this.totalUsage,
  });

  factory FlowMeter.fromJson(Map<String, dynamic> json) {
    return FlowMeter(
      flowRate: (json['flow_rate'] ?? 0).toDouble(),
      totalUsage: (json['total_usage'] ?? 0).toDouble(),
    );
  }
}