import 'package:cardinal_sdk/model/document.dart';
import 'package:cardinal_sdk/model/healthcare_party.dart';
import 'package:flutter/material.dart';
import 'package:cardinal_introductory_tutorial/cardinal/create_sdk.dart';
import 'package:cardinal_introductory_tutorial/cardinal/share_hcp.dart';
import 'dart:async';
import '../cardinal/pretty_print.dart';

class ShareHcpPage extends StatefulWidget {
  const ShareHcpPage({super.key});

  @override
  _ShareHcpPageState createState() => _ShareHcpPageState();
}

class _ShareHcpPageState extends State<ShareHcpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int _stage = 1;
  DecryptedDocument? currentDocument;
  bool? shareStatus;
  String? output;
  late String otherHcpUsername;
  late HealthcareParty otherHcp;
  bool _isLoading = false;
  bool successfulLogin = true;

  Future<void> _instantiateOtherSdk(String username, String password) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final sdk = await createSdk(username, password);
      otherHcpUsername = username;
      otherHcp = await sdk.healthcareParty.getCurrentHealthcareParty();
      successfulLogin = true;
    } catch(e) {
      successfulLogin = false;
    }
    setState(() {
      _isLoading = false;
      _stage = successfulLogin ? 2 : 1;
    });
  }

  Future<void> _createDocumentWithoutSharing() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    currentDocument = await createDocumentWithoutSharing(sdk);
    shareStatus = false;
    output = "Created document ${currentDocument?.id}";
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createDocumentAndShare() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    currentDocument = await createDocumentAndShare(sdk, otherHcp);
    shareStatus = true;
    output = "Created document ${currentDocument?.id}";
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _shareDocument() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[mainUsername]!;
    shareStatus = await shareWithHcp(sdk, currentDocument!, otherHcp);
    if (shareStatus!) {
      output = "Successfully shared document ${currentDocument?.id}";
    } else {
      output = "Document ${currentDocument?.id} is already shared";
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _retrieveDocument() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[otherHcpUsername]!;
    output = await getDocument(sdk, currentDocument!.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share data with another HCP'),
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
              Text(!successfulLogin ? "Invalid username or password" : ""),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Other Healthcare Party username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Other Healthcare Party password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      final firstName = _usernameController.text;
                      final lastName = _passwordController.text;
                      _instantiateOtherSdk(firstName, lastName);
                    },
                    child: const Text('Submit'),
              ),
            ] else if (_stage == 2) ...[
                const Text("Choose an operation"),
                _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _createDocumentWithoutSharing,
                    child: const Text('Doctor 1 creates data without sharing'),
                  ),
                _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                    onPressed: _createDocumentAndShare,
                    child: const Text('Doctor 1 creates data and shares with doctor 2'),
                  ),
                _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                    onPressed: _shareDocument,
                    child: const Text('Doctor 1 shares created data with doctor 2'),
                  ),
                  _isLoading
                    ? const SizedBox(height: 20)
                    : ElevatedButton(
                      onPressed: _retrieveDocument,
                      child: const Text('Doctor 2 checks data access'),
                    ),
            ],
            Text(currentDocument != null ? "Current document: ${currentDocument?.id}" : "Current document:"),
            Text(shareStatus != null ? "Status: ${shareStatus! ? "shared" : "not shared"}" : ""),
            const SizedBox(height: 20),
            Text(output != null ? output! : "")
          ],
        ),
      ),
    );
  }
}
