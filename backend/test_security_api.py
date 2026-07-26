import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database import Base, Utilisateur, Facture, AuditLog, RoleUtilisateur, StatutFacture, init_db
from main import app, get_db
from security import (
    hash_password, validate_password_policy, verify_audit_hash_chain,
    inspect_file_security
)

# Configuration de la BDD de test SQLite en mémoire
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_security.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_test_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    init_db()

# ── 1. Test Politique de Mot de Passe & Connexion Générique ──────────────────
def test_password_policy_and_generic_login():
    # Validation de la politique de mot de passe (12+ chars, majuscule, minuscule, chiffre, symbole)
    is_valid, _ = validate_password_policy("short")
    assert not is_valid

    is_valid, _ = validate_password_policy("ValidPassword123!")
    assert is_valid

    # Réponse générique pour éviter le credential enumeration
    res = client.post("/api/auth/login", data={"username": "wrong@demo.com", "password": "WrongPassword123!"})
    assert res.status_code == 401
    assert res.json()["detail"] == "Identifiants invalides."

# ── 2. Test Protection Brute-Force & Verrouillage ────────────────────────────
def test_brute_force_lockout():
    for _ in range(5):
        client.post("/api/auth/login", data={"username": "client@demo.com", "password": "WrongPassword123!"})
    
    # La 6ème tentative doit renvoyer un statut 403 Verrouillé
    res = client.post("/api/auth/login", data={"username": "client@demo.com", "password": "WrongPassword123!"})
    assert res.status_code == 403
    assert "verrouillé" in res.json()["detail"].lower()

# ── 3. Test RBAC et Séparation des Tâches (SoD) ──────────────────────────────
def test_rbac_and_sod_enforcement():
    # Login Comptable (Préparateur)
    res_comp = client.post("/api/auth/login", data={"username": "comptable@demo.com", "password": "Comptable123!"})
    assert res_comp.status_code == 200
    comp_token = res_comp.json()["access_token"]
    comp_headers = {"Authorization": f"Bearer {comp_token}"}

    # Upload d'une facture par le Comptable
    pdf_bytes = b"%PDF-1.4 Fake Invoice Content"
    upload_res = client.post(
        "/api/factures/upload",
        files={"file": ("invoice_sod_test.pdf", pdf_bytes, "application/pdf")},
        headers=comp_headers
    )
    assert upload_res.status_code == 200
    facture_id = upload_res.json()["id"]

    # Tentative par l'Auteur/Préparateur de Valider sa propre facture -> Doit ÉCHOUER (SoD 403)
    val_res_same = client.patch(
        f"/api/factures/{facture_id}/status",
        json={"statut": "validee", "commentaire": "Auto-validation interdite"},
        headers=comp_headers
    )
    assert val_res_same.status_code == 403
    assert "séparation des tâches" in val_res_same.json()["detail"].lower()

    # Login Expert-Comptable (Validateur distinct)
    res_exp = client.post("/api/auth/login", data={"username": "expert@demo.com", "password": "Expert123456!"})
    assert res_exp.status_code == 200
    exp_token = res_exp.json()["access_token"]
    exp_headers = {"Authorization": f"Bearer {exp_token}"}

    # Validation par l'Expert-Comptable distinct -> Doit RÉUSSIR (200 OK)
    val_res_exp = client.patch(
        f"/api/factures/{facture_id}/status",
        json={"statut": "validee", "commentaire": "Validation par Expert conforme"},
        headers=exp_headers
    )
    assert val_res_exp.status_code == 200
    assert val_res_exp.json()["facture"]["statut"] == "validee"

# ── 4. Test Chaîne d'Audit Cryptographique Inviolable (SEC-AUD-02) ─────────────
def test_cryptographic_audit_hash_chain():
    res_admin = client.post("/api/auth/login", data={"username": "admin@demo.com", "password": "Admin1234567!"})
    admin_token = res_admin.json()["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # Vérification de l'intégrité de la chaîne d'audit initiale
    verify_res = client.get("/api/audit/verify-chain", headers=admin_headers)
    assert verify_res.status_code == 200
    assert verify_res.json()["chain_intact"] is True

    # Simulation d'une altération malveillante en base de données sur une entrée d'audit
    db = TestingSessionLocal()
    tampered_entry = db.query(AuditLog).first()
    tampered_entry.action = "ALTERED_ACTION_BY_ATTACKER"
    db.commit()
    db.close()

    # La vérification de la chaîne doit détecter immédiatement l'altération !
    tamper_check_res = client.get("/api/audit/verify-chain", headers=admin_headers)
    assert tamper_check_res.status_code == 200
    assert tamper_check_res.json()["chain_intact"] is False
    assert "altération" in tamper_check_res.json()["message"].lower() or "rupture" in tamper_check_res.json()["message"].lower()

# ── 5. Test Inspection Magic Bytes & Téléversement Sécurisé (SEC-05) ────────────
def test_magic_bytes_and_quarantine_upload():
    # 1. Valide : Fichier PDF avec vrais Magic Bytes %PDF
    is_safe, msg, mime = inspect_file_security(b"%PDF-1.7 Valid PDF Content", "valid.pdf")
    assert is_safe
    assert mime == "application/pdf"

    # 2. Invalide : Fichier script PHP renommé en .pdf
    is_safe, msg, mime = inspect_file_security(b"<?php echo 'malware'; ?>", "malicious.pdf")
    assert not is_safe
    assert mime in ["unauthorized", "malware_detected"]

    # 3. Invalide : Dépassement de la taille maximale 10 Mo
    huge_bytes = b"%PDF" + b"0" * (11 * 1024 * 1024)
    is_safe, msg, mime = inspect_file_security(huge_bytes, "huge.pdf")
    assert not is_safe
    assert "volumineux" in msg.lower()
