import 'package:equatable/equatable.dart';

/// Clase base para manejar errores en la aplicación
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Error de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Error de conexión
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet'});
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Error genérico
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Ha ocurrido un error inesperado'});
}
