import '../repositories/auth_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/mock_invoice_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Inject the offline mock implementations for client-side security kernel
  final AuthRepository authRepository = MockAuthRepository();
  final InvoiceRepository invoiceRepository = MockInvoiceRepository();
}

// Global service locator instance
final locator = ServiceLocator();
