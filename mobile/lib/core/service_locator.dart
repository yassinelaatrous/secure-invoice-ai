import '../repositories/auth_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/http_auth_repository.dart';
import '../repositories/http_invoice_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Inject the HTTP implementations of the repositories
  final AuthRepository authRepository = HttpAuthRepository();
  final InvoiceRepository invoiceRepository = HttpInvoiceRepository();
}

// Global service locator instance
final locator = ServiceLocator();
