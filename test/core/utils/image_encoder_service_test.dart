import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portafolio_project/core/utils/image_encoder_service.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('image_encoder_service_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('encodes a file to Base64', () async {
    final file = File('${tempDir.path}/sample.bin');
    final data = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
    await file.writeAsBytes(data);

    final encoder = ImageEncoderService(maxFileSizeBytes: 1024);
    final encoded = await encoder.encodeFile(file);

    expect(encoded, base64Encode(data));
  });

  test('throws if file is larger than allowed max', () async {
    final file = File('${tempDir.path}/large.bin');
    final data = List<int>.generate(32, (index) => index);
    await file.writeAsBytes(data);

    final encoder = ImageEncoderService(maxFileSizeBytes: 16);
    expect(
      () async => await encoder.encodeFile(file),
      throwsA(isA<ImageEncodingException>()),
    );
  });

  test('throws when target file does not exist', () {
    final encoder = ImageEncoderService();
    final missing = File('${tempDir.path}/missing.bin');

    expect(
      () async => await encoder.encodeFile(missing),
      throwsA(isA<ImageEncodingException>()),
    );
  });
}
