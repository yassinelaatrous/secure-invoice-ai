import 'dart:convert';

class Invoice {
  final int id;
  final String numero;
  final String fournisseur;
  final DateTime dateFacture;
  final DateTime dateReception;
  final String devise;
  final double montantHt;
  final double tva;
  final double montantTtc;
  final String iban;
  final String statut;
  final double fraudScore;
  final double confidenceScore;
  final String? imagePath;
  final bool? conformiteValide;
  final String? conformiteDetails;
  final String? fraudeJustification;
  final List<dynamic>? fraudeAlertes;
  final int? creeParId;
  final int? valideParId;
  final String? creeParNom;
  final String? tenantId;
  final String? mimeType;
  final bool? isScannedSafe;

  Invoice({
    required this.id,
    required this.numero,
    required this.fournisseur,
    required this.dateFacture,
    required this.dateReception,
    required this.devise,
    required this.montantHt,
    required this.tva,
    required this.montantTtc,
    required this.iban,
    required this.statut,
    required this.fraudScore,
    required this.confidenceScore,
    this.imagePath,
    this.conformiteValide,
    this.conformiteDetails,
    this.fraudeJustification,
    this.fraudeAlertes,
    this.creeParId,
    this.valideParId,
    this.creeParNom,
    this.tenantId,
    this.mimeType,
    this.isScannedSafe,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime toDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    List<dynamic>? parseAlertes(dynamic val) {
      if (val == null) return null;
      if (val is List) return val;
      if (val is String) {
        try { return jsonDecode(val); } catch (_) { return null; }
      }
      return null;
    }

    return Invoice(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 'Inconnu',
      fournisseur: json['fournisseur'] ?? 'Inconnu',
      dateFacture: toDateTime(json['date_facture']),
      dateReception: toDateTime(json['date_reception'] ?? json['created_at']),
      devise: json['devise'] ?? 'EUR',
      montantHt: toDouble(json['ht'] ?? json['montant_ht']),
      tva: toDouble(json['tva']),
      montantTtc: toDouble(json['ttc'] ?? json['montant_ttc']),
      iban: json['iban'] ?? '',
      statut: json['statut'] ?? 'brouillon',
      fraudScore: toDouble(json['fraude_score'] ?? json['fraud_score']),
      confidenceScore: toDouble(json['confiance'] ?? json['confidence_score'] ?? 0.95),
      imagePath: json['file_path'] ?? json['image_path'],
      conformiteValide: json['conformite_valide'] ?? true,
      conformiteDetails: json['conformite_details'],
      fraudeJustification: json['fraude_justification'],
      fraudeAlertes: parseAlertes(json['fraude_alertes']),
      creeParId: json['cree_par_id'],
      valideParId: json['valide_par_id'],
      creeParNom: json['cree_par_nom'] ?? 'Auteur Système',
      tenantId: json['tenant_id'] ?? 'tenant_default',
      mimeType: json['mime_type'] ?? 'application/pdf',
      isScannedSafe: json['is_scanned_safe'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'fournisseur': fournisseur,
      'date_facture': dateFacture.toIso8601String(),
      'devise': devise,
      'ht': montantHt,
      'tva': tva,
      'ttc': montantTtc,
      'iban': iban,
      'statut': statut,
      'cree_par_id': creeParId,
      'valide_par_id': valideParId,
      'tenant_id': tenantId,
    };
  }
}
