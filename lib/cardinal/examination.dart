import 'dart:math';
import 'dart:typed_data';
import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/model/base/identifier.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/document.dart';
import 'package:cardinal_sdk/model/embed/content.dart';
import 'package:cardinal_sdk/model/embed/document_type.dart';
import 'package:cardinal_sdk/model/embed/measure.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/embed/sub_contact.dart';
import 'package:cardinal_sdk/model/embed/time_series.dart';
import 'package:cardinal_sdk/model/health_element.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_introductory_tutorial/cardinal/utils.dart';

Future<DecryptedPatient> getOrCreatePatient(CardinalSdk sdk, String patientId) async {
  final patient = patientId.trim().isEmpty
      ? await sdk.patient.createPatient(
      await sdk.patient.withEncryptionMetadata(
          DecryptedPatient(
            generateUuid(),
            firstName: "Annabelle",
            lastName: "Hall",
          )
      )
  ) : await sdk.patient.getPatient(patientId);
  return patient;
}

Future<DecryptedContact> createNewContact(CardinalSdk sdk, Patient patient, String description) async {
  final contact = DecryptedContact(
      generateUuid(),
      descr: description,
      openingDate: currentDateAsYYYYMMddHHmmSS()
  );
  final contactWithMetadata = await sdk.contact.withEncryptionMetadata(contact, patient);
  final createdContact = await sdk.contact.createContact(contactWithMetadata);
  return createdContact;
}

Future<DecryptedContact> addBloodPressureService(CardinalSdk sdk, DecryptedContact createdContact) async {
  final bloodPressureService = DecryptedService(
      generateUuid(),
      label: "Blood pressure",
      identifier: [Identifier(system: "cardinal", value: "bloodPressure")],
      content: {
        "en": DecryptedContent(
            measureValue: Measure(
                value: (80 + Random().nextInt(41)).toDouble(),
                unit: "mmHg"
            )
        )
      }
  );
  createdContact.services = { bloodPressureService };
  final contactWithBloodPressure = await sdk.contact.modifyContact(createdContact);
  return contactWithBloodPressure;
}

Future<DecryptedContact> addHeartRateService(CardinalSdk sdk, DecryptedContact contactWithBloodPressure) async {
  final ecgSignal = List.generate(10, (_) => Random().nextInt(100) / 100.0);
  final heartRateService = DecryptedService(
      generateUuid(),
      identifier: [Identifier(system: "cardinal", value: "ecg")],
      label: "Heart rate",
      content: {
        "en": DecryptedContent(
            timeSeries: TimeSeries(
                samples: [ecgSignal]
            )
        )
      }
  );
  contactWithBloodPressure.services.add(heartRateService);
  final contactWithECG = await sdk.contact.modifyContact(contactWithBloodPressure);
  return contactWithECG;
}

Future<DecryptedContact> addXRayImageService(CardinalSdk sdk, DecryptedContact contactWithECG) async {
  final document = DecryptedDocument(
      generateUuid(),
      documentType: DocumentType.labresult
  );
  final createdDocument = await sdk.document.createDocument(
      await sdk.document.withEncryptionMetadata(document, null)
  );

  Uint8List xRayImage = Uint8List(100);
  for (int i = 0; i < xRayImage.length; i++) {
    xRayImage[i] = Random().nextInt(256);
  }
  final documentWithAttachment = await sdk.document.encryptAndSetMainAttachment(
      createdDocument,
      ["public.tiff"],
      xRayImage
  );
  final xRayService = DecryptedService(
      generateUuid(),
      label: "X-Ray image",
      identifier: [Identifier(system: "cardinal", value: "xRay")],
      content: {
        "en": DecryptedContent(
            documentId: documentWithAttachment.id
        )
      }
  );
  contactWithECG.services.add(xRayService);
  final contactWithImage = await sdk.contact.modifyContact(contactWithECG);
  return contactWithImage;
}

Future<DecryptedContact> addDiagnosis(CardinalSdk sdk, DecryptedContact contactWithImage, Patient patient, String diagnosis) async {
  final healthElement = DecryptedHealthElement(
      generateUuid(),
      descr: diagnosis
  );
  final createdDiagnosis = await sdk.healthElement.createHealthElement(
      await sdk.healthElement.withEncryptionMetadata(healthElement, patient)
  );
  contactWithImage.subContacts = {
    DecryptedSubContact(
        descr: "Diagnosis",
        healthElementId: createdDiagnosis.id
    )
  };
  final contactWithDiagnosis = await sdk.contact.modifyContact(contactWithImage);
  return contactWithDiagnosis;
}

Future<DecryptedContact> closeContact(CardinalSdk sdk, DecryptedContact contactWithDiagnosis) async {
  contactWithDiagnosis.closingDate = currentDateAsYYYYMMddHHmmSS();
  final finalContact = await sdk.contact.modifyContact(contactWithDiagnosis);
  return finalContact;
}