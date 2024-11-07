import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> pieChartData;

  const PieChartWidget({
    Key? key,
    required this.pieChartData, // Accept dynamic data
  }) : super(key: key);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  late Future<String> _totalFuture;

  @override
  void initState() {
    super.initState();
    _totalFuture = DataApi.getTotal(); // Fetch total value once
  }

  @override
  Widget build(BuildContext context) {
    double totalValue =
        widget.pieChartData.values.fold(0.0, (sum, value) => sum + value);

    return Row(
      children: [
        // PieChart on the left
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FutureBuilder<String>(
                future: _totalFuture, // Use cached future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Text.rich(
                      TextSpan(
                        text: 'Total\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'Rp. ${NumberFormat("#,##0").format(double.tryParse(snapshot.data.toString()) ?? 0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
              PieChart(PieChartData(
                sections: widget.pieChartData.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: '',
                    color: _getColorForCategory(entry.key),
                    radius: 30,
                  );
                }).toList(),
              )),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.pieChartData.entries.map((entry) {
              double percentage = (entry.value / totalValue) * 100;
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Container(
                      width: 15,
                      height: 20,
                      color: _getColorForCategory(entry.key),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Others':
        return Colors.blue;
      case 'Food & Drinks':
        return Colors.green;
      case 'Entertainment':
        return Colors.red;
      case 'Travel':
        return Colors.yellow;
      case 'Shopping':
        return Colors.purple;
      default:
        // You can add a dynamic color or a fallback
        return Colors.orange; // Use a default color like orange
    }
  }
}
