abstract class Either<Error, Value> {
  const Either();

  R when<R>(R Function(Error error) isError, R Function(Value value) isValue);

  bool get isValue;

  bool get isError => !isValue;

  Error get error;

  Value get value;
}

class Left<Error, Value> extends Either<Error, Value> {
  const Left(this.error);

  @override
  final Error error;

  @override
  Value get value {
    throw ForbiddenAccessError('Cannot access [value] for error instance.');
  }

  @override
  R when<R>(
    R Function(Error error) isError,
    R Function(Value value) isValue,
  ) {
    return isError(error);
  }

  @override
  bool get isValue => false;
}

class Right<Error, Value> extends Either<Error, Value> {
  const Right(this.value);

  @override
  final Value value;

  @override
  Error get error {
    throw ForbiddenAccessError('Cannot access [error] for value instance.');
  }

  @override
  R when<R>(
    R Function(Error error) isError,
    R Function(Value value) isValue,
  ) {
    return isValue(value);
  }

  @override
  bool get isValue => true;
}

class ForbiddenAccessError extends Error {
  ForbiddenAccessError(this.message);

  final String message;

  @override
  String toString() => 'ForbiddenAccessError: $message';
}
