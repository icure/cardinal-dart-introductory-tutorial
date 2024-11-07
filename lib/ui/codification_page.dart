import 'package:cardinal_sdk/model/code.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/utils/pagination/paginated_list_iterator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playground/cardinal/codification.dart';
import 'package:flutter_playground/cardinal/create_sdk.dart';
import 'package:flutter_playground/cardinal/pretty_print.dart';
import 'dart:async';

class CodificationPage extends StatefulWidget {
  const CodificationPage({super.key});

  @override
  _CodificationPageState createState() => _CodificationPageState();
}

class _CodificationPageState extends State<CodificationPage> {

  int _stage = 1;
  Code? cachedCode;
  late DecryptedContact cachedContact;
  late Code codeIteratorPtx;
  late DecryptedService serviceIteratorPtx;
  late PaginatedListIterator<Code> cachedCodeIterator;
  late PaginatedListIterator<DecryptedService> cachedServiceIterator;
  bool _isLoading = false;
  bool hasNextCode = false;
  bool hasNextService = false;

  Future<void> _getIterator() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedCodeIterator = await createCodeIterator(sdk);
    hasNextCode = await cachedCodeIterator.hasNext();
    if (hasNextCode) {
      codeIteratorPtx = (await cachedCodeIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextCode ? 2 : 1;
    });
  }

  Future<void> _nextCode() async {
    setState(() {
      _isLoading = true;
    });
    hasNextCode = await cachedCodeIterator.hasNext();
    if (hasNextCode) {
      codeIteratorPtx = (await cachedCodeIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextCode ? 2 : 1;
    });
  }

  Future<void> _selectCode() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedCode = codeIteratorPtx;
    cachedContact = await createContactWithCode(sdk, cachedCode!);
    setState(() {
      _isLoading = false;
      _stage = 3;
    });
  }

  Future<void> _nextStage() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    cachedServiceIterator = await getServiceIteratorForCode(sdk, cachedCode!);
    hasNextService = await cachedServiceIterator.hasNext();
    if (hasNextService) {
      serviceIteratorPtx = (await cachedServiceIterator.next(1)).first;
    }
    setState(() {
      _isLoading = false;
      _stage = hasNextService ? 4 : 5;
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
        title: const Text('Use Codifications'),
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
            Text(cachedCode != null ? "Selected code: ${cachedCode?.id}" : ""),
            if (_stage == 1) ...[
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _getIterator,
                    child: const Text('Search'),
              ),
            ] else if (_stage == 2) ...[
              Text("Use ${codeIteratorPtx.id} (${codeIteratorPtx.label?["en"]})?"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _selectCode,
                child: const Text('Yes'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _nextCode,
                child: const Text('Next'),
              ),
            ] else if (_stage == 3) ...[
              Text("Created contact ${cachedContact.id}"),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _nextStage,
                child: Text('Search Service with code ${cachedCode?.id} (${codeIteratorPtx.label?["en"]})'),
              ),
            ] else if (_stage == 4) ...[
              Text(prettyPrintService(serviceIteratorPtx)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _nextService,
                child: const Text('Next'),
              ),
            ] else if (_stage == 5) ...[
              const Text("No more medical data to show"),
            ],
          ],
        ),
      ),
    );
  }
}
