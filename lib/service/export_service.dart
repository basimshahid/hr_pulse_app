import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:hr_pulse_app/screens/overview_dashboard_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';


// Future<void> exportOverviewAsPDF(DashboardData data, BuildContext context) async {
//   final status = await Permission.storage.request();
//   if (!status.isGranted) return;

//   final PdfDocument document = PdfDocument();
//   final page = document.pages.add();

//   final titleFont = PdfStandardFont(
//     PdfFontFamily.helvetica,
//     18,
//     style: PdfFontStyle.bold,
//   );
//   final headerFont = PdfStandardFont(
//     PdfFontFamily.helvetica,
//     14,
//     style: PdfFontStyle.bold,
//   );
//   final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
//   double y = 20;

//   // Title
//   page.graphics.drawString(
//     "📊 Company Overview Report",
//     titleFont,
//     bounds: Rect.fromLTWH(0, y, 500, 30),
//   );
//   y += 40;

//   // Summary Section
//   page.graphics.drawString(
//     "📋 Summary Metrics",
//     headerFont,
//     bounds: Rect.fromLTWH(0, y, 500, 20),
//   );
//   y += 25;

//   final summaryTable = PdfGrid();
//   summaryTable.columns.add(count: 2);
//   summaryTable.headers.add(1);
//   summaryTable.headers[0].cells[0].value = "Metric";
//   summaryTable.headers[0].cells[1].value = "Value";

//   summaryTable.rows.add().cells
//     ..[0].value = "Total Attendance Records"
//     ..[1].value = data.totalAttendance.toString();

//   summaryTable.rows.add().cells
//     ..[0].value = "Total Late Entries"
//     ..[1].value = data.totalLate.toString();

//   summaryTable.rows.add().cells
//     ..[0].value = "Average Lateness Rate (%)"
//     ..[1].value = (data.totalLate / data.totalAttendance * 100).toStringAsFixed(
//       2,
//     );

//   summaryTable.rows.add().cells
//     ..[0].value = "Most Punctual Department"
//     ..[1].value = data.mostPunctual;

//   summaryTable.rows.add().cells
//     ..[0].value = "Least Punctual Department"
//     ..[1].value = data.leastPunctual;

//   summaryTable.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent1);
//   summaryTable.draw(page: page, bounds: Rect.fromLTWH(0, y, 500, 100));
//   y += 120;

//   // Late Count Section
//   page.graphics.drawString(
//     "📊 Late Count by Department",
//     headerFont,
//     bounds: Rect.fromLTWH(0, y, 500, 20),
//   );
//   y += 25;

//   final lateTable = PdfGrid();
//   lateTable.columns.add(count: 2);
//   lateTable.headers.add(1);
//   lateTable.headers[0].cells[0].value = "Department";
//   lateTable.headers[0].cells[1].value = "Late Count";

//   for (var entry in data.latePerDept.entries) {
//     lateTable.rows.add().cells
//       ..[0].value = entry.key
//       ..[1].value = entry.value.toString();
//   }

//   lateTable.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent2);
//   lateTable.draw(page: page, bounds: Rect.fromLTWH(0, y, 500, 100));
//   y += 120;

//   // Leave Trend Section
//   page.graphics.drawString(
//     "📈 Monthly Leave Trend",
//     headerFont,
//     bounds: Rect.fromLTWH(0, y, 500, 20),
//   );
//   y += 25;

//   final leaveTable = PdfGrid();
//   leaveTable.columns.add(count: 2);
//   leaveTable.headers.add(1);
//   leaveTable.headers[0].cells[0].value = "Month";
//   leaveTable.headers[0].cells[1].value = "Leave Count";

//   for (var entry in data.monthlyLeaves.entries) {
//     leaveTable.rows.add().cells
//       ..[0].value = entry.key
//       ..[1].value = entry.value.toString();
//   }

//   leaveTable.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent3);
//   leaveTable.draw(page: page, bounds: Rect.fromLTWH(0, y, 500, 100));

//   // Save PDF
//   final dir = await getExternalStorageDirectory();
//   final file = File("${dir!.path}/overview_report.pdf");
//   await file.writeAsBytes(await document.save());
//   document.dispose();

//   ScaffoldMessenger.of(
//     context,
//   ).showSnackBar(SnackBar(content: Text("PDF exported to ${file.path}")));
// }


Future<void> exportOverviewAsPDF(
    DashboardData data,
    BuildContext context,
    GlobalKey<SfCartesianChartState> lateChartKey,
    GlobalKey<SfCartesianChartState> leaveChartKey,
) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) return;

  final PdfDocument document = PdfDocument();
  final page = document.pages.add();
  final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
  final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
  final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

  double y = 20;

  // Title
  page.graphics.drawString("📊 Company Overview Report", titleFont, bounds: Rect.fromLTWH(0, y, 500, 30));
  y += 40;

  // Summary Metrics
  page.graphics.drawString("📋 Summary Metrics", headerFont, bounds: Rect.fromLTWH(0, y, 500, 20));
  y += 25;

  final summaryTable = PdfGrid();
  summaryTable.columns.add(count: 2);
  summaryTable.headers.add(1);
  summaryTable.headers[0].cells[0].value = "Metric";
  summaryTable.headers[0].cells[1].value = "Value";

  summaryTable.rows.add().cells
    ..[0].value = "Total Attendance"
    ..[1].value = data.totalAttendance.toString();
  summaryTable.rows.add().cells
    ..[0].value = "Total Late Entries"
    ..[1].value = data.totalLate.toString();
  summaryTable.rows.add().cells
    ..[0].value = "Average Lateness Rate (%)"
    ..[1].value = (data.totalLate / data.totalAttendance * 100).toStringAsFixed(2);
  summaryTable.rows.add().cells
    ..[0].value = "Most Punctual Department"
    ..[1].value = data.mostPunctual;
  summaryTable.rows.add().cells
    ..[0].value = "Least Punctual Department"
    ..[1].value = data.leastPunctual;

  summaryTable.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent1);
  summaryTable.draw(page: page, bounds: Rect.fromLTWH(0, y, 500, 140));
  y += 160;

  // Now capture Charts
  Future<Uint8List> captureChart(GlobalKey<SfCartesianChartState> key) async {
    final ui.Image? img = await key.currentState!.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await img!.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Late Count Chart Image
  final lateChartImage = await captureChart(lateChartKey);
  final PdfBitmap lateBitmap = PdfBitmap(lateChartImage);
  page.graphics.drawString("📊 Late Count by Department", headerFont, bounds: Rect.fromLTWH(0, y, 500, 20));
  y += 25;
  page.graphics.drawImage(lateBitmap, Rect.fromLTWH(0, y, 400, 250));
  y += 270;

  // Leave Trends Chart Image
  final leaveChartImage = await captureChart(leaveChartKey);
  final PdfBitmap leaveBitmap = PdfBitmap(leaveChartImage);
  page.graphics.drawString("📈 Monthly Leave Trends", headerFont, bounds: Rect.fromLTWH(0, y, 500, 20));
  y += 25;
  page.graphics.drawImage(leaveBitmap, Rect.fromLTWH(0, y, 400, 250));

  // Save PDF
  final dir = await getExternalStorageDirectory();
  final file = File("${dir!.path}/overview_report.pdf");
  await file.writeAsBytes(await document.save());
  document.dispose();

  final fullPath = file.path;

  // Split and get the last 3 segments
  final segments = fullPath.split('/');
  final shortenedPath = segments.length >= 3
    ? segments.sublist(segments.length - 3).join('/')
    : fullPath; // fallback in case path is too short

  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      messagePadding: EdgeInsets.symmetric(horizontal: 10),
      message: "PDF exported to $shortenedPath",
      textStyle: TextStyle(fontSize: 14, color: Colors.white),
      backgroundColor: Colors.black54,
    ),
  );
}







Future<void> exportOverviewAsCSV(DashboardData data, BuildContext context) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) return;

  List<List<dynamic>> csvData = [];

  // Title
  csvData.add(["Company Overview Report"]);
  csvData.add([]);

  // Summary
  csvData.add(["Summary Metrics"]);
  csvData.add(["Metric", "Value"]);
  csvData.add(["Total Attendance Records", data.totalAttendance]);
  csvData.add(["Total Late Entries", data.totalLate]);
  csvData.add([
    "Average Lateness (%)",
    (data.totalLate / data.totalAttendance * 100).toStringAsFixed(2),
  ]);
  csvData.add(["Most Punctual Department", data.mostPunctual]);
  csvData.add(["Least Punctual Department", data.leastPunctual]);

  csvData.add([]);
  csvData.add(["Late Count by Department"]);
  csvData.add(["Department", "Late Count"]);
  for (var entry in data.latePerDept.entries) {
    csvData.add([entry.key, entry.value]);
  }

  csvData.add([]);
  csvData.add(["Monthly Leave Trend"]);
  csvData.add(["Month", "Leave Count"]);
  for (var entry in data.monthlyLeaves.entries) {
    csvData.add([entry.key, entry.value]);
  }

  String csv = const ListToCsvConverter().convert(csvData);

  final dir = await getExternalStorageDirectory();
  final file = File("${dir!.path}/overview_report.csv");
  await file.writeAsString(csv);

  final fullPath = file.path;

  // Split and get the last 3 segments
  final segments = fullPath.split('/');
  final shortenedPath = segments.length >= 3
    ? segments.sublist(segments.length - 3).join('/')
    : fullPath; // fallback in case path is too short

  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      messagePadding: EdgeInsets.symmetric(horizontal: 10),
      message: "CSV exported to $shortenedPath",
      textStyle: TextStyle(fontSize: 14, color: Colors.white),
      backgroundColor: Colors.black54,
    ),
  );
}


























// Future<void> exportOverviewAsPDF(DashboardData data) async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return;

//     final doc = PdfDocument();
//     final page = doc.pages.add();

//     final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
//     double y = 0;

//     page.graphics.drawString(
//       "Company Overview Report",
//       PdfStandardFont(PdfFontFamily.helvetica, 18),
//       bounds: Rect.fromLTWH(0, y, 500, 30),
//     );
//     y += 40;

//     // Summary metrics
//     final summary = [
//       "Total Attendance Records: ${data.totalAttendance}",
//       "Total Late Entries: ${data.totalLate}",
//       "Average Lateness Rate: ${(data.totalLate / data.totalAttendance * 100).toStringAsFixed(2)}%",
//       "Most Punctual Department: ${data.mostPunctual}",
//       "Least Punctual Department: ${data.leastPunctual}",
//     ];
//     for (var line in summary) {
//       page.graphics.drawString(
//         line,
//         font,
//         bounds: Rect.fromLTWH(0, y, 500, 20),
//       );
//       y += 20;
//     }

//     y += 20;
//     page.graphics.drawString(
//       "Late Count by Department",
//       font,
//       bounds: Rect.fromLTWH(0, y, 500, 20),
//     );
//     y += 20;

//     for (var entry in data.latePerDept.entries) {
//       page.graphics.drawString(
//         "${entry.key}: ${entry.value} late entries",
//         font,
//         bounds: Rect.fromLTWH(20, y, 500, 20),
//       );
//       y += 20;
//     }

//     y += 20;
//     page.graphics.drawString(
//       "Monthly Leave Trend",
//       font,
//       bounds: Rect.fromLTWH(0, y, 500, 20),
//     );
//     y += 20;

//     for (var entry in data.monthlyLeaves.entries) {
//       page.graphics.drawString(
//         "${entry.key}: ${entry.value} leaves",
//         font,
//         bounds: Rect.fromLTWH(20, y, 500, 20),
//       );
//       y += 20;
//     }

//     final dir = await getExternalStorageDirectory();
//     final file = File("${dir!.path}/overview_report.pdf");
//     await file.writeAsBytes(await doc.save());
//     doc.dispose();

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("PDF saved: ${file.path}")));
//   }