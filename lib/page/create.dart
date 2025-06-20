import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/widget/user_form_widget.dart';

class CreateSheetsPage extends StatelessWidget {
  const CreateSheetsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Add Data To Sheet"),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: UserFormWidget(
              onSavedUser: (data) async {
                final connectivity = await Connectivity().checkConnectivity();
                int id;

                if (connectivity == ConnectivityResult.none) {
                  // Use timestamp or incrementing local ID
                  id = DateTime.now().millisecondsSinceEpoch;
                  print('[Create] Offline mode, using timestamp ID: $id');
                } else {
                  id = await DataApi.getRowCount() + 1;
                  print('[Create] Online mode, using sheet row count ID: $id');
                }

                final newData = data.copy(id: id);
                await DataApi.insert([newData.toJson()]);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Data inserted successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
}
