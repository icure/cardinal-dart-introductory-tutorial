import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_sdk/utils/pagination/paginated_list_iterator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playground/cardinal/create_sdk.dart';
import 'package:flutter_playground/cardinal/pretty_print.dart';
import 'package:flutter_playground/cardinal/search.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchStringController = TextEditingController();

  int _stage = 1;
  DecryptedPatient? cachedPatient;
  late DecryptedPatient patientIteratorPtx;
  late DecryptedContact contactIteratorPtx;
  late DecryptedService serviceIteratorPtx;
  late PaginatedListIterator<DecryptedPatient> cachedPatientIterator;
  late PaginatedListIterator<DecryptedContact> cachedContactIterator;
  late PaginatedListIterator<DecryptedService> cachedServiceIterator;
  bool _isLoading = false;
  bool hasNextPatient = false;
  bool hasNextContact = false;
  bool hasNextService = false;

  Future<void> _getIterator(String nameToSearch) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedPatientIterator = await createPatientIterator(sdk, nameToSearch);
    hasNextPatient = await cachedPatientIterator.hasNext();
    if (hasNextPatient) {
      patientIteratorPtx = (await cachedPatientIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextPatient ? 2 : 1;
    });
  }

  Future<void> _nextPatient() async {
    setState(() {
      _isLoading = true;
    });
    hasNextPatient = await cachedPatientIterator.hasNext();
    if (hasNextPatient) {
      patientIteratorPtx = (await cachedPatientIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextPatient ? 2 : 1;
    });
  }

  Future<void> _selectPatient() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedPatient = patientIteratorPtx;
    cachedContactIterator = await createContactIterator(sdk, cachedPatient!);
    hasNextContact = await cachedContactIterator.hasNext();
    if (hasNextContact) {
      contactIteratorPtx = (await cachedContactIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextContact ? 3 : 4;
    });
  }

  Future<void> _nextContact() async {
    setState(() {
      _isLoading = true;
    });
    hasNextContact = await cachedContactIterator.hasNext();
    if (hasNextContact) {
      contactIteratorPtx = (await cachedContactIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextContact ? 3 : 4;
    });
  }

  Future<void> _chooseServiceType(int choice) async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedServiceIterator = await createServiceIterator(sdk, choice);
    hasNextService = await cachedServiceIterator.hasNext();
    if (hasNextService) {
      serviceIteratorPtx = (await cachedServiceIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextService ? 5 : 6;
    });
  }

  Future<void> _nextService() async {
    setState(() {
      _isLoading = true;
    });
    hasNextService = await cachedServiceIterator.hasNext();
    if (hasNextService) {
      serviceIteratorPtx = (await cachedServiceIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextService ? 5 : 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medical Data'),
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
            Text(cachedPatient != null ? "Selected patient: ${cachedPatient?.firstName} ${cachedPatient?.lastName}" : ""),
            if (_stage == 1) ...[
              Text(!hasNextPatient ? "No patient found, try again" : ""),
              TextField(
                controller: _searchStringController,
                decoration: const InputDecoration(labelText: 'Name to search'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      final searchString = _searchStringController.text;
                      _getIterator(searchString);
                    },
                    child: const Text('Search'),
              ),
            ] else if (_stage == 2) ...[
              Text("Use ${patientIteratorPtx.firstName} ${patientIteratorPtx.lastName}?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _selectPatient,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _nextPatient,
                child: const Text('Next'),
              ),
            ] else if (_stage == 3) ...[
              Text(prettyPrintContact(contactIteratorPtx)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _nextContact,
                child: const Text('Next'),
              ),
            ] else if (_stage == 4) ...[
              const Text("Choose a type of Service"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  _chooseServiceType(0);
                },
                child: const Text('Blood Pressure'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {
                  _chooseServiceType(1);
                },
                child: const Text('Heart Rate'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: () {
                  _chooseServiceType(2);
                },
                child: const Text('X-Ray Image'),
              ),
            ] else if (_stage == 5) ...[
              Text(prettyPrintService(serviceIteratorPtx)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _nextService,
                child: const Text('Next'),
              ),
            ] else if (_stage == 6) ...[
              const Text("No more medical data to show"),
            ],
          ],
        ),
      ),
    );
  }
}
