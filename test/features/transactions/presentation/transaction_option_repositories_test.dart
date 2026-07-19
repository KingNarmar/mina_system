import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/demo/data/repo/demo_tools_repo.dart';
import 'package:mina_system/features/demo/data/repo/demo_workers_repo.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';

void main() {
  group('resolveTransactionOptionRepositories', () {
    test('returns Demo repositories in Demo Mode', () {
      final repositories = resolveTransactionOptionRepositories(isDemo: true);

      expect(repositories.workersRepo, isA<DemoWorkersRepo>());
      expect(repositories.toolsRepo, isA<DemoToolsRepo>());
    });

    test('uses default Live repositories outside Demo Mode', () {
      final repositories = resolveTransactionOptionRepositories(isDemo: false);

      expect(repositories.workersRepo, isNull);
      expect(repositories.toolsRepo, isNull);
    });
  });
}
