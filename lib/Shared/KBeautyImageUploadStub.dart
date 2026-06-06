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

Future<KBeautyPickedImage?> pickKBeautyImage() async => null;
