// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'auth_repository.dart';
import 'mock_auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_info';
  
  String _baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api'; 

  final List<String> _candidateUrls = [
    if (kIsWeb) 'http://localhost:8000/api',
    'http://10.0.2.2:8000/api',
    if (!kIsWeb) 'http://localhost:8000/api',
    'http://192.168.0.145:8000/api',
    'http://192.168.144.1:8000/api',
    'http://192.168.1.145:8000/api',
  ];

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_base_url', url);
  }

  @override
  Future<void> discoverBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _baseUrl = savedUrl;
        print('[AUTO-DISCOVERY] Using saved custom server URL: $_baseUrl');
        return;
      }
    } catch (_) {}

    print('[AUTO-DISCOVERY] Probing active backend candidate URLs...');
    
    final List<Future<String?>> probes = _candidateUrls.map((url) async {
      try {
        final client = http.Client();
        final response = await client.get(
          Uri.parse('$url/local-ip'),
        ).timeout(const Duration(milliseconds: 1500));
        
        if (response.statusCode == 200) {
          return url;
        }
      } catch (_) {}
      return null;
    }).toList();

    try {
      final results = await Future.wait(probes);
      for (final res in results) {
        if (res != null) {
          _baseUrl = res;
          print('[AUTO-DISCOVERY] Detected active backend at: $_baseUrl');
          return;
        }
      }
    } catch (e) {
      print('[AUTO-DISCOVERY] Probe failed with error: $e');
    }
    if (kIsWeb) {
      _baseUrl = 'http://localhost:8000/api';
      return;
    }
    print('[AUTO-DISCOVERY] No active backend detected. Falling back to default: $_baseUrl');
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user));

        return {'success': true, 'user': user};
      } else {
        String errorMsg = 'Identifiants incorrects';
        try {
          errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg;
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      // Fallback to offline mock repository when backend server is unreachable
      final mock = MockAuthRepository();
      return mock.login(username, password);
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
