import 'package:cardinal_sdk/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:cardinal_introductory_tutorial/cardinal/create_sdk.dart';
import 'package:cardinal_introductory_tutorial/cardinal/patient.dart';
import 'dart:async';
import '../cardinal/pretty_print.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();

  int _stage = 1;
  DecryptedPatient? cachedPatient;
  bool _isLoading = false;

  Future<void> _createPatient(String firstName, String lastName) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedPatient = await createPatient(sdk, firstName, lastName);
    setState(() {
      _isLoading = false;
      _stage = 2;
    });
  }

  Future<void> _updatePatientWithBirthDate(int date) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedPatient = await updatePatientWithDateOfBirthAndRetrieve(sdk, cachedPatient!, date);
    setState(() {
      _isLoading = false;
      _stage = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_stage == 1) ...[
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      final firstName = _firstNameController.text;
                      final lastName = _lastNameController.text;
                      _createPatient(firstName, lastName);
                    },
                    child: const Text('Submit'),
              ),
            ] else if (_stage == 2) ...[
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date of birth (YYYYMMDD)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        RegExp regExp = RegExp(r'\d+');
                        Iterable<Match> matches = regExp.allMatches(_dateController.text);
                        String numbers = matches.map((match) => match.group(0)).join();
                        _updatePatientWithBirthDate(int.parse(numbers));
                      },
                      child: const Text('Update patient with date of birth'),
              ),
            ],
            Text(cachedPatient != null ? prettyPrintPatient(cachedPatient!) : ""),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
