/// Resultの勉強
sealed class Result<S, E extends Exception> {
  const Result();

  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  });

  Result<T, E> map<T>(T Function(S value) transform) {
    return fold(
      onSuccess: (value) => Success<T, E>(transform(value)),
      onFailure: (error) => Failure<T, E>(error),
    );
  }
}

final class Success<S, E extends Exception> extends Result<S, E> {
  const Success(this.value);
  final S value;

  @override
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  }) {
    return onSuccess(value);
  }
}

final class Failure<S, E extends Exception> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;

  @override
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  }) {
    return onFailure(exception);
  }
}

Future<Result<int, Exception>> getTest() async {
  var x = 1;
  try {
    return Success(x);
  } on Exception catch (e) {
    return Failure(e);
  }
}

void main() async {
  var hoge = await getTest();
  hoge.map((value) => value * 2);
  hoge.fold(onSuccess: (_) => print("OK"), onFailure: (_) => print("NG"));
}
