import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hr_pulse_app/service/export_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewDashboardScreen extends StatefulWidget {
  const OverviewDashboardScreen({super.key});

  @override
  State<OverviewDashboardScreen> createState() =>
      _OverviewDashboardScreenState();
}

class _OverviewDashboardScreenState extends State<OverviewDashboardScreen> {
  final GlobalKey<SfCartesianChartState> _lateChartKey = GlobalKey();
  final GlobalKey<SfCartesianChartState> _leaveChartKey = GlobalKey();
  Map<String, int> lateCounts = {};
  Map<String, int> leaveTrends = {};
  int totalAttendance = 0;
  int totalLate = 0;
  String mostPunctual = 'N/A';
  String leastPunctual = 'N/A';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOverviewData();
  }

  Future<void> loadOverviewData() async {
    final attendanceSnap =
        await FirebaseFirestore.instance.collection('attendance').get();
    final userSnap = await FirebaseFirestore.instance.collection('users').get();

    Map<String, int> latePerDept = {};
    Map<String, int> leavesPerMonth = {};
    Map<String, int> deptTotals = {};

    int late = 0;
    int total = attendanceSnap.docs.length;

    for (var doc in attendanceSnap.docs) {
      final status = doc['status'];
      final uid = doc['userId'];
      final user = userSnap.docs.firstWhere((u) => u.id == uid);
      if (user == null) continue;

      final dept = user['department'];
      deptTotals[dept] = (deptTotals[dept] ?? 0) + 1;

      if (status == 'late') {
        late += 1;
        latePerDept[dept] = (latePerDept[dept] ?? 0) + 1;
      }

      if (status == 'onLeave') {
        final dateStr = doc['date'];
        final month = dateStr.substring(0, 7); // yyyy-MM
        leavesPerMonth[month] = (leavesPerMonth[month] ?? 0) + 1;
      }
    }

    String most = 'N/A';
    String least = 'N/A';
    if (deptTotals.isNotEmpty) {
      final punctualRates = {
        for (var dept in deptTotals.keys)
          dept:
              100 -
              ((latePerDept[dept] ?? 0) / deptTotals[dept]! * 100).round(),
      };

      most =
          punctualRates.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      least =
          punctualRates.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    }

    setState(() {
      totalLate = late;
      totalAttendance = total;
      lateCounts = latePerDept;
      leaveTrends = leavesPerMonth;
      mostPunctual = most;
      leastPunctual = least;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Company Overview")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double latenessRate =
        totalAttendance == 0 ? 0 : (totalLate / totalAttendance) * 100;

    return Scaffold(
      appBar: AppBar(title: Text("Company Overview")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_paste,
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text("Summary", style: theme.textTheme.titleMedium),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text("Total Attendance: $totalAttendance"),
                    Text("Total Late Entries: $totalLate"),
                    Text(
                      "Average Lateness Rate: ${latenessRate.toStringAsFixed(2)}%",
                    ),
                    Text("Most Punctual Dept: $mostPunctual"),
                    Text("Least Punctual Dept: $leastPunctual"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
              "Late Count by Department",
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            SfCartesianChart(
              key: _lateChartKey,
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource:
                      lateCounts.entries
                          .map((e) => ChartData(e.key, e.value))
                          .toList(),
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),

            SizedBox(height: 30),

            Text("Monthly Leave Trends", style: theme.textTheme.titleMedium),
            SizedBox(height: 12),
            leaveTrends.length < 2
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        "Not enough data to display trends.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                : SfCartesianChart(
                  key: _leaveChartKey,
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    LineSeries<ChartData, String>(
                      dataSource:
                          leaveTrends.entries
                              .map((e) => ChartData(e.key, e.value))
                              .toList(),
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      color: theme.colorScheme.secondary,
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                  ],
                ),

            SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () =>exportOverviewAsPDF(
                          DashboardData(
                            totalAttendance: totalAttendance,
                            totalLate: totalLate,
                            mostPunctual: mostPunctual,
                            leastPunctual: leastPunctual,
                            latePerDept: lateCounts,
                            monthlyLeaves: leaveTrends,
                          ),
                          context,
                          _lateChartKey,
                          _leaveChartKey,
                        ),
                        
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text("Export PDF"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => exportOverviewAsCSV(
                          DashboardData(
                            totalAttendance: totalAttendance,
                            totalLate: totalLate,
                            mostPunctual: mostPunctual,
                            leastPunctual: leastPunctual,
                            latePerDept: lateCounts,
                            monthlyLeaves: leaveTrends,
                          ),
                          context,
                        ),
                    icon: Icon(Icons.table_chart),
                    label: Text("Export CSV"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;
  ChartData(this.label, this.value);
}

class DashboardData {
  final int totalAttendance;
  final int totalLate;
  final String mostPunctual;
  final String leastPunctual;
  final Map<String, int> latePerDept;
  final Map<String, int> monthlyLeaves;

  DashboardData({
    required this.totalAttendance,
    required this.totalLate,
    required this.mostPunctual,
    required this.leastPunctual,
    required this.latePerDept,
    required this.monthlyLeaves,
  });
}

