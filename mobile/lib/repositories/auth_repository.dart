abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? verificationCode,
  });
  Future<void> logout();
  Future<String?> getToken();
  Future<Map<String, dynamic>?> getUserInfo();
  Future<bool> isLoggedIn();
  Future<Map<String, String>> getAuthHeaders();
  Future<void> discoverBaseUrl();
  String get baseUrl;
  Future<void> setBaseUrl(String url);
}
