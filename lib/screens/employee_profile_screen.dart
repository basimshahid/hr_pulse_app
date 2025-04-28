import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final String userId;

  const EmployeeProfileScreen({super.key, required this.userId});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  int late = 0, present = 0, onLeave = 0, withoutPay = 0;
  Map<String, dynamic> leaveBalance = {};
  Map<String, dynamic> benefits = {};
  String name = "", dept = "", role = "", empNo = "", email = "";
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
      empNo = userDoc['employeeNumber'];
      email = userDoc['email'];
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
      appBar: AppBar(title: const Text("Employee Profile")),
      body: loading 
      ? Center(child: CircularProgressIndicator())
      :SingleChildScrollView(
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
                const SizedBox(height: 16),
                Text(name, style: theme.textTheme.headlineLarge),
                Text(email, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text("Employee #: $empNo", style: theme.textTheme.labelLarge),
                const SizedBox(height: 20),

                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        _infoRow("Role", role.toUpperCase(), Icons.work_outline),
                        const Divider(color: Colors.black, thickness: 1),
                        _infoRow("Department", dept, Icons.apartment_outlined),
                        const Divider(color: Colors.black, thickness: 1),
                        _infoRow("Late Count", "$late", Icons.alarm),
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
                            Icon(Icons.info_outline, size: 48, color: Colors.blueGrey.shade700,),
                            const SizedBox(height: 8),
                            Text(
                              "No attendance data available.",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    
                    : SfCircularChart(
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

                const SizedBox(height: 30),

                Text("Leave Balance", style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        _infoRow("Annual", "${leaveBalance['annual']} days", Icons.date_range),
                        const Divider(color: Colors.black, thickness: 1),
                        _infoRow("Sick", "${leaveBalance['sick']} days", Icons.healing_outlined),
                        const Divider(color: Colors.black, thickness: 1),
                        _infoRow("Without Pay", "${leaveBalance['withoutPay']} days", Icons.money_off),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text("Benefits", style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.health_and_safety, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Health Insurance', style: theme.textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            benefits['healthInsurance'] == true
                                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                                : const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                        if (benefits['otherBenefit'] != null &&
                            benefits['otherBenefit'].toString().trim().isNotEmpty)
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
          ),
    );
        }
      
    
  }

  Widget _infoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }


class ChartData {
  final String label;
  final int value;
  ChartData(this.label, this.value);
}


