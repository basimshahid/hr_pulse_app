import 'package:flutter/material.dart';
import 'package:hr_pulse_app/screens/add_user_screen.dart';
import 'package:hr_pulse_app/screens/attendance_approval_screen.dart';
import 'package:hr_pulse_app/screens/attendance_marking_screen.dart';
import 'package:hr_pulse_app/screens/employee_dashboard_screen.dart';
import 'package:hr_pulse_app/screens/employee_directory_screen.dart';
import 'package:hr_pulse_app/screens/login_screen.dart';
import 'package:hr_pulse_app/screens/overview_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class HomeScreen extends StatelessWidget {
//   final String userId;
//   final String role;

//   const HomeScreen({super.key, required this.userId, required this.role});

//   @override
//   Widget build(BuildContext context) {
//     void logoutUser() {
//       // Implement your logout logic here
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (ctx) => LoginScreen()),
//       );
//     }

//     final List<_HomeCard> modules = [
//       if (role == 'admin')
//         _HomeCard(
//           title: 'Add User',
//           icon: Icons.person_add,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => AddUserScreen()),
//               ),
//         ),
//       if (role == 'admin' || role == 'hr' || role == 'employee')
//         _HomeCard(
//           title: 'Employee Directory',
//           icon: Icons.people_alt_outlined,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => EmployeeDirectoryScreen()),
//               ),
//         ),
//       if (role == 'admin' || role == 'hr')
//         _HomeCard(
//           title: 'Mark Attendance',
//           icon: Icons.event_available_outlined,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => AttendanceMarkingScreen(markedByUserId: userId),
//                 ),
//               ),
//         ),
//       if (role == 'admin' || role == 'hr')
//         _HomeCard(
//           title: 'Approve Attendance',
//           icon: Icons.verified_outlined,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => AttendanceApprovalScreen()),
//               ),
//         ),
//       if (role == 'admin' || role == 'hr')
//         _HomeCard(
//           title: 'Company Overview',
//           icon: Icons.bar_chart_outlined,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => OverviewDashboardScreen()),
//               ),
//         ),
//       if (role == 'admin' || role == 'hr')
//         _HomeCard(
//           title: 'Add New User',
//           icon: Icons.person_add,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (ctx) => AddUserScreen()),
//               ),
//         ),
//       _HomeCard(
//         title: 'My Dashboard',
//         icon: Icons.dashboard_customize_outlined,
//         onTap:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => EmployeeDashboardScreen(userId: userId),
//               ),
//             ),
//       ),
//     ];

//     return Scaffold(
//       appBar: AppBar(title: Text("HR Pulse Dashboard")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         //  child: Column(
//         //     children: [
//         //       Expanded(
//         child: GridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 10,
//           childAspectRatio: 1,
//           children: modules.map((m) => m.buildCard(context)).toList(),
//         ),
//       ),
//       //       SizedBox(
//       //             width: double.infinity,
//       //             child: ElevatedButton.icon(
//       //               onPressed: logoutUser,
//       //               icon: Icon(Icons.login),
//       //               label: Text("Logout"),
//       //             ),
//       //           ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }

// class _HomeCard {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   _HomeCard({required this.title, required this.icon, required this.onTap});

//   Widget buildCard(BuildContext context) {
//     final theme = Theme.of(context);
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 48, color: theme.colorScheme.primary),
//                 SizedBox(height: 16),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    final double itemHeight = itemWidth * 0.8;
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
          'label': 'Employee Dashboard',
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
          'label': 'Employee Dashboard',
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
          'label': 'Employee Dashboard',
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                  //itemWidth / itemHeight,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: option['onTap'],
                    child: Card(
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
                              color: Theme.of(context).colorScheme.primary,
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
