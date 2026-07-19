import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_image_reference.dart';

void main() {
  group('classifyTransactionImageReference', () {
    test('accepts a valid HTTPS URL', () {
      final reference = classifyTransactionImageReference(
        ' https://example.com/proof.jpg?token=signed ',
      );

      expect(reference.kind, TransactionImageReferenceKind.secureRemoteUrl);
      expect(reference.value, 'https://example.com/proof.jpg?token=signed');
      expect(reference.isSecureRemoteUrl, isTrue);
      expect(reference.isRejectedRemoteUrl, isFalse);
    });

    test('rejects an HTTP URL', () {
      final reference = classifyTransactionImageReference(
        'http://example.com/proof.jpg',
      );

      expect(reference.kind, TransactionImageReferenceKind.insecureRemoteUrl);
      expect(reference.isSecureRemoteUrl, isFalse);
      expect(reference.isRejectedRemoteUrl, isTrue);
    });

    test('rejects malformed HTTPS and unsupported schemes', () {
      expect(
        classifyTransactionImageReference('https:proof.jpg').kind,
        TransactionImageReferenceKind.unsupportedRemoteUrl,
      );
      expect(
        classifyTransactionImageReference('ftp://example.com/proof.jpg').kind,
        TransactionImageReferenceKind.unsupportedRemoteUrl,
      );
      expect(
        classifyTransactionImageReference('data:image/png;base64,abc').kind,
        TransactionImageReferenceKind.unsupportedRemoteUrl,
      );
    });

    test('keeps Windows local paths as paths', () {
      final backslashPath = classifyTransactionImageReference(
        r'C:\Users\Mina\Pictures\proof.jpg',
      );
      final slashPath = classifyTransactionImageReference(
        'D:/proofs/proof.jpg',
      );

      expect(backslashPath.kind, TransactionImageReferenceKind.path);
      expect(slashPath.kind, TransactionImageReferenceKind.path);
    });

    test('keeps Unix and UNC local paths as paths', () {
      expect(
        classifyTransactionImageReference('/tmp/proof.jpg').kind,
        TransactionImageReferenceKind.path,
      );
      expect(
        classifyTransactionImageReference(r'\\server\share\proof.jpg').kind,
        TransactionImageReferenceKind.path,
      );
    });

    test('keeps company-scoped storage object paths as paths', () {
      final reference = classifyTransactionImageReference(
        'company-1/transactions/trx-1/proof.jpg',
      );

      expect(reference.kind, TransactionImageReferenceKind.path);
      expect(reference.isRejectedRemoteUrl, isFalse);
    });

    test('reports an empty value', () {
      final reference = classifyTransactionImageReference('   ');

      expect(reference.kind, TransactionImageReferenceKind.empty);
      expect(reference.value, isEmpty);
    });
  });
}
