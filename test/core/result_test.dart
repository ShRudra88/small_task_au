import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success returns data and handles fold correctly', () {
      const result = Result<String>.success('Hello World');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('Hello World'));
      expect(result.failureOrNull, isNull);

      final folded = result.fold(
        (failure) => 'Error: ${failure.message}',
        (data) => 'Success: $data',
      );
      expect(folded, equals('Success: Hello World'));
    });

    test('Failure returns failure and handles fold correctly', () {
      const result = Result<String>.failure(ServerFailure('Server Error'));

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, isA<ServerFailure>());

      final folded = result.fold(
        (failure) => 'Error: ${failure.message}',
        (data) => 'Success: $data',
      );
      expect(folded, equals('Error: Server Error'));
    });
  });
}
