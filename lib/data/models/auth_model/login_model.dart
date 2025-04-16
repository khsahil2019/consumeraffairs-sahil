class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final String token;
  final bool isFirstLogin;
  final int id;
  final String role;

  LoginData({
    required this.token,
    required this.isFirstLogin,
    required this.id,
    required this.role,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      isFirstLogin: json['is_first_login'],
      id: json['id'],
      role: json['role'],
    );
  }
}
