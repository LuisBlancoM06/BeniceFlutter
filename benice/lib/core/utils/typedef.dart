import 'package:dartz/dartz.dart';
import 'failure.dart';

/// Tipo de resultado que puede ser un Failure o un valor exitoso
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Tipo de resultado para operaciones que no devuelven valor
typedef ResultVoid = ResultFuture<void>;
