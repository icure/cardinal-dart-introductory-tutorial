import 'dart:math';

import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/filters/code_filters.dart';
import 'package:cardinal_sdk/filters/service_filters.dart';
import 'package:cardinal_sdk/model/base/code_stub.dart';
import 'package:cardinal_sdk/model/code.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/embed/content.dart';
import 'package:cardinal_sdk/model/embed/measure.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_sdk/utils/pagination/paginated_list_iterator.dart';
import 'package:cardinal_introductory_tutorial/cardinal/utils.dart';

Future<PaginatedListIterator<Code>> createCodeIterator(CardinalSdk sdk) async {
  final existing = await sdk.code.getCodes(
      ["INTERNAL|ANALYSIS|1", "SNOMED|45007003|1", "SNOMED|38341003|1", "SNOMED|2004005|1"]
  );

  if(existing.isEmpty) {
    await sdk.code.createCode(Code(
        "INTERNAL|ANALYSIS|1",
        type: "INTERNAL",
        code: "ANALYSIS",
        version: "1",
        label: {"en": "Internal analysis code"}
    ));
    await sdk.code.createCodes([
      Code(
          "SNOMED|45007003|1",
          type: "SNOMED",
          code: "45007003",
          version: "1",
          label: {"en": "Low blood pressure"}
      ),
      Code(
          "SNOMED|38341003|1",
          type: "SNOMED",
          code: "38341003",
          version: "1",
          label: {"en": "High blood pressure"}
      ),
      Code(
          "SNOMED|2004005|1",
          type: "SNOMED",
          code: "2004005",
          version: "1",
          label: {"en": "Normal blood pressure"}
      )
    ]);
  }

  final codeIterator = await sdk.code.filterCodesBy(
      await CodeFilters.byLanguageTypeLabelRegion(
        "en",
        "SNOMED",
        label: "blood",
      )
  );
  return codeIterator;
}

Future<DecryptedContact> createContactWithCode(CardinalSdk sdk, Code selectedCode) async {
  final patient = await sdk.patient.createPatient(
      await sdk.patient.withEncryptionMetadata(
          DecryptedPatient(
            generateUuid(),
            firstName: "Annabelle",
            lastName: "Hall",
          )
      )
  );

  final contact = DecryptedContact(
      generateUuid(),
      descr: "Blood pressure measurement",
      openingDate: currentDateAsYYYYMMddHHmmSS(),
      services: {
        DecryptedService(
            generateUuid(),
            label: "Blood pressure",
            content: {
              "en": DecryptedContent(
                  measureValue: Measure(
                      value: (80 + Random().nextInt(41)).toDouble(),
                      unit: "mmHg"
                  )
              )
            },
            tags: {
              CodeStub(
                  id: selectedCode.id,
                  type: selectedCode.type,
                  code: selectedCode.code,
                  version: selectedCode.version
              )
            }
        )
      }
  );
  final createdContact = await sdk.contact.createContact(
      await sdk.contact.withEncryptionMetadata(contact, patient)
  );
  return createdContact;
}

Future<PaginatedListIterator<DecryptedService>> getServiceIteratorForCode(CardinalSdk sdk, Code selectedCode) async {
  final serviceIterator = await sdk.contact.filterServicesBy(
      await ServiceFilters.byTagAndValueDateForSelf(
          selectedCode.type!,
          tagCode: selectedCode.code
      )
  );
  return serviceIterator;
}