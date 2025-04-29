import 'package:flutter/material.dart';
import 'package:hr_pulse_app/screens/add_user_screen.dart';
import 'package:hr_pulse_app/screens/attendance_approval_screen.dart';
import 'package:hr_pulse_app/screens/attendance_marking_screen.dart';
import 'package:hr_pulse_app/screens/employee_dashboard_screen.dart';
import 'package:hr_pulse_app/screens/employee_directory_screen.dart';
import 'package:hr_pulse_app/screens/files_claim_screen.dart';
import 'package:hr_pulse_app/screens/login_screen.dart';
import 'package:hr_pulse_app/screens/overview_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String role;

  const HomeScreen({super.key, required this.userId, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double itemWidth = (screenSize.width / 2) - 30;
    final double itemHeight = itemWidth * 1;
    final theme = Theme.of(context);

    List<Map<String, dynamic>> options = [];

    void logoutUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => LoginScreen()),
      );
    }

    if (widget.role == 'admin') {
      options = [
        {
          'icon': Icons.event_available_outlined,
          'label': 'Mark Attendance',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AttendanceMarkingScreen(
                        markedByUserId: widget.userId,
                      ),
                ),
              ),
        },
        {
          'icon': Icons.verified_outlined,
          'label': 'Approve Attendance',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendanceApprovalScreen()),
              ),
        },
        {
          'icon': Icons.people,
          'label': 'Employee Directory',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmployeeDirectoryScreen()),
              ),
        },
        {
          'icon': Icons.bar_chart_outlined,
          'label': 'Overview Dashboard',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OverviewDashboardScreen()),
              ),
        },
        {
          'icon': Icons.dashboard_customize_outlined,
          'label': 'My Dashboard',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EmployeeDashboardScreen(userId: widget.userId),
                ),
              ),
        },
        {
          'icon': Icons.person_add,
          'label': 'Add User',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddUserScreen()),
              ),
        },
        {
          'icon': Icons.assignment_turned_in_outlined,
          'label': 'Claims Filed',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FilesClaimScreen()),
              ),
        },
      ];
    } else if (widget.role == 'hr') {
      options = [
        {
          'icon': Icons.event_available_outlined,
          'label': 'Mark Attendance',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AttendanceMarkingScreen(
                        markedByUserId: widget.userId,
                      ),
                ),
              ),
        },
        {
          'icon': Icons.verified_outlined,
          'label': 'Approve Attendance',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendanceApprovalScreen()),
              ),
        },
        {
          'icon': Icons.people,
          'label': 'Employee Directory',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmployeeDirectoryScreen()),
              ),
        },
        {
          'icon': Icons.bar_chart_outlined,
          'label': 'Overview Dashboard',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OverviewDashboardScreen()),
              ),
        },
        {
          'icon': Icons.dashboard_customize_outlined,
          'label': 'My Dashboard',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EmployeeDashboardScreen(userId: widget.userId),
                ),
              ),
        },
      ];
    } else {
      options = [
        {
          'icon': Icons.dashboard_customize_outlined,
          'label': 'My Dashboard',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EmployeeDashboardScreen(userId: widget.userId),
                ),
              ),
        },
        {
          'icon': Icons.people,
          'label': 'Employee Directory',
          'onTap':
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmployeeDirectoryScreen()),
              ),
        },
      ];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('HR Pulse Dashboard')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenSize.width < 600 ? 2 : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: option['onTap'],
                    child: Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              option['icon'],
                              size: 48,
                              color:theme.colorScheme.primary,
                               // Colors.blueGrey.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              option['label'],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 240,
              child: ElevatedButton.icon(
                onPressed: logoutUser,
                icon: Icon(Icons.login),
                label: Text("Logout"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
