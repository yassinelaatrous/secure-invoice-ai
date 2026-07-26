import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/service_locator.dart';
import '../models/invoice.dart';
import 'invoice_repository.dart';
import 'mock_invoice_repository.dart';

class HttpInvoiceRepository implements InvoiceRepository {
  @override
  Future<List<Invoice>> getInvoices() async {
    try {
      final headers = await locator.authRepository.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${locator.authRepository.baseUrl}/factures'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des factures (Code ${response.statusCode})');
      }
    } catch (e) {
      return MockInvoiceRepository().getInvoices();
    }
  }

  @override
  Future<Invoice> getInvoiceDetails(int id) async {
    try {
      final headers = await locator.authRepository.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${locator.authRepository.baseUrl}/factures/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Facture introuvable (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadInvoice(String filePath) async {
    try {
      final token = await locator.authRepository.getToken();
      final uri = Uri.parse('${locator.authRepository.baseUrl}/upload');
      
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur OCR (Code ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de transmission : $e');
    }
  }

  @override
  Future<Invoice> createFacture(Map<String, dynamic> factureData) async {
    try {
      final headers = await locator.authRepository.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${locator.authRepository.baseUrl}/factures'),
        headers: headers,
        body: jsonEncode(factureData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur de création (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  @override
  Future<void> updateInvoiceStatus(int id, String status) async {
    try {
      final headers = await locator.authRepository.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${locator.authRepository.baseUrl}/factures/$id/statut'),
        headers: headers,
        body: jsonEncode({'statut': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du changement de statut (Code ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de requête : $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final invoices = await getInvoices();
      
      final total = invoices.length;
      final totalTtc = invoices.fold<double>(0, (sum, inv) => sum + inv.montantTtc);
      final validated = invoices.where((inv) => inv.statut == 'validee' || inv.statut == 'controlee').length;
      final pending = invoices.where((inv) => inv.statut == 'brouillon' || inv.statut == 'nouveau').length;
      final avgFraud = total > 0 ? invoices.fold<double>(0, (sum, inv) => sum + inv.fraudScore) / total : 0.0;
      
      return {
        'total_factures': total,
        'total_montant': totalTtc,
        'factures_validees': validated,
        'factures_en_attente': pending,
        'risque_moyen': avgFraud,
        'invoices': invoices,
      };
    } catch (e) {
      return MockInvoiceRepository().getDashboardStats();
    }
  }
}
