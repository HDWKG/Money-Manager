import 'package:flutter/material.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/button_widget.dart';
import 'package:intl/intl.dart';

class UserFormWidget extends StatefulWidget {
  final ValueChanged<User> onSavedUser;
  const UserFormWidget({Key? key, required this.onSavedUser}) : super(key: key);

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerTotal = TextEditingController();
  
  String? selectedMethod;
  String? selectedType;
  String? selectedCategory;

  final List<String> methods = ['BCA', 'Jago', 'Cash', 'GoPay', 'ShopeePay', 'Stockbit', 'Bibit'];
  final List<String> types = ['Income', 'Expense'];
  final List<String> categories = ['Entertainment', 'Travel', 'Shopping', 'Food & Drinks', 'Others'];

  @override
  Widget build(BuildContext context) => Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildName(),
          const SizedBox(height: 16),
          buildMethod(),
          const SizedBox(height: 16),
          buildType(),
          const SizedBox(height: 16),
          buildTotal(),
          const SizedBox(height: 16),
          buildCategory(),
          const SizedBox(height: 16),
          buildSubmit(),
        ],
      ));

  Widget buildName() => TextFormField(
        controller: controllerName,
        decoration:
            InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
        validator: (value) =>
            value != null && value.isEmpty ? 'Enter Name' : null,
      );

  Widget buildMethod() => DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Method', border: OutlineInputBorder()),
        value: selectedMethod,
        items: methods.map((method) {
          return DropdownMenuItem(
            value: method,
            child: Text(method),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedMethod = value),
        validator: (value) => value == null ? 'Select Method' : null,
      );

  Widget buildType() => DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
        value: selectedType,
        items: types.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedType = value),
        validator: (value) => value == null ? 'Select Type' : null,
      );

Widget buildTotal() {
  String rawTotal = ""; // Store the unformatted value

  controllerTotal.addListener(() {
    final text = controllerTotal.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text != rawTotal) { // Update only if there's a change
      rawTotal = text;
      final formattedText = text.isNotEmpty
          ? 'Rp ${NumberFormat('#,###', 'id_ID').format(int.parse(text))}'
          : '';

      controllerTotal.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  });

  return TextFormField(
    controller: controllerTotal,
    decoration: InputDecoration(labelText: 'Total', border: OutlineInputBorder()),
    keyboardType: TextInputType.number,
    validator: (value) => value != null && value.isEmpty ? 'Enter Total' : null,
    onSaved: (value) {
      // Remove formatting when saving the data
      controllerTotal.text = rawTotal;
    },
  );
}


  Widget buildCategory() => DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
        value: selectedCategory,
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
        // validator: (value) => value == null ? 'Select Category' : null,
      );

Widget buildSubmit() => ButtonWidget(
      text: 'Save',
      onClicked: () {
        final form = formKey.currentState!;
        final isValid = form.validate();

        if (isValid) {
          final cleanTotalText = controllerTotal.text.replaceAll(RegExp(r'[^0-9]'), '');
          final data = User(
            date: DateTime.now(),
            name: controllerName.text,
            method: selectedMethod ?? '',
            type: selectedType ?? '',
            total: int.parse(cleanTotalText),
            category: selectedCategory ?? '',
          );
          widget.onSavedUser(data);
        }
      },
    );


  @override
  void dispose() {
    controllerName.dispose();
    controllerTotal.dispose();
    super.dispose();
  }
}
