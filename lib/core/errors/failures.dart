abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure: $message (code: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode});
}
