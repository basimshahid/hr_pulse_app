import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final String userId;

  const EmployeeProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Employee Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final user = snapshot.data!;
          final name = user['fullName'];
          final email = user['email'];
          final empNo = user['employeeNumber'];
          final dept = user['department'];
          final role = user['role'];
          final late = user['lateCount'];
          final leave = Map<String, dynamic>.from(user['leaveBalance']);
          final benefits = Map<String, dynamic>.from(user['benefits']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text(name, style: theme.textTheme.headlineLarge),
                Text(email, style: theme.textTheme.bodyMedium),
                SizedBox(height: 8),
                Text("Employee #: $empNo", style: theme.textTheme.labelLarge),

                SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          "Role",
                          role.toUpperCase(),
                          Icons.work_outline,
                        ),
                        Divider(),
                        _infoRow("Department", dept, Icons.apartment_outlined),
                        Divider(),
                        _infoRow("Late Count", "$late", Icons.alarm),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Text("Leave Balance", style: theme.textTheme.titleMedium),
                SizedBox(height: 4),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          "Annual",
                          "${leave['annual']} days",
                          Icons.date_range,
                        ),
                        Divider(),
                        _infoRow(
                          "Sick",
                          "${leave['sick']} days",
                          Icons.healing_outlined,
                        ),
                        Divider(),
                        _infoRow(
                          "Without Pay",
                          "${leave['withoutPay']} days",
                          Icons.money_off,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Text("Benefits", style: theme.textTheme.titleMedium),
                SizedBox(height: 4),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Health Insurance',
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(width: 8),
                            benefits['healthInsurance'] == true
                                ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                                : Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                        if (benefits['otherBenefit'] != null &&
                            benefits['otherBenefit']
                                .toString()
                                .trim()
                                .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4),
                            child: Text(
                              "Other: ${benefits['otherBenefit']}",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 12),
        Text("$title:", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
