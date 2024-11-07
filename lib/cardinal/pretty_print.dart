import 'package:cardinal_sdk/model/code.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/document.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/health_element.dart';
import 'package:cardinal_sdk/model/patient.dart';

String printLine(String line, int maxLen) {
  return '$line${' ' * (maxLen - line.length + 1)}\n';
}

String printDivider(int maxLen) {
  return '${'-' * maxLen}\n';
}

String prettyPrintPatient(Patient patient) {
  final id = 'id: ${patient.id}';
  final rev = 'rev: ${patient.rev ?? "rev is missing"}';
  final name = '${patient.firstName} ${patient.lastName}';
  final dateOfBirth = 'Birthday: ${patient.dateOfBirth}';

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(10));
  buffer.write("$name\n");
  buffer.write(printDivider(10));
  buffer.write("$id\n");
  buffer.write("$rev\n");
  if (patient.dateOfBirth != null) {
    buffer.write("$dateOfBirth\n");
  }
  buffer.write(printDivider(10));
  return buffer.toString();
}

String prettyPrintDocument(Document document) {
  final id = 'id: ${document.id}';
  final rev = 'rev: ${document.rev ?? "rev is missing"}';
  final name = '${document.name}';

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(10));
  buffer.write("$name\n");
  buffer.write(printDivider(10));
  buffer.write("$id\n");
  buffer.write("$rev\n");
  buffer.write(printDivider(10));
  return buffer.toString();
}

String prettyPrintHealthElement(HealthElement healthElement) {
  final id = 'id: ${healthElement.id}';
  final rev = 'rev: ${healthElement.rev ?? "rev is missing"}';
  final description = '${healthElement.descr}';

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(10));
  buffer.write("$description\n");
  buffer.write(printDivider(10));
  buffer.write("$id\n");
  buffer.write("$rev\n");
  buffer.write(printDivider(10));
  return buffer.toString();
}

String prettyPrintCode(Code code) {
  final label = '${code.label?["en"]} v${code.version}';
  final codeType = 'Type: ${code.type}';
  final codeCode = 'Code: ${code.code}';
  final maxLen = [label, codeType, codeCode].map((str) => str.length).reduce((a, b) => a > b ? a : b);

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(maxLen));
  buffer.write(printLine(label, maxLen));
  buffer.write(printDivider(maxLen));
  buffer.write(printLine(codeType, maxLen));
  buffer.write(printLine(codeCode, maxLen));
  buffer.write(printDivider(maxLen));
  return buffer.toString();
}

String prettyPrintContact(Contact contact) {
  final id = 'id: ${contact.id}';
  final rev = 'rev: ${contact.rev ?? "rev is missing"}';
  final description = '${contact.descr}';
  final openingDate = 'Opened: ${contact.openingDate}';
  final closingDate = 'Closed: ${contact.closingDate}';
  final diagnosis = diagnosisOf(contact);
  final services = contact.services.map((service) => contentOf(service)).where((content) => content != null).toList();

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(10));
  buffer.write("$description\n");
  buffer.write(printDivider(10));
  if (diagnosis != null) {
    buffer.write("$diagnosis\n");
    buffer.write(printDivider(10));
  }
  buffer.write("$id\n");
  buffer.write("$rev\n");
  buffer.write("$openingDate\n");
  if (contact.closingDate != null) {
    buffer.write("$closingDate\n");
  }
  buffer.write(printDivider(10));
  for (var service in services) {
    buffer.write("$service\n");
  }
  if (services.isNotEmpty) {
    buffer.write(printDivider(10));
  }
  return buffer.toString();
}

String prettyPrintService(Service service) {
  final id = 'id: ${service.id}';
  final content = contentOf(service);
  final tags = 'Tags: ${service.tags.map((tag) => tag.id ?? "").join(", ")}';
  final maxLen = [id, content, tags].where((str) => str != null).map((str) => str!.length).reduce((a, b) => a > b ? a : b);

  StringBuffer buffer = StringBuffer();
  buffer.write(printDivider(10));
  buffer.write("$id\n");
  if (content != null) {
    buffer.write("$content\n");
  }
  if (service.tags.isNotEmpty) {
    buffer.write("$tags\n");
  }
  buffer.write(printDivider(10));
  return buffer.toString();
}

String? diagnosisOf(Contact contact) {
  return contact.subContacts.isNotEmpty
      ? 'Diagnosis in healthElement: ${contact.subContacts.first.healthElementId}'
      : null;
}

String? contentOf(Service service) {
  final firstContent = service.content.values.isNotEmpty ? service.content.values.first : null;
  if (firstContent == null) return null;

  if (firstContent.measureValue != null) {
    return '${service.label}: ${firstContent.measureValue?.value} ${firstContent.measureValue?.unit}';
  } else if (firstContent.timeSeries != null) {
    return '${service.label}: ${firstContent.timeSeries?.samples?.first?.join(" ")}';
  } else if (firstContent.documentId != null) {
    return '${service.label}: in Document with id ${firstContent.documentId}';
  } else {
    return null;
  }
}
