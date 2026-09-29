import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/mock_data.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(
      user: MockData.initialUser,
      isAuthenticated: false,
    );
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));
    state = state.copyWith(
      isLoading: false,
      user: (state.user ?? MockData.initialUser).copyWith(phone: phone),
    );
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
    );
    return true;
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: newUser,
    );
    return true;
  }

  void logout() {
    state = const AuthState(
      user: MockData.initialUser,
      isAuthenticated: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
