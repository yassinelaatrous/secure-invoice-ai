import re
from typing import Dict, Any, Tuple, List
from sqlalchemy.orm import Session
from database import RegleConformite

def check_compliance(invoice_data: Dict[str, Any], db: Session) -> Tuple[bool, List[str]]:
    """
    Exécute l'ensemble des règles de conformité comptables actives en BDD.
    Retourne (is_compliant, list_of_error_messages).
    """
    errors = []
    active_rules = db.query(RegleConformite).filter(RegleConformite.active == True).all()
    rule_codes = {r.code for r in active_rules}

    # 1. Champs obligatoires
    if "CHAMPS_OBLIGATOIRES" in rule_codes:
        required = ["fournisseur", "numero", "date_facture"]
        for field in required:
            val = invoice_data.get(field)
            if not val or str(val).strip() == "" or str(val).lower() == "inconnu":
                errors.append(f"Champ obligatoire manquant : '{field}' est requis.")

    # 2. Cohérence TVA (HT + TVA = TTC)
    if "COHERENCE_TVA" in rule_codes:
        ht = float(invoice_data.get("ht", 0.0))
        tva = float(invoice_data.get("tva", 0.0))
        ttc = float(invoice_data.get("ttc", 0.0))
        calculated_ttc = round(ht + tva, 2)
        if abs(calculated_ttc - ttc) > 0.05:
            errors.append(f"Incohérence TVA : HT ({ht}) + TVA ({tva}) = {calculated_ttc} ≠ TTC ({ttc}).")

    # 3. Format IBAN
    if "FORMAT_IBAN" in rule_codes:
        iban = str(invoice_data.get("iban", "")).strip()
        if iban:
            # Enlever les espaces
            clean_iban = iban.replace(" ", "")
            if len(clean_iban) < 15 or len(clean_iban) > 34 or not re.match(r"^[A-Z]{2}\d{2}[A-Z0-9]+$", clean_iban):
                errors.append(f"Format IBAN invalide : '{iban}' ne respecte pas la norme ISO 13616.")

    is_compliant = len(errors) == 0
    return is_compliant, errors
