import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageCompressionResult {
  const ImageCompressionResult({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
}

class ImageCompressionService {
  const ImageCompressionService();

  static const int defaultMaxDimension = 1600;
  static const int companyLogoMaxDimension = 800;
  static const int companyLogoQuality = 90;

  Future<ImageCompressionResult> compressImageFile(
    File sourceFile, {
    int quality = 85,
    int maxDimension = defaultMaxDimension,
  }) async {
    if (!sourceFile.existsSync()) {
      throw StateError('Source file does not exist: ${sourceFile.path}');
    }

    final extension = _extensionFor(sourceFile.path);
    final originalBytes = await sourceFile.readAsBytes();

    return compressImageBytes(
      sourceBytes: originalBytes,
      fileExtension: extension,
      quality: quality,
      maxDimension: maxDimension,
      sourceDescription: sourceFile.path,
    );
  }

  Future<ImageCompressionResult> compressImageBytes({
    required Uint8List sourceBytes,
    required String fileExtension,
    int quality = 85,
    int maxDimension = defaultMaxDimension,
    String sourceDescription = 'selected image',
  }) async {
    if (sourceBytes.isEmpty) {
      throw StateError('Image file is empty: $sourceDescription');
    }

    if (quality < 1 || quality > 100) {
      throw StateError('Image compression quality must be between 1 and 100.');
    }

    if (maxDimension < 300) {
      throw StateError('Image max dimension must be at least 300 pixels.');
    }

    final extension = _cleanExtension(fileExtension);

    if (extension == 'pdf') {
      throw StateError('PDF files should not be image-compressed.');
    }

    _validateSupportedImageExtension(extension);

    final decodedImage = img.decodeImage(sourceBytes);

    if (decodedImage == null) {
      throw StateError('Unable to decode image file: $sourceDescription');
    }

    final shouldResize = _shouldResize(
      decodedImage,
      maxDimension: maxDimension,
    );

    final resizedImage = shouldResize
        ? _resizeImage(decodedImage, maxDimension: maxDimension)
        : decodedImage;

    final encodedResult = _encodeCompressedImage(
      image: resizedImage,
      originalExtension: extension,
      quality: quality,
    );

    if (!shouldResize && encodedResult.bytes.length >= sourceBytes.length) {
      return ImageCompressionResult(
        bytes: sourceBytes,
        extension: extension,
        contentType: _contentTypeFor(extension),
      );
    }

    return encodedResult;
  }

  bool _shouldResize(
    img.Image image, {
    required int maxDimension,
  }) {
    return max(image.width, image.height) > maxDimension;
  }

  img.Image _resizeImage(
    img.Image image, {
    required int maxDimension,
  }) {
    final largestSide = max(image.width, image.height);
    final scale = maxDimension / largestSide;
    final targetWidth = max(1, (image.width * scale).round());
    final targetHeight = max(1, (image.height * scale).round());

    return img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
    );
  }

  ImageCompressionResult _encodeCompressedImage({
    required img.Image image,
    required String originalExtension,
    required int quality,
  }) {
    switch (originalExtension) {
      case 'jpg':
      case 'jpeg':
        return ImageCompressionResult(
          bytes: Uint8List.fromList(img.encodeJpg(image, quality: quality)),
          extension: 'jpg',
          contentType: 'image/jpeg',
        );

      case 'png':
        return ImageCompressionResult(
          bytes: Uint8List.fromList(img.encodePng(image, level: 6)),
          extension: 'png',
          contentType: 'image/png',
        );

      case 'webp':
        return ImageCompressionResult(
          bytes: Uint8List.fromList(img.encodeJpg(image, quality: quality)),
          extension: 'jpg',
          contentType: 'image/jpeg',
        );

      default:
        throw StateError(
          'Unsupported image file type: .$originalExtension. Supported types are jpg, jpeg, png, and webp.',
        );
    }
  }

  void _validateSupportedImageExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return;
      default:
        throw StateError(
          'Unsupported image file type: .$extension. Supported types are jpg, jpeg, png, and webp.',
        );
    }
  }

  String _extensionFor(String path) {
    final cleanPath = path.split('?').first;
    final dotIndex = cleanPath.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == cleanPath.length - 1) {
      throw StateError('Image file must have an extension.');
    }

    return _cleanExtension(cleanPath.substring(dotIndex + 1));
  }

  String _cleanExtension(String extension) {
    return extension.replaceAll('.', '').toLowerCase().trim();
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw StateError(
        'Unsupported image file type: .$extension. Supported types are jpg, jpeg, png, and webp.',
      ),
    };
  }
}