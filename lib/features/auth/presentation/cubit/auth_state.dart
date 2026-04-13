import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final bool isGuest;
  final UserModel? user;

  const AuthAuthenticated({this.isGuest = false, this.user});

  @override
  List<Object?> get props => [isGuest, user];
}

class AuthUnauthenticated extends AuthState {}

class AuthCodeSent extends AuthState {
  final String phoneNumber;
  const AuthCodeSent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
