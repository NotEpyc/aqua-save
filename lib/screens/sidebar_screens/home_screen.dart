import 'package:aquasave/screens/sidebar_screens/leak_detection_screen.dart';
import 'package:aquasave/screens/sidebar_screens/water_analytics_screen.dart';
import 'package:aquasave/screens/login_screen/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/theme/theme.dart';
import 'package:aquasave/screens/sidebar_screens/settings_screen.dart';
import 'package:aquasave/screens/sidebar_screens/notifications_screen.dart';
import 'package:aquasave/screens/sidebar_screens/billing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        return const Center(child: Text('Please sign in'));
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize test data if needed
    initializeTestData();
  }

  Future<void> initializeTestData() async {
    try {
      final snapshot = await _database.get();
      
      if (!snapshot.exists) {
        await _database.set({
          'test_connection': 'ESP32 Connected',
          'water_management': {
            'master_flowmeter': {
              'flow_rate': 0.0,
              'total_usage': 0.0
            },
            'room_1': {
              'flow_rate': 0.0,
              'total_usage': 0.0,
              'usage': {
                'daily_usage': [],
                'weekly_usage': [],
                'monthly_usage': []
              }
            },
            'room_2': {
              'flow_rate': 0.0,
              'total_usage': 0.0,
              'usage': {
                'daily_usage': [],
                'weekly_usage': [],
                'monthly_usage': []
              }
            }
          },
          'notifications': {
            'welcome': {
              'title': 'Welcome to AquaSave',
              'message': 'You will receive notifications about leaks and water usage here.',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'type': 'info',
              'is_read': false,
            }
          }
        });
        print('Test data initialized with notifications');
      }
    } catch (e) {
      print('Error initializing test data: $e');
    }
  }

  Widget _buildDrawerHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/app_icon.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              const Text(
                'AquaSave',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (user != null) // Only show user info if logged in
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: lightColorScheme.primary,
                  radius: 20,
                  child: Text(
                    user?.email?[0].toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: lightColorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: lightColorScheme.onSurface,
                      fontSize: 12, // Reduced from 14 to 12
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_selectedIndex) {
          0 => 'Dashboard',
          1 => 'Water Analytics',
          2 => 'Leak Detection',
          3 => 'Billing',
          4 => 'Settings',
          _ => 'Dashboard',
        }),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 16),
          // Navigation items
          NavigationDrawerDestination(
            icon: const Icon(Icons.dashboard),
            label: const Text('Dashboard'),
            selectedIcon: Icon(Icons.dashboard, color: lightColorScheme.primary),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.water),
            label: const Text('Water Analytics'),
            selectedIcon: Icon(Icons.water, color: lightColorScheme.primary),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.warning),
            label: const Text('Leak Detection'),
            selectedIcon: Icon(Icons.warning, color: lightColorScheme.primary),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.receipt),
            label: const Text('Billing'),
            selectedIcon: Icon(Icons.receipt, color: lightColorScheme.primary),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
            selectedIcon: Icon(Icons.settings, color: lightColorScheme.primary),
          ),
          // Container for bottom section with logout
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: lightColorScheme.error,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: lightColorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const WaterAnalyticsScreen();
      case 2:
        return const LeakDetectionScreen();
      case 3:
        return BillingScreen();
      case 4:
        return const SettingsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return StreamBuilder<DatabaseEvent>(
      // Update the stream to listen to root level
      stream: _database.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Database Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        try {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('No data available'));
          }

          final dynamic rawData = snapshot.data!.snapshot.value;
          print('Raw data: $rawData'); // Debug print

          if (rawData == null || !(rawData is Map)) {
            return const Center(child: Text('Invalid data format'));
          }

          final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
          
          // Access water_management directly from root
          if (!data.containsKey('water_management')) {
            return const Center(child: Text('No water management data available'));
          }

          final Map<String, dynamic> waterManagement = 
              Map<String, dynamic>.from(data['water_management']);

          // Get connection status from root level
          final String connectionStatus = data['test_connection'] ?? 'Disconnected';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status
                Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      Icons.wifi,
                      color: connectionStatus == 'ESP32 Connected' 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    title: const Text('ESP32 Status'),
                    subtitle: Text(connectionStatus),
                  ),
                ),
                const SizedBox(height: 20),

                // User Profile Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: lightColorScheme.primary,
                              radius: 30,
                              child: Text(
                                user?.email?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.email ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Water Usage Statistics
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Water Usage Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Icon(Icons.water_drop,
                              color: lightColorScheme.primary),
                          title: const Text('Master Flow Rate'),
                          trailing: Text(
                            '${(waterManagement['master_flowmeter'] as Map<dynamic, dynamic>?)?['flow_rate']?.toString() ?? '0'} L/min',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.show_chart,
                              color: lightColorScheme.primary),
                          title: const Text('Total Usage'),
                          trailing: Text(
                            '${(waterManagement['master_flowmeter'] as Map<dynamic, dynamic>?)?['total_usage']?.toString() ?? '0'} L',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Room Status
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Room Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...['room_1', 'room_2'].map((room) {
                          final roomData = waterManagement[room] as Map<dynamic, dynamic>?;
                          final valveStatus = (waterManagement['solenoid_valves'] as Map<dynamic, dynamic>?)?['${room}_valve'] as String? ?? 'OFF';
                          
                          return ListTile(
                            leading: Icon(
                              valveStatus == 'ON' ? Icons.check_circle : Icons.cancel,
                              color: valveStatus == 'ON' ? Colors.green : Colors.red,
                            ),
                            title: Text('Room ${room.split('_')[1]}'),
                            trailing: Text(
                              '${roomData?['flow_rate']?.toString() ?? '0'} L/min',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Data Processing Error: $e');
          return Center(child: Text('Error processing data: $e'));
        }
      },
    );
  }
}
