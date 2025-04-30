import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilesClaimScreen extends StatefulWidget {
  const FilesClaimScreen({super.key});

  @override
  State<FilesClaimScreen> createState() => _FilesClaimScreenState();
}

class _FilesClaimScreenState extends State<FilesClaimScreen> {
  String selectedDepartment = 'All';
  bool showUnclaimed = false;

   bool _isClaimed(Map<String, dynamic> benefits) {
    final hasHealth = benefits['healthInsurance'] == true;
    final other = benefits['otherBenefit']?.toString().trim();
    return hasHealth || (other != null && other.isNotEmpty);
  }

  List<DocumentSnapshot> _filterByDepartment(List<DocumentSnapshot> docs) {
    if (selectedDepartment == 'All') return docs;
    return docs.where((doc) => doc['department'] == selectedDepartment).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Benefits Utilization")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final allUsers = snapshot.data!.docs;

          final filteredUsers = allUsers.where((doc) {
            final benefits = doc['benefits'] as Map<String, dynamic>;
            final isClaimed = _isClaimed(benefits);
            return showUnclaimed ? !isClaimed : isClaimed;
          }).toList();

          final departments = allUsers.map((doc) => doc['department'] as String).toSet().toList();
          departments.sort();
          departments.insert(0, 'All');

          final displayUsers = _filterByDepartment(filteredUsers);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                        children: [
                          Switch(
                            value: showUnclaimed,
                            onChanged: (val) => setState(() => showUnclaimed = val),
                          ),
                          Text(showUnclaimed ? "Show Claimed" : "Show Unclaimed", 
                          style: theme.textTheme.titleMedium),
                         
                          Spacer(),
                          DropdownButton<String>(
                            value: selectedDepartment,
                            items: departments
                                .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                                .toList(),
                            onChanged: (val) => setState(() => selectedDepartment = val!),
                          ),
                        ],
                      ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                      showUnclaimed
                          ? "Total Without Claims: ${displayUsers.length}"
                          : "Total Benefits Claimed: ${displayUsers.length}",
                      style: theme.textTheme.titleMedium,
                    ),
              ),
              Expanded(
                child: displayUsers.isEmpty
                    ? Center(
                        child: Text(
                          showUnclaimed
                              ? "All users have claimed benefits."
                              : "No user has claimed any benefit yet.",
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : 
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: displayUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = displayUsers[index];
                    final name = userDoc['fullName'] ?? '';
                    final dept = userDoc['department'] ?? '';
                    final benefits = userDoc['benefits'] as Map<String, dynamic>;
                
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(name, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            //Text("Email: $email", style: theme.textTheme.bodySmall),
                            Text(
                              "Department: $dept",
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            const Divider(color: Colors.black, thickness: 1),
                            const Text(
                              "Benefits Utilized:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            if (benefits['healthInsurance'] == false && benefits['otherBenefit'].toString().trim().isEmpty)
                              const Text("None"),
                            if (benefits['healthInsurance'] == true)
                              Row(
                                children: [
                                  Icon(
                                    Icons.health_and_safety,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("Health Insurance"),
                                ],
                              ),
                            if (benefits['otherBenefit'] != null &&
                                benefits['otherBenefit'].toString().trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        benefits['otherBenefit'],
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ), 
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
