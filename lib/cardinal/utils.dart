import 'dart:math';

String generateUuid() {
  final random = Random.secure();

  String generateHex(int count) {
    return List<int>.generate(count, (_) => random.nextInt(256))
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join('');
  }

  String generateTimeLow() {
    return generateHex(4);
  }

  String generateTimeMid() {
    return generateHex(2);
  }

  String generateTimeHiAndVersion() {
    final timeHi = generateHex(2);
    final hiAndVersion = (int.parse(timeHi, radix: 16) & 0x0fff) | 0x4000;
    return hiAndVersion.toRadixString(16).padLeft(4, '0');
  }

  String generateClockSeqAndReserved() {
    final clockSeq = generateHex(2);
    final clockSeqRes = (int.parse(clockSeq, radix: 16) & 0x3fff) | 0x8000;
    return clockSeqRes.toRadixString(16).padLeft(4, '0');
  }

  String generateNode() {
    return generateHex(6);
  }

  return '${generateTimeLow()}-${generateTimeMid()}-${generateTimeHiAndVersion()}-${generateClockSeqAndReserved()}-${generateNode()}';
}

int currentDateAsYYYYMMddHHmmSS() {
  DateTime now = DateTime.now();

  final dateAsString = '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
  return int.parse(dateAsString);
}