import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/filters/contact_filters.dart';
import 'package:cardinal_sdk/filters/patient_filters.dart';
import 'package:cardinal_sdk/filters/service_filters.dart';
import 'package:cardinal_sdk/model/base/identifier.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_sdk/utils/pagination/paginated_list_iterator.dart';

// nameToSearch comes from the UI
Future<PaginatedListIterator<DecryptedPatient>> createPatientIterator(CardinalSdk sdk, String nameToSearch) async {
  final patientIterator = await sdk.patient.filterPatientsBy(
      await PatientFilters.byNameForSelf(nameToSearch)
  );
  return patientIterator;
}

Future<PaginatedListIterator<DecryptedContact>> createContactIterator(CardinalSdk sdk, DecryptedPatient patient) async {
  final contactIterator = sdk.contact.filterContactsBy(
      await ContactFilters.byPatientsForSelf([patient])
  );
  return contactIterator;
}

// choice comes from the UI
Future<PaginatedListIterator<DecryptedService>> createServiceIterator(CardinalSdk sdk, int choice) async {
  Identifier identifier;
  switch(choice) {
    case 0:
      identifier = Identifier(system: "cardinal", value: "bloodPressure");
    case 1:
      identifier = Identifier(system: "cardinal", value: "ecg");
    case 2:
      identifier = Identifier(system: "cardinal", value: "xRay");
    default:
      throw ArgumentError("Invalid choice");
  }

  final serviceIterator = sdk.contact.filterServicesBy(
      await ServiceFilters.byIdentifiersForSelf([identifier])
  );
  return serviceIterator;
}