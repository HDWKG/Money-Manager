import 'package:flutter/material.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/button_widget.dart';

class UserFormWidget extends StatefulWidget {
  final ValueChanged<User> onSavedUser;
  const UserFormWidget({Key? key, required this.onSavedUser}) : super(key: key);

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final formKey = GlobalKey<FormState>();

  // Initialize controllers directly to avoid late initialization errors
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  bool isBeginner = true; // Initialize directly here as well

  @override
  Widget build(BuildContext context) => Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildName(),
          const SizedBox(height: 16),
          buildEmail(),
          const SizedBox(height: 16),
          buildSwitch(),
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

  Widget buildEmail() => TextFormField(
      controller: controllerEmail,
      decoration:
          InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
      validator: (value) =>
          value != null && value.isEmpty ? 'Enter Email' : null);

  Widget buildSwitch() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: isBeginner,
        title: Text("Is Flutter Beginner?"),
        onChanged: (value) => setState(() => isBeginner = value),
      );

  Widget buildSubmit() => ButtonWidget(
      text: 'Save',
      onClicked: () {
        final form = formKey.currentState!;
        final isValid = form.validate();

        if (isValid) {
          final data = User(
              name: controllerName.text,
              email: controllerEmail.text,
              isBeginner: isBeginner);
          widget.onSavedUser(data);
        }
      });

  @override
  void dispose() {
    controllerName.dispose();
    controllerEmail.dispose();
    super.dispose();
  }
}
