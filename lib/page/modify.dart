import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/button_widget.dart';
import 'package:mon/widget/navigate_datas_widget.dart';
import 'package:mon/widget/user_form_widget.dart';

class ModifySheetsPage extends StatefulWidget {
  const ModifySheetsPage({super.key});

  @override
  State<ModifySheetsPage> createState() => _ModifySheetsPageState();
}

class _ModifySheetsPageState extends State<ModifySheetsPage> {
  List<User> datas = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData({int index = 0}) async {
    final fetchedDatas = await DataApi.getAll(); // Fetch data
    setState(() {
      datas = fetchedDatas; // Update the state with fetched data
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Modify Sheets"),
          centerTitle: true,
        ),
        body: Center(
          child: datas.isEmpty // Check if datas is empty
              ? const CircularProgressIndicator() // Show loading indicator
              : ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                    UserFormWidget(
                      data: datas[index], // Access only if datas is not empty
                      onSavedUser: (data) async {
                        await DataApi.update(data.id!, data.toJson());
                        // DataApi.updateCell(
                        //   id: 2,
                        //   key: 'Name',
                        //   value: 'Test',
                        // );
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Data Editted successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (datas.isNotEmpty) buildUserControls()
                  ],
                ),
        ),
      );

  Widget buildUserControls() => Column(children: [
        ButtonWidget(text: 'Delete', onClicked: deleteUser),
        NavigateDatasWidget(
          text: '${index + 1}/${datas.length} Datas',
          onClickedNext: () {
            final nextIndex = index >= datas.length - 1 ? 0 : index + 1;

            setState(() => index = nextIndex);
          },
          onClickedPrevious: () {
            final previousIndex = index <= 0 ? datas.length - 1 : index - 1;

            setState(() => index = previousIndex);
          },
        )
      ]);

  Future<void> deleteUser() async {
    final data = datas[index];

    await DataApi.deleteById(data.id!);

    final isLastItem = index == datas.length - 1;
    final isOnlyOne = datas.length == 1;
    final newIndex = isOnlyOne ? 0 : (isLastItem ? index - 1 : index);

    await getData(index: newIndex);

    setState(() {
      index = newIndex;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Data Deleted Successfully!'),
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
