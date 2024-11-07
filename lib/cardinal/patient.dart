import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:flutter_playground/cardinal/utils.dart';

Future<DecryptedPatient> createPatient(CardinalSdk sdk, String firstName, String lastName) async {
  final patient = DecryptedPatient(
    generateUuid(),
    firstName: firstName,
    lastName: lastName,
  );
  final patientWithMetadata = await sdk.patient.withEncryptionMetadata(patient);
  final createdPatient = await sdk.patient.createPatient(patientWithMetadata);
  return createdPatient;
}

Future<DecryptedPatient> updatePatientWithDateOfBirthAndRetrieve(CardinalSdk sdk, DecryptedPatient createdPatient, int dateAsYYYYMMDD) async {
  createdPatient.dateOfBirth = dateAsYYYYMMDD;
  final updatedPatient = await sdk.patient.modifyPatient(createdPatient);

  final retrievedPatient = sdk.patient.getPatient(updatedPatient.id);

  return retrievedPatient;
}