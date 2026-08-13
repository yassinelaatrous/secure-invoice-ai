// ignore_for_file: avoid_print
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  String _baseUrl = 'http://offline-mock.local';
  Map<String, dynamic>? _currentUser;
  String? _token;

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
  }

  @override
  Future<void> discoverBaseUrl() async {
    print('[OFFLINE MOCK] Security Kernel active in Sandbox mode.');
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final normalizedUser = username.trim().toLowerCase();
    
    // Support standard security roles
    String role = 'client';
    String name = 'Client User';
    String tenantId = 'tenant_alpha';
    bool mfaRequired = false;

    if (normalizedUser == 'admin' || normalizedUser == 'admin@demo.com') {
      role = 'admin';
      name = 'Yassine Admin';
      tenantId = 'cabinet_internal';
      mfaRequired = true;
    } else if (normalizedUser == 'expert' || normalizedUser == 'expert@demo.com' || normalizedUser == 'accountant') {
      role = 'expert_comptable';
      name = 'Khaled Expert';
      tenantId = 'cabinet_internal';
      mfaRequired = true;
    } else if (normalizedUser == 'comptable' || normalizedUser == 'comptable@demo.com') {
      role = 'comptable';
      name = 'Mohamed Comptable';
      tenantId = 'cabinet_internal';
      mfaRequired = true;
    } else if (normalizedUser == 'assistant' || normalizedUser == 'assistant@demo.com') {
      role = 'assistant_comptable';
      name = 'Sarra Assistant';
      tenantId = 'cabinet_internal';
      mfaRequired = true;
    } else if (normalizedUser == 'auditeur' || normalizedUser == 'auditeur@demo.com') {
      role = 'auditeur';
      name = 'Sami Auditeur';
      tenantId = 'cabinet_internal';
      mfaRequired = true;
    } else if (normalizedUser == 'client' || normalizedUser == 'client@demo.com') {
      role = 'client';
      name = 'Yassine Client';
      tenantId = 'tenant_alpha';
      mfaRequired = false;
    } else {
      return {
        'success': false, 
        'error': 'Identifiants invalides.'
      };
    }

    _currentUser = {
      'id': role == 'client' ? 1 : role == 'assistant_comptable' ? 2 : role == 'comptable' ? 3 : role == 'expert_comptable' ? 4 : role == 'auditeur' ? 5 : 6,
      'email': '$role@demo.com',
      'nom': name,
      'role': role,
      'tenant_id': tenantId,
      'mfa_enabled': mfaRequired,
    };
    _token = 'mock_jwt_token_for_$role';
    
    return {'success': true, 'user': _currentUser};
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? verificationCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final normalizedRole = role.toLowerCase();
    
    String assignedRole = 'client';
    bool mfaRequired = false;
    String tenantId = 'tenant_${email.split('@').first}';

    if (normalizedRole.contains('admin')) {
      assignedRole = 'admin';
      mfaRequired = true;
      tenantId = 'cabinet_internal';
    } else if (normalizedRole.contains('comptable') || normalizedRole.contains('accountant')) {
      assignedRole = 'comptable';
      mfaRequired = true;
      tenantId = 'cabinet_internal';
    } else if (normalizedRole.contains('audit')) {
      assignedRole = 'auditeur';
      mfaRequired = true;
      tenantId = 'cabinet_internal';
    }

    // Verify Third Party Code / Internal Admin Verification Token
    bool is3rdPartyVerified = verificationCode != null && verificationCode.isNotEmpty;
    bool isAdminVerified = assignedRole == 'client' || (verificationCode == 'ADMIN-2026' || verificationCode == '123456');

    if (!isAdminVerified && assignedRole != 'client') {
      return {
        'success': false,
        'error': 'Le rôle interne ($assignedRole) exige un code de vérification administrateur valide (ex: ADMIN-2026).',
      };
    }

    _currentUser = {
      'id': DateTime.now().millisecondsSinceEpoch % 10000,
      'email': email,
      'nom': fullName,
      'role': assignedRole,
      'company_name': companyName ?? 'Entreprise Indépendante',
      'tenant_id': tenantId,
      'mfa_enabled': mfaRequired,
      'verified_via_3rd_party': is3rdPartyVerified,
      'verified_by_admin': isAdminVerified,
      'created_at': DateTime.now().toIso8601String(),
    };
    _token = 'mock_jwt_token_registered_${_currentUser!['id']}';
    
    return {'success': true, 'user': _currentUser};
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    return _currentUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _token != null;
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
