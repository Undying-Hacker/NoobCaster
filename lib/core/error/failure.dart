import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// General Failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class PermissionFailure extends Failure {}

class InputFailure extends Failure {}