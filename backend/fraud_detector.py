import json
from typing import Dict, Any, Tuple, List
from sqlalchemy.orm import Session
from database import Facture, Fournisseur

def detect_fraud(invoice_data: Dict[str, Any], db: Session, current_facture_id: int = None) -> Tuple[int, str, List[str]]:
    """
    Calcule le score de risque de fraude (0 à 100) et liste les alertes de sécurité.
    """
    score = 0
    alerts = []

    fournisseur_nom = str(invoice_data.get("fournisseur", "")).strip()
    numero = str(invoice_data.get("numero", "")).strip()
    iban = str(invoice_data.get("iban", "")).strip()
    ttc = float(invoice_data.get("ttc", 0.0))

    # 1. Vérification des Doublons (Duplicate Invoice Check)
    if numero and fournisseur_nom:
        query = db.query(Facture).filter(
            Facture.fournisseur.ilike(fournisseur_nom),
            Facture.numero.ilike(numero)
        )
        if current_facture_id:
            query = query.filter(Facture.id != current_facture_id)
        
        duplicate = query.first()
        if duplicate:
            score += 80
            alerts.append(f"Alerte critique : Doublon de facture détecté (Numéro '{numero}' déjà enregistré pour {fournisseur_nom}).")

    # 2. Vérification de l'IBAN du Fournisseur (IBAN Substitution Fraud)
    if fournisseur_nom:
        supplier = db.query(Fournisseur).filter(Fournisseur.nom.ilike(fournisseur_nom)).first()
        if supplier:
            if iban and supplier.iban_officiel:
                clean_iban = iban.replace(" ", "")
                clean_official = supplier.iban_officiel.replace(" ", "")
                if clean_iban != clean_official:
                    score += 65
                    alerts.append(f"Risque d'usurpation d'IBAN : L'IBAN extrait ({iban}) diffère de l'IBAN officiel ({supplier.iban_officiel}).")
            
            # 3. Montant Inhabituellement Élevé (> 3x moyenne mensuelle)
            if supplier.montant_moyen_mensuel and ttc > (supplier.montant_moyen_mensuel * 3.0):
                score += 25
                alerts.append(f"Alerte montant : Le montant TTC ({ttc}) dépasse 3 fois la moyenne mensuelle habituelle ({supplier.montant_moyen_mensuel}).")
        else:
            score += 40
            alerts.append(f"Alerte fournisseur : Le fournisseur '{fournisseur_nom}' n'est pas référencé dans la liste de confiance.")

    # 4. Détection de Montant Rond Suspect
    if ttc > 500 and ttc.is_integer():
        score += 10
        alerts.append("Signal faible : Le montant total est un chiffre parfaitement rond.")

    # Borner le score à 100 max
    score = min(score, 100)

    # Justification synthétique
    if score >= 70:
        justification = "Risque TRÈS ÉLEVÉ : Facture nécessitant une vérification manuelle urgente avant tout paiement."
    elif score >= 40:
        justification = "Risque MODÉRÉ : Des anomalies d'IBAN ou de fournisseur nécessitent un contrôle préalable."
    elif score >= 15:
        justification = "Risque FAIBLE : Quelques signaux mineurs détectés."
    else:
        justification = "Facture saine : Aucune anomalie de fraude suspectée."

    return score, justification, alerts
