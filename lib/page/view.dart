import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/chart_widget.dart';

class ViewAllPage extends StatefulWidget {
  @override
  _ViewAllPageState createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  late Future<List<User>> _usersFuture;
  late Future<Map<String, double>> _pieChartDataFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DataApi.getAll();
    _pieChartDataFuture = DataApi.getPieChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Entries'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: FutureBuilder<Map<String, double>>(
                future: _pieChartDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found.'));
                  }
                  return PieChartWidget(pieChartData: snapshot.data!);
                },
              ),
            ),
            FutureBuilder<String>(
              future: DataApi.getActiveTab(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("");
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}"); // Handle error
                } else {
                  final activeTab = snapshot.data ?? ''; // Get the active tab
                  return Text(""); // Display the active tab
                }
              },
            ),
            FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found.'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: UserFields.getFields()
                        .map((field) => DataColumn(label: Text(field)))
                        .toList(),
                    rows: snapshot.data!.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.id?.toString() ?? 'N/A')),
                        DataCell(Text(user.name ?? 'N/A')),
                        DataCell(Text(user.method ?? 'N/A')),
                        DataCell(Text(user.type ?? 'N/A')),
                        DataCell(Text(
                          'Rp ${NumberFormat("#,##0").format(user.total?.toDouble() ?? 0)}',
                          style: TextStyle(
                              fontWeight: FontWeight
                                  .normal), // Optional: set text style
                        )),
                        DataCell(Text(user.category ?? 'N/A')),
                        DataCell(Text(user.date?.toIso8601String() ?? 'N/A')),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
