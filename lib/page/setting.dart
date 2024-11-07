import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/widget/button_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _tabController = TextEditingController();
  String? _selectedTab;
  List<String> _worksheetTitles = [];

  @override
  void initState() {
    super.initState();
    _fetchWorksheetTitles();
  }

  Future<void> _fetchWorksheetTitles() async {
    final titles = await DataApi.getAllWorksheetTitles();
    setState(() {
      _worksheetTitles = titles;
    });
  }

  void _saveTab() async {
    String tabName = _tabController.text.isNotEmpty
        ? _tabController.text
        : _selectedTab ?? '';
    if (tabName.isEmpty) {
      // Handle the case where no tab name is provided
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a tab name or select from the dropdown.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final isSuccess = await DataApi.updateTab(tabName);
    if (isSuccess) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Data edited successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Data Not Written!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Select Worksheet', border: OutlineInputBorder()),
              value: _selectedTab,
              onChanged: (newValue) {
                setState(() {
                  _selectedTab = newValue;
                });
              },
              items: _worksheetTitles
                  .map<DropdownMenuItem<String>>((String title) {
                return DropdownMenuItem<String>(
                  value: title,
                  child: Text(title),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // TextField for entering a new tab name
            TextFormField(
              controller: _tabController,
              decoration: const InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
              validator: (value) => value != null && value.isEmpty
                  ? 'Enter A New Tab Name'
                  : null,
            ),
            const SizedBox(height: 20),
            ButtonWidget(text: "Save", onClicked: _saveTab),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: DataApi.getActiveTab(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while fetching
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}"); // Handle error
                } else {
                  final activeTab = snapshot.data ?? ''; // Get the active tab
                  return Text(
                      "Active Sheet: $activeTab"); // Display the active tab
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
