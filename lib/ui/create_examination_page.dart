import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:cardinal_introductory_tutorial/cardinal/create_sdk.dart';
import 'package:cardinal_introductory_tutorial/cardinal/examination.dart';
import 'dart:async';
import '../cardinal/pretty_print.dart';

class CreateExaminationPage extends StatefulWidget {
  @override
  _CreateExaminationPageState createState() => _CreateExaminationPageState();
}

class _CreateExaminationPageState extends State<CreateExaminationPage> {
  final _patientIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _diagnosisController = TextEditingController();

  int _stage = 1;
  DecryptedPatient? cachedPatient;
  DecryptedContact? cachedContact;
  bool _isLoading = false;

  Future<void> _getOrCreatePatient(String patientId) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedPatient = await getOrCreatePatient(sdk, patientId);
    setState(() {
      _isLoading = false;
      _stage = 2;
    });
  }

  Future<void> _createExamination(String description) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await createNewContact(sdk, cachedPatient!, description);
    setState(() {
      _isLoading = false;
      _stage = 3;
    });
  }

  Future<void> _addBloodPressureService() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await addBloodPressureService(sdk, cachedContact!);
    setState(() {
      _isLoading = false;
      _stage = 4;
    });
  }

  Future<void> _addHeartRateService() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await addHeartRateService(sdk, cachedContact!);
    setState(() {
      _isLoading = false;
      _stage = 5;
    });
  }

  Future<void> _addXRayImageService() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await addXRayImageService(sdk, cachedContact!);
    setState(() {
      _isLoading = false;
      _stage = 6;
    });
  }

  Future<void> _addDiagnosis(String diagnosis) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await addDiagnosis(sdk, cachedContact!, cachedPatient!, diagnosis);
    setState(() {
      _isLoading = false;
      _stage = 7;
    });
  }

  Future<void> _closeContact() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedContact = await closeContact(sdk, cachedContact!);
    setState(() {
      _isLoading = false;
      _stage = 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an Examination'),
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
                controller: _patientIdController,
                decoration: const InputDecoration(labelText: 'Patient id (blank for new patient)'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: () {
                    final patientId = _patientIdController.text;
                    _getOrCreatePatient(patientId);
                  },
                  child: const Text('Submit'),
              ),
            ] else if (_stage == 2) ...[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Examination description'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      _createExamination(_descriptionController.text);
                    },
                child: const Text('Add description'),
              ),
            ] else if (_stage == 3) ...[
              const Text("Register blood pressure?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addBloodPressureService,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {},
                child: const Text('No'),
              ),
            ] else if (_stage == 4) ...[
              const Text("Register heart rate?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addHeartRateService,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {},
                child: const Text('No'),
              ),
            ] else if (_stage == 5) ...[
              const Text("Add an X-Ray image service?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addXRayImageService,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {},
                child: const Text('No'),
              ),
            ] else if (_stage == 6) ...[
              TextField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  _addDiagnosis(_diagnosisController.text);
                },
                child: const Text('Add diagnosis'),
              ),
            ] else if (_stage == 7) ...[
              const Text("Close contact?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _closeContact,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {},
                child: const Text('No'),
              ),
            ],
            Text(cachedPatient != null ? "Selected patient: ${cachedPatient?.firstName} ${cachedPatient?.lastName}" : ""),
            Text(cachedContact != null ? prettyPrintContact(cachedContact!) : ""),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
