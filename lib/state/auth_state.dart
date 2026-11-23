import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/mock_data.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool isNewUser;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.isNewUser = false,
  });

  bool get isTestAccount {
    if (user == null) return false;
    return AuthNotifier.isTestAccount(email: user!.email, phone: user!.phone);
  }

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isNewUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  // Test Account Constants per specifications
  static const String testAccountName = 'Rahul Sharma';
  static const String testAccountEmail = 'sharahul@ledgerly.in';
  static const String testAccountPhone = '9876543210';
  static const String testAccountPhoneAlt = '1234567890';

  /// In-memory persistent user registry across sign-ins
  static final Map<String, UserModel> _registeredUsers = {
    testAccountPhone: MockData.initialUser,
    testAccountPhoneAlt: MockData.initialUser,
    testAccountEmail.toLowerCase(): MockData.initialUser,
  };

  /// Normalizes phone numbers (strips spaces, punctuation, leading country code)
  static String normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    return digits;
  }

  /// Checks if given credentials correspond to the designated test account
  static bool isTestAccount({String? email, String? phone}) {
    if (email != null && email.trim().toLowerCase() == testAccountEmail) {
      return true;
    }
    if (phone != null) {
      final norm = normalizePhone(phone);
      if (norm == testAccountPhone || norm == testAccountPhoneAlt) {
        return true;
      }
    }
    return false;
  }

  @override
  AuthState build() {
    // Default to unauthenticated state with test user pre-configured for instant demo login
    return const AuthState(
      user: MockData.initialUser,
      isAuthenticated: false,
      isNewUser: false,
    );
  }

  /// Searches for an existing user by normalized phone or email
  UserModel? findUser(String query) {
    final clean = query.trim().toLowerCase();
    final normPhone = normalizePhone(query);

    if (isTestAccount(email: clean, phone: query)) {
      return MockData.initialUser;
    }

    if (_registeredUsers.containsKey(normPhone)) {
      return _registeredUsers[normPhone];
    }
    if (_registeredUsers.containsKey(clean)) {
      return _registeredUsers[clean];
    }

    // Scan values by phone/email
    for (final u in _registeredUsers.values) {
      if (normalizePhone(u.phone) == normPhone ||
          u.email.trim().toLowerCase() == clean) {
        return u;
      }
    }
    return null;
  }

  Future<bool> sendOtp(String phoneOrEmail) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final existing = findUser(phoneOrEmail);
    state = state.copyWith(
      isLoading: false,
      user: existing ?? UserModel(
        id: 'user_temp',
        firstName: '',
        lastName: '',
        email: phoneOrEmail.contains('@') ? phoneOrEmail : '',
        phone: phoneOrEmail,
      ),
    );
    return true;
  }

  Future<bool> verifyOtp(String otp, {required String input}) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));

    // 1. Check if test account
    if (isTestAccount(email: input, phone: input)) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: MockData.initialUser,
        isNewUser: false,
      );
      return true;
    }

    // 2. Check if existing registered user
    final existing = findUser(input);
    if (existing != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: existing,
        isNewUser: false,
      );
      return true;
    }

    // 3. Fallback: If OTP is valid (123456 or non-empty), create standard user session
    final norm = normalizePhone(input);
    final fallbackUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      firstName: 'New',
      lastName: 'User',
      email: input.contains('@') ? input : 'user_$norm@ledgerly.in',
      phone: norm.isNotEmpty ? norm : input,
    );

    _registeredUsers[fallbackUser.phone] = fallbackUser;
    _registeredUsers[fallbackUser.email.toLowerCase()] = fallbackUser;

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: fallbackUser,
      isNewUser: true,
    );
    return true;
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));

    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();

    // Check if test account details were entered in signup
    if (isTestAccount(email: cleanEmail, phone: cleanPhone)) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: MockData.initialUser,
        isNewUser: false,
      );
      return true;
    }

    // Create fresh user account with 0 pre-data
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: cleanEmail,
      phone: cleanPhone,
    );

    // Save in registry
    final normPhone = normalizePhone(cleanPhone);
    _registeredUsers[normPhone] = newUser;
    _registeredUsers[cleanEmail.toLowerCase()] = newUser;

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: newUser,
      isNewUser: true, // Triggers feature tour!
    );
    return true;
  }

  void markTourCompleted() {
    state = state.copyWith(isNewUser: false);
  }

  void logout() {
    state = const AuthState(
      user: null,
      isAuthenticated: false,
      isNewUser: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
