import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/button_widget.dart';
import 'package:mon/widget/user_form_widget.dart';

class CreateSheetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Mon"),
        centerTitle: true,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(32),
          child: SingleChildScrollView(child: UserFormWidget(
            onSavedUser: (data) async {
              final id = await DataApi.getRowCount() + 1;
              final newData = data.copy(id: id);
              await DataApi.insert([newData.toJson()]);
            },
          )))
      // child: UserFormWidget(onSavedUser: (data) async {
      //   final data =
      //       User(id: 1, email: "@g", name: "o", isBeginner: false);

      // })),
      );
  Future insertData() async {
    final data = [
      User(id: 1, name: "John", email: "John@gmail.com", isBeginner: true),
      User(id: 2, name: "Paul", email: "Paul@gmail.com", isBeginner: false)
    ];
    final jsonData = data.map((data) => data.toJson()).toList();
    await DataApi.insert(jsonData);
  }
}
