import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilesClaimScreen extends StatelessWidget {
  const FilesClaimScreen({super.key});

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

          final userDocs =
              snapshot.data!.docs.where((doc) {
                final benefits = doc['benefits'] as Map<String, dynamic>;
                final hasHealth = benefits['healthInsurance'] == true;
                final hasOther = benefits['otherBenefit'].toString().trim();
                return hasHealth || (hasOther != null && hasOther.isNotEmpty);
              }).toList();

          if (userDocs.isEmpty) {
            return Center(
              child: Text(
                "No benefits have been claimed yet!",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "Total Claims Filed: ${userDocs.length}",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    final userDoc = userDocs[index];
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
