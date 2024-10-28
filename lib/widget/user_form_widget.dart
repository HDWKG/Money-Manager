import 'package:flutter/material.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/button_widget.dart';
import 'package:intl/intl.dart';

class UserFormWidget extends StatefulWidget {
  final User? data;
  final ValueChanged<User> onSavedUser;

  const UserFormWidget({Key? key, required this.onSavedUser, this.data})
      : super(key: key);

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final formKey = GlobalKey<FormState>();

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerTotal = TextEditingController();

  String? selectedMethod;
  String? selectedType;
  String? selectedCategory;

  final List<String> methods = [
    'Jago',
    'BCA',
    'Cash',
    'GoPay',
    'ShopeePay',
    'Stockbit',
    'Bibit'
  ];
  final List<String> types = ['Expense','Income'];
  final List<String> categories = [
    'Food & Drinks',
    'Entertainment',
    'Travel',
    'Shopping',
    'Others'
  ];

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
        ),
      );

  Widget buildName() => TextFormField(
        controller: controllerName,
        decoration:
            InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
        validator: (value) =>
            value != null && value.isEmpty ? 'Enter Name' : null,
      );

  Widget buildMethod() => DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: 'Method', border: OutlineInputBorder()),
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
        decoration:
            InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
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
      if (text != rawTotal) {
        // Update only if there's a change
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
      decoration:
          InputDecoration(labelText: 'Total', border: OutlineInputBorder()),
      keyboardType: TextInputType.number,
      validator: (value) =>
          value != null && value.isEmpty ? 'Enter Total' : null,
      onSaved: (value) {
        // Remove formatting when saving the data
        controllerTotal.text = rawTotal;
      },
    );
  }

  Widget buildCategory() => DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: 'Category', border: OutlineInputBorder()),
        value: selectedCategory,
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
        validator: (value) => value == null ? 'Select Category' : null,
      );

  Widget buildSubmit() => ButtonWidget(
        text: 'Save',
        onClicked: () {
          final form = formKey.currentState!;
          final isValid = form.validate();

          if (isValid) {
            final id = widget.data != null
                ? widget.data!.id
                : 0; // Use 0 or some default value for a new entry
            final cleanTotalText =
                controllerTotal.text.replaceAll(RegExp(r'[^0-9]'), '');

            // Check if cleanTotalText is empty and handle it
            if (cleanTotalText.isEmpty) {
              // You can show an error or handle this case as needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Total cannot be empty')),
              );
              return;
            }

            print(
                'Saving User: { id: $id, name: ${controllerName.text}, total: $cleanTotalText }');

            final data = User(
              id: id,
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
  void initState() {
    super.initState();
    if (widget.data != null) {
      controllerName.text = widget.data!.name;
      controllerTotal.text = widget.data!.total.toString();
      selectedMethod = methods.contains(widget.data!.method)
          ? widget.data!.method
          : methods[0];
      selectedType =
          types.contains(widget.data!.type) ? widget.data!.type : types[0];
      selectedCategory = categories.contains(widget.data!.category)
          ? widget.data!.category
          : categories[0];
    } else {
      // If no data is provided, set default values
      selectedMethod = methods[0];
      selectedType = types[0];
      selectedCategory = categories[0];
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant UserFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != null && widget.data != oldWidget.data) {
      controllerName.text = widget.data!.name;
      controllerTotal.text = widget.data!.total.toString();
      selectedMethod = methods.contains(widget.data!.method)
          ? widget.data!.method
          : methods[0];
      selectedType =
          types.contains(widget.data!.type) ? widget.data!.type : types[0];
      selectedCategory = categories.contains(widget.data!.category)
          ? widget.data!.category
          : categories[0];
      setState(() {});
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerTotal.dispose();
    super.dispose();
  }
}
