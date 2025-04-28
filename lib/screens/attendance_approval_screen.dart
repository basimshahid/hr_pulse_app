import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceApprovalScreen extends StatefulWidget {
  const AttendanceApprovalScreen({super.key});

  @override
  State<AttendanceApprovalScreen> createState() =>
      _AttendanceApprovalScreenState();
}

class _AttendanceApprovalScreenState extends State<AttendanceApprovalScreen> {
  bool showApproved = false;
  Map<String, dynamic> usersMap = {};

  Future<Map<String, dynamic>> fetchUsers() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    return {for (var doc in users.docs) doc.id: doc.data()};
  }

  Future<void> updateApproval(String docId, bool approve) async {
    await FirebaseFirestore.instance.collection('attendance').doc(docId).update(
      {'approved': approve},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Approve Attendance")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUsers(),
        builder: (context, userSnap) {
          if (!userSnap.hasData)
            return Center(child: CircularProgressIndicator());

          usersMap = userSnap.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Showing: ${showApproved ? "Approved" : "Pending"}",
                      style: theme.textTheme.titleMedium,
                    ),
                    Switch(
                      value: showApproved,
                      onChanged: (val) => setState(() => showApproved = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('attendance')
                          .where('approved', isEqualTo: showApproved)
                          .orderBy('date', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No ${showApproved ? 'approved' : 'pending'} records found.",
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final userId = doc['userId'];
                        final status = doc['status'];
                        final date = doc['date'];

                        final user = usersMap[userId];
                        final name =
                            user != null ? user['fullName'] : "Unknown";

                        return Card(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: theme.textTheme.titleMedium),
                                SizedBox(height: 8),
                                Text("Status: ${status.toUpperCase()}"),
                                Text("Date: $date"),
                                if (!showApproved) ...[
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        // style: ElevatedButton.styleFrom(
                                        //   backgroundColor: Colors.red,
                                        // ),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        label: Text("Cancel"),
                                        onPressed: () async {
                                          bool confirm = await showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Cancel Confirmation',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to cancel this attendance request?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text('Yes'),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (confirm) {
                                            await FirebaseFirestore.instance
                                                .collection('attendance')
                                                .doc(doc.id)
                                                .delete();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Request canceled successfully',
                                                ),
                                              ),
                                            );
                                          }
                                        },

                                        //     () => updateApproval(doc.id, false),
                                        // tooltip: "Reject",
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => updateApproval(doc.id, true),
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        label: Text("Approve"),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
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
