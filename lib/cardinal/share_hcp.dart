import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/model/document.dart';
import 'package:cardinal_sdk/model/embed/access_level.dart';
import 'package:cardinal_sdk/model/healthcare_party.dart';
import 'package:cardinal_introductory_tutorial/cardinal/pretty_print.dart';
import 'package:cardinal_introductory_tutorial/cardinal/utils.dart';

Future<DecryptedDocument> createDocumentWithoutSharing(CardinalSdk sdk) async {
  final oldDocument = await sdk.document.createDocument(
      await sdk.document.withEncryptionMetadata(
          DecryptedDocument(
              generateUuid(),
              name: "An important document"
          ),
          null
      )
  );
  return oldDocument;
}

Future<DecryptedDocument> createDocumentAndShare(CardinalSdk sdk, HealthcareParty otherHcp) async {
  final newDocument = DecryptedDocument(
      generateUuid(),
      name: "Another important document"
  );
  final newDocumentWithMetadata = await sdk.document.withEncryptionMetadata(
      newDocument,
      null,
      delegates: { otherHcp.id: AccessLevel.read }
  );
  final createdNewDocument = await sdk.document.createDocument(newDocumentWithMetadata);
  return createdNewDocument;
}

Future<bool> shareWithHcp(CardinalSdk sdk, DecryptedDocument oldDocument, HealthcareParty otherHcp) async {
  try {
    await sdk.document.shareWith(otherHcp.id, oldDocument);
    return true;
  } on Exception catch(e) {
    return false;
  }
}

Future<String> getDocument(CardinalSdk otherSdk, String documentId) async {
  try {
    final document = await otherSdk.document.getDocument(documentId);
    return prettyPrintDocument(document);
  } on Exception catch(e) {
    return "Document is not shared with HCP 2";
  }
}