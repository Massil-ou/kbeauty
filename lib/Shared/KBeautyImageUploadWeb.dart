// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class KBeautyPickedImage {
  const KBeautyPickedImage({
    required this.name,
    required this.bytes,
    this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String? mimeType;
}

Future<KBeautyPickedImage?> pickKBeautyImage() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp,image/gif';
  input.click();
  await input.onChange.first;

  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) return null;

  final reader = html.FileReader();
  final completer = Completer<void>();
  late final StreamSubscription loadSub;
  late final StreamSubscription errorSub;

  loadSub = reader.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  errorSub = reader.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(Exception('Lecture du fichier impossible.'));
    }
  });

  reader.readAsArrayBuffer(file);
  await completer.future;
  await loadSub.cancel();
  await errorSub.cancel();

  final result = reader.result;
  final bytes = result is ByteBuffer
      ? Uint8List.view(result)
      : result is Uint8List
          ? result
          : null;
  if (bytes == null || bytes.isEmpty) return null;

  return KBeautyPickedImage(
    name: file.name,
    bytes: bytes,
    mimeType: file.type.isEmpty ? null : file.type,
  );
}
