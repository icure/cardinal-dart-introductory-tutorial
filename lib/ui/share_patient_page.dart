import 'package:cardinal_sdk/model/health_element.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:cardinal_introductory_tutorial/cardinal/create_sdk.dart';
import 'dart:async';

import 'package:cardinal_introductory_tutorial/cardinal/share_patient.dart';

class SharePatientPage extends StatefulWidget {
  const SharePatientPage({super.key});

  @override
  _SharePatientPageState createState() => _SharePatientPageState();
}

class _SharePatientPageState extends State<SharePatientPage> {

  int _stage = 1;
  DecryptedHealthElement? currentHealthElement;
  bool? shareStatus;
  String? output;
  late String patientUsername;
  late DecryptedPatient patient;
  bool _isLoading = false;
  bool successfulCreation = true;

  Future<void> _createPatientUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final sdk = sdkCache[mainUsername]!;
      final patientUser = await createPatientSdk(sdk);
      patientUsername = patientUser.login!;
      final patientSdk = sdkCache[patientUsername]!;
      patient = await patientSdk.patient.getPatient(patientUser.patientId!);
      successfulCreation = true;
    } catch(e) {
      successfulCreation = false;
    }
    setState(() {
      _isLoading = false;
      _stage = successfulCreation ? 2 : 1;
    });
  }

  Future<void> _createHealthElementWithoutSharing() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    currentHealthElement = await createHealthElementWithoutSharing(sdk, patient);
    shareStatus = false;
    output = "Created health element ${currentHealthElement?.id}";
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createHealthElementAndShare() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    currentHealthElement = await createHealthElementAndShare(sdk, patient);
    shareStatus = true;
    output = "Created health element ${currentHealthElement?.id}";
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _shareHealthElement() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    shareStatus = await shareHealthElementWithPatient(sdk, currentHealthElement!, patient);
    if (shareStatus!) {
      output = "Successfully shared health element ${currentHealthElement?.id}";
    } else {
      output = "Health element ${currentHealthElement?.id} is already shared";
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _retrieveHealthElement() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[patientUsername]!;
    output = await getHealthElement(sdk, currentHealthElement!.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share data with a patient'),
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
              Text(!successfulCreation ? "There was an error creating the patient" : ""),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createPatientUser,
                child: const Text('Create Patient User'),
              ),
            ] else if (_stage == 2) ...[
              const Text("Choose an operation"),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createHealthElementWithoutSharing,
                child: const Text('Doctor 1 creates data without sharing'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _createHealthElementAndShare,
                child: const Text('Doctor 1 creates data and shares with patient'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _shareHealthElement,
                child: const Text('Doctor 1 shares created data with patient'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _retrieveHealthElement,
                child: const Text('Patient checks access'),
              ),
            ],
            Text(currentHealthElement != null ? "Current health element: ${currentHealthElement?.id}" : "Current health element:"),
            Text(shareStatus != null ? "Status: ${shareStatus! ? "shared" : "not shared"}" : ""),
            const SizedBox(height: 20),
            Text(output != null ? output! : "")
          ],
        ),
      ),
    );
  }
}
