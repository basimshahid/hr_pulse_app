import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hr_pulse_app/service/notification.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final String markedByUserId;

  AttendanceMarkingScreen({required this.markedByUserId});

  @override
  _AttendanceMarkingScreenState createState() =>
      _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  List<String> selectedUserIds = [];
  List<DateTime> selectedDates = [];
  String selectedStatus = 'present';
  String? selectedLeaveType;
  bool loading = false;
  List<QueryDocumentSnapshot> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = snapshot.docs;
    });
  }

  Future<void> pickDates(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!selectedDates.contains(pickedDate)) {
        setState(() {
          selectedDates.add(pickedDate);
        });
      }
    }
  }

  // Future<void> pickDates() async {
  //   final now = DateTime.now();
  //   final picked = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(now.year - 1),
  //     lastDate: DateTime(now.year + 1),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       selectedDates = List.generate(
  //         picked.end.difference(picked.start).inDays + 1,
  //         (index) => picked.start.add(Duration(days: index)),
  //       );
  //     });
  //   }
  // }

  List<String> getFormattedDates() {
    return selectedDates
        .map(
          (date) =>
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        )
        .toList();
  }

  Future<void> submitAttendance() async {
    if (selectedUserIds.isEmpty ||
        selectedDates.isEmpty ||
        selectedStatus == 'leave' && selectedLeaveType == null) {
      // showTopSnackBar(
      //   Overlay.of(context),
      //   CustomSnackBar.success(
      //     message: "Please fill all required fields",
      //     textStyle: TextStyle(fontSize: 16, color: Colors.white),
      //     backgroundColor: Colors.black54,
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);
    final firestore = FirebaseFirestore.instance;
    final dates = getFormattedDates();

    for (var uid in selectedUserIds) {
      for (var date in dates) {
        final record = {
          'userId': uid,
          'date': date,
          'status': selectedStatus == 'leave' ? 'onLeave' : selectedStatus,
          'approved': false,
          'markedBy': widget.markedByUserId,
        };

        if (selectedStatus == 'leave') {
          record['leaveType'] = selectedLeaveType!;
          final userRef = firestore.collection('users').doc(uid);
          final userDoc = await userRef.get();
          final leave = Map<String, dynamic>.from(userDoc['leaveBalance']);
          leave['annual'] = (leave['annual'] ?? 0) - 1;
          leave[selectedLeaveType!] = (leave[selectedLeaveType!] ?? 0) - 1;
          await userRef.update({'leaveBalance': leave});

          await checkLeaveBalanceAndNotify(uid, 2);
        }

        if (selectedStatus == 'late') {
          final userRef = firestore.collection('users').doc(uid);
          final userDoc = await userRef.get();
          final currentLate = userDoc['lateCount'] ?? 0;
          await userRef.update({'lateCount': currentLate + 1});

          await checkLatenessAndNotify(uid, 5);
        }

        await firestore.collection('attendance').add(record);
      }
    }

    setState(() {
      loading = false;
      selectedUserIds.clear();
      selectedDates.clear();
      selectedStatus = 'present';
      selectedLeaveType = null;
    });

    // showTopSnackBar(
    //   Overlay.of(context),
    //   CustomSnackBar.success(
    //     messagePadding: EdgeInsets.symmetric(horizontal: 10),
    //     message: "Attendance marked successfully",
    //     textStyle: TextStyle(fontSize: 16, color: Colors.white),
    //     backgroundColor: Colors.black54,
    //   ),
    // );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Attendance marked successfully.")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance")),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Employees",
                      style: theme.textTheme.titleMedium,
                    ),
                    Wrap(
                      spacing: 10,
                      children:
                          users.map((user) {
                            final isSelected = selectedUserIds.contains(
                              user.id,
                            );
                            return FilterChip(
                              label: Text(user['fullName']),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedUserIds.add(user.id);
                                  } else {
                                    selectedUserIds.remove(user.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 30),

                    Text("Select Dates", style: theme.textTheme.titleMedium),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => pickDates(context),
                      icon: Icon(Icons.date_range),
                      label: Text("Pick Date(s)"),
                    ),
                    if (selectedDates.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 4,
                          children:
                              selectedDates.map((date) {
                                return Chip(
                                  deleteIcon: Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      selectedDates.remove(date);
                                    });
                                  },
                                  label: Text(
                                    '${date.day}-${date.month}-${date.year}',
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    SizedBox(height: 30),

                    Text(
                      "Attendance Status",
                      style: theme.textTheme.titleMedium,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(),
                      items:
                          ['present', 'late', 'leave']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() {
                            selectedStatus = val!;
                            selectedLeaveType = null;
                          }),
                    ),

                    if (selectedStatus == 'leave') ...[
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedLeaveType,
                        decoration: InputDecoration(labelText: "Leave Type"),
                        items:
                            ['sick', 'withoutPay']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedLeaveType = val),
                      ),
                    ],
                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: submitAttendance,
                        icon: Icon(Icons.check),
                        label: Text("Submit Attendance"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
