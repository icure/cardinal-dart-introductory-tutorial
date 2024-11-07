import 'package:cardinal_sdk/auth/authentication_method.dart';
import 'package:cardinal_sdk/auth/credentials.dart';
import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/crypto/entities/patient_share_options.dart';
import 'package:cardinal_sdk/crypto/entities/secret_id_share_options.dart';
import 'package:cardinal_sdk/crypto/entities/share_metadata_behaviour.dart';
import 'package:cardinal_sdk/model/embed/access_level.dart';
import 'package:cardinal_sdk/model/health_element.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_sdk/model/requests/requested_permission.dart';
import 'package:cardinal_sdk/model/user.dart';
import 'package:cardinal_sdk/options/storage_options.dart';
import 'package:cardinal_introductory_tutorial/cardinal/create_sdk.dart';
import 'package:cardinal_introductory_tutorial/cardinal/pretty_print.dart';
import 'package:cardinal_introductory_tutorial/cardinal/utils.dart';
import 'dart:developer' as developer;

Future<User> createPatientSdk(CardinalSdk sdk) async {
  final newPatient = DecryptedPatient(
    generateUuid(),
    firstName: "Edmond",
    lastName: "Dantes",
  );
  final patientWithMetadata = await sdk.patient.withEncryptionMetadata(newPatient);
  final createdPatient = await sdk.patient.createPatient(patientWithMetadata);
  final login = "edmond.dantes.${generateUuid().substring(0, 6)}@icure.com";
  final patientUser = User(
      generateUuid(),
      patientId: createdPatient.id,
      login: login,
      email: login
  );
  final createdUser = await sdk.user.createUser(patientUser);
  final loginToken = await sdk.user.getToken(createdUser.id, "login");

  await CardinalSdk.initialize(
      null,
      cardinalUrl,
      AuthenticationMethod.UsingCredentials(Credentials.UsernamePassword(login, loginToken)),
      StorageOptions.PlatformDefault
  );

  await sdk.patient.shareWith(
      createdPatient.id,
      createdPatient,
      options: PatientShareOptions(
          shareSecretIds: SecretIdShareOptionsAllAvailable(true),
          shareEncryptionKey: ShareMetadataBehaviour.ifAvailable,
          requestedPermissions: RequestedPermission.maxWrite
      )
  );

  await createSdk(login, loginToken);

  return createdUser;
}

Future<DecryptedHealthElement> createHealthElementWithoutSharing(CardinalSdk sdk, DecryptedPatient patient) async {
  final healthElement = DecryptedHealthElement(
      generateUuid(),
      descr: "This is some medical context"
  );
  final healthElementWithMetadata = await sdk.healthElement.withEncryptionMetadata(healthElement, patient);
  final createdHealthElement = await sdk.healthElement.createHealthElement(healthElementWithMetadata);
  return createdHealthElement;
}

Future<DecryptedHealthElement> createHealthElementAndShare(CardinalSdk sdk, DecryptedPatient patient) async {
  final newHealthElement = DecryptedHealthElement(
      generateUuid(),
      descr: "This is some other medical context"
  );
  final newHealthElementWithMetadata = await sdk.healthElement.withEncryptionMetadata(
      newHealthElement,
      patient,
      delegates: { patient.id: AccessLevel.write }
  );
  final newCreatedHealthElement = await sdk.healthElement.createHealthElement(newHealthElementWithMetadata);
  return newCreatedHealthElement;
}

Future<bool> shareHealthElementWithPatient(CardinalSdk sdk, DecryptedHealthElement createdHealthElement, DecryptedPatient patient) async {
  try {
    await sdk.healthElement.shareWith(patient.id, createdHealthElement);
    return true;
  } on Exception catch(e) {
    return false;
  }
}

Future<String> getHealthElement(CardinalSdk otherSdk, String healthElementId) async {
  try {
    final healthElement = await otherSdk.healthElement.getHealthElement(healthElementId);
    return prettyPrintHealthElement(healthElement);
  } on Exception catch(e) {
    return "Document is not shared with patient";
  }
}