import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/widget/user_form_widget.dart';

class CreateSheetsPage extends StatelessWidget {
  const CreateSheetsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Mon"),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: UserFormWidget(
              onSavedUser: (data) async {
                final id = await DataApi.getRowCount() + 1;
                final newData = data.copy(id: id);
                await DataApi.insert([newData.toJson()]);

                // Show a dialog to confirm data insertion
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Data inserted successfully!'),
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
              },
            ),
          ),
        ),
      );
}
  // Future insertData() async {
  //   final data = [
  //     User(id: 1, name: "John", email: "John@gmail.com", isBeginner: true),
  //     User(id: 2, name: "Paul", email: "Paul@gmail.com", isBeginner: false)
  //   ];
  //   final jsonData = data.map((data) => data.toJson()).toList();
  //   await DataApi.insert(jsonData);
  // }