import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final String userId;

  const EmployeeDashboardScreen({super.key, required this.userId});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int late = 0, present = 0, onLeave = 0, withoutPay = 0;
  Map<String, dynamic> leaveBalance = {};
  Map<String, dynamic> benefits = {};
  String name = "", dept = "", role = "";
  bool loading = true;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> attendanceData;


  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    final attendanceSnap =
        await FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: widget.userId)
            .get();

    int lateCount = 0, presentCount = 0, leaveCount = 0, wopCount = 0;

    for (var entry in attendanceSnap.docs) {
      final status = entry['status'];
      if (status == 'present')
        presentCount++;
      else if (status == 'late')
        lateCount++;
      else if (status == 'onLeave') {
        leaveCount++;
        if (entry['leaveType'] == 'withoutPay') wopCount++;
      }
    }

    setState(() {
      name = userDoc['fullName'];
      dept = userDoc['department'];
      role = userDoc['role'];
      leaveBalance = Map<String, dynamic>.from(userDoc['leaveBalance']);
      benefits = Map<String, dynamic>.from(userDoc['benefits']);
      late = lateCount;
      present = presentCount;
      onLeave = leaveCount;
      withoutPay = wopCount;
      loading = false;
      attendanceData  = attendanceSnap.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text("My Dashboard")),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.person_outline,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(name, style: theme.textTheme.titleMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Department: $dept"),
                            Text("Role: ${role.toUpperCase()}"),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(
                      "Attendance Summary",
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 12),
                    attendanceData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              "No attendance data available.",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    :
                    SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Present', present),
                            ChartData('Late', late),
                            ChartData('Leave', onLeave),
                            ChartData('Without Pay', withoutPay),
                          ],
                          xValueMapper: (d, _) => d.label,
                          yValueMapper: (d, _) => d.value,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Text("Leave Balance", style: theme.textTheme.titleMedium),
                    SizedBox(height: 12),
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _leaveRow(
                              "Annual",
                              '${leaveBalance['annual']} days left',
                            ),
                            Divider(color: Colors.black, thickness: 1,),
                            _leaveRow(
                              "Sick",
                              '${leaveBalance['sick']} days left',
                            ),
                            Divider(color: Colors.black, thickness: 1,),
                            _leaveRow(
                              "Without Pay",
                              '${leaveBalance['withoutPay']} days left',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Benefits", style: theme.textTheme.titleMedium),
                    SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _leaveRow(
                              "Health Insurance",
                              benefits['healthInsurance'] ? 'Yes' : 'No',
                            ),
                            Divider(color: Colors.black, thickness: 1,),
                            _leaveRow(
                              "other",
                              benefits['otherBenefit'] ?? 'None',
                            ),
                            Divider(color: Colors.black, thickness: 1,),
                            _leaveRow("Insurance Claims Filed:", '2'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _leaveRow(String type, dynamic count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(type, style: TextStyle(fontWeight: FontWeight.w600)),
        Text(count.toString()),
      ],
    );
  }
}

class ChartData {
  final String label;
  final int value;
  ChartData(this.label, this.value);
}
