import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> pieChartData;

  const PieChartWidget({
    Key? key,
    required this.pieChartData, // Accept dynamic data
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalValue =
        pieChartData.values.fold(0.0, (sum, value) => sum + value);

    return Row(
      children: [
        // PieChart on the left
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FutureBuilder<String>(
                future: DataApi.getTotal(), // Fetch data from cell I1
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Text.rich(
                      TextSpan(
                        text: 'Total\n', // Bold "Total"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'Rp. ${NumberFormat("#,##0").format(double.tryParse(snapshot.data.toString()) ?? 0)}', // Convert to double and format
                            style: TextStyle(
                              fontWeight: FontWeight
                                  .normal, // Normal weight for the data
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center, // Center the text
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
              PieChart(PieChartData(
                sections: pieChartData.entries.map((entry) {
                  double percentage = (entry.value / totalValue) * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '', // Display category and percentage
                    color: _getColorForCategory(
                        entry.key), // Customize color based on category
                    radius: 30, // Adjust the radius as needed
                  );
                }).toList(),
              )),
            ],
          ),
        ),
        // Legends on the right
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pieChartData.entries.map((entry) {
              double percentage = (entry.value / totalValue) * 100;
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: _getColorForCategory(entry.key),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 16),
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
