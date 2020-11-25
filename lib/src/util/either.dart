abstract class Either<Error, Value> {
  const Either();

  R when<R>(R Function(Error error) isError, R Function(Value value) isValue);

  bool get isValue;

  bool get isError => !isValue;
}

class Left<Error, Value> extends Either<Error, Value> {
  const Left(this.value);

  final Error value;

  @override
  R when<R>(
    R Function(Error error) isError,
    R Function(Value value) isValue,
  ) {
    return isError(value);
  }

  @override
  bool get isValue => false;
}

class Right<Error, Value> extends Either<Error, Value> {
  const Right(this.value);

  final Value value;

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
