import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final empNoController = TextEditingController();
  final deptController = TextEditingController();
  final benefitOtherController = TextEditingController();

  String role = 'employee';
  bool hasInsurance = false;
  bool loading = false;

  void submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final userData = {
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'employeeNumber': empNoController.text.trim(),
        'department': deptController.text.trim(),
        'role': role,
        'lateCount': 0,
        'leaveBalance': {'annual': 12, 'sick': 5, 'withoutPay': 0},
        'benefits': {
          'healthInsurance': hasInsurance,
          'otherBenefit': benefitOtherController.text.trim(),
        },
      };

      await FirebaseFirestore.instance.collection('users').add(userData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User added successfully")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Add New User")),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "User Information",
                        style: theme.textTheme.headlineLarge,
                      ),
                      SizedBox(height: 30),

                      TextFormField(
                        controller: nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(labelText: "Full Name"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: empNoController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: "Employee Number",
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: deptController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(labelText: "Department"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: InputDecoration(labelText: "Role"),
                        items:
                            ['admin', 'hr', 'employee']
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => role = val!),
                      ),
                      SizedBox(height: 16),

                      CheckboxListTile(
                        value: hasInsurance,
                        title: Text("Has Health Insurance?"),
                        onChanged: (val) => setState(() => hasInsurance = val!),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      TextFormField(
                        controller: benefitOtherController,
                        decoration: InputDecoration(
                          labelText: "Other Benefit (Optional)",
                        ),
                      ),
                      SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submitUser,
                          icon: Icon(Icons.check_circle_outline),
                          label: Text("Add User"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
