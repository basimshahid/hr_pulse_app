import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_pulse_app/screens/employee_profile_screen.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  String searchQuery = '';
  String selectedRole = 'All';
  String selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Employee Directory")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search by name",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  (value) =>
                      setState(() => searchQuery = value.trim().toLowerCase()),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (val) => setState(() => selectedRole = val!),
                  items:
                      ['All', 'admin', 'hr', 'employee']
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text("Role: $r"),
                            ),
                          )
                          .toList(),
                ),
                DropdownButton<String>(
                  value: selectedDepartment,
                  onChanged: (val) => setState(() => selectedDepartment = val!),
                  items:
                      ['All', 'IT', 'HR', 'Sales', 'Finance', 'Operations']
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text("Dept: $d"),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 2),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs =
                    snapshot.data!.docs.where((doc) {
                      final name = doc['fullName'].toString().toLowerCase();
                      final role = doc['role'];
                      final dept = doc['department'];

                      final matchName = name.contains(searchQuery);
                      final matchRole =
                          selectedRole == 'All' || role == selectedRole;
                      final matchDept =
                          selectedDepartment == 'All' ||
                          dept == selectedDepartment;

                      return matchName && matchRole && matchDept;
                    }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No matching employees found.",
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(10),
                  separatorBuilder: (_, __) => SizedBox(height: 4),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index];
                    final name = user['fullName'];
                    final role = user['role'];
                    final dept = user['department'];

                    return Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(name, style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          'Role: $role | Dept: $dept',
                          style: theme.textTheme.titleSmall,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeProfileScreen(userId: user.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
