import os
import re
import json
import uuid
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, Tuple

import pyotp
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from database import (
    Utilisateur, Facture, AuditLog, RoleUtilisateur, StatutFacture,
    calculate_audit_hash
)

# ── Configuration de Sécurité ──────────────────────────────────────────────────
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "secure-invoice-ai-super-secret-key-2026-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 7

# ── 1. Politique de Mot de Passe & Hachage PBKDF2/SHA256 Ultra-Sécurisé ────────
def validate_password_policy(password: str) -> Tuple[bool, str]:
    """
    Exige au moins 12 caractères, 1 majuscule, 1 minuscule, 1 chiffre et 1 caractère spécial.
    """
    if len(password) < 12:
        return False, "Le mot de passe doit contenir au moins 12 caractères."
    if not re.search(r"[A-Z]", password):
        return False, "Le mot de passe doit contenir au moins une lettre majuscule."
    if not re.search(r"[a-z]", password):
        return False, "Le mot de passe doit contenir au moins une lettre minuscule."
    if not re.search(r"[0-9]", password):
        return False, "Le mot de passe doit contenir au moins un chiffre."
    if not re.search(r"[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]", password):
        return False, "Le mot de passe doit contenir au moins un caractère spécial (!@#$%^&*...)."
    return True, "Mot de passe conforme."

def hash_password(password: str) -> str:
    """Hachage PBKDF2-HMAC-SHA256 sécurisé (100,000 itérations + Salt)."""
    salt = secrets.token_hex(16)
    key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 100000)
    return f"pbkdf2_sha256${salt}${key.hex()}"

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        if not hashed_password or not hashed_password.startswith("pbkdf2_sha256$"):
            return False
        parts = hashed_password.split("$")
        if len(parts) != 3:
            return False
        salt = parts[1]
        expected_key = parts[2]
        key = hashlib.pbkdf2_hmac("sha256", plain_password.encode("utf-8"), salt.encode("utf-8"), 100000)
        return secrets.compare_digest(key.hex(), expected_key)
    except Exception:
        return False

# ── 2. Protection Brute-Force et Verrouillage de Compte ───────────────────────
def check_account_lockout(user: Utilisateur, db: Session) -> Tuple[bool, str]:
    if user.locked_until:
        if datetime.utcnow() < user.locked_until:
            remaining = int((user.locked_until - datetime.utcnow()).total_seconds() / 60)
            return True, f"Compte temporairement verrouillé pour des raisons de sécurité. Réessayez dans {max(1, remaining)} min."
        else:
            user.locked_until = None
            user.failed_login_attempts = 0
            db.commit()

    return False, "Compte actif."

def record_failed_login(user: Utilisateur, db: Session):
    user.failed_login_attempts += 1
    if user.failed_login_attempts >= 10:
        user.locked_until = datetime.utcnow() + timedelta(hours=24)
    elif user.failed_login_attempts >= 5:
        user.locked_until = datetime.utcnow() + timedelta(minutes=5)
    db.commit()

def reset_failed_logins(user: Utilisateur, db: Session):
    user.failed_login_attempts = 0
    user.locked_until = None
    db.commit()

# ── 3. Authentification Multi-Facteurs (TOTP MFA) ──────────────────────────────
def generate_totp_secret() -> str:
    return pyotp.random_base32()

def get_totp_uri(secret: str, email: str) -> str:
    totp = pyotp.TOTP(secret)
    return totp.provisioning_uri(name=email, issuer_name="SecureInvoice AI")

def verify_totp_code(secret: str, code: str) -> bool:
    if not secret or not code:
        return False
    totp = pyotp.TOTP(secret)
    return totp.verify(code.strip(), valid_window=1)

# ── 4. Gestion des Jetons JWT (Short-Lived Access + Refresh) ──────────────────
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_jwt_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        raise ValueError(f"Jeton JWT invalide ou expiré: {str(e)}")

# ── 5. Journal d'Audit Cryptographique Inviolable (Cryptographic Hash Chain) ──
def log_security_event(
    db: Session,
    actor: str,
    actor_id: Optional[int],
    actor_role: str,
    action: str,
    object_type: str,
    object_id: str,
    tenant_id: str = "tenant_default",
    result: str = "SUCCESS",
    metadata: dict = None,
    ip_address: str = "127.0.0.1",
    user_agent: str = "SecureInvoice-Client"
) -> AuditLog:
    last_entry = db.query(AuditLog).order_by(AuditLog.id.desc()).first()
    previous_hash = last_entry.hash if last_entry else "GENESIS_HASH"

    event_id = str(uuid.uuid4())
    now_dt = datetime.utcnow()
    date_str = now_dt.isoformat()
    
    current_hash = calculate_audit_hash(previous_hash, event_id, date_str, actor, action, str(object_id), result)

    log_entry = AuditLog(
        event_id=event_id,
        date=now_dt,
        acteur=actor,
        actor_id=actor_id,
        actor_role=actor_role,
        ip_address=ip_address,
        user_agent=user_agent,
        action=action,
        object_type=object_type,
        object_id=str(object_id),
        tenant_id=tenant_id,
        result=result,
        metadata_json=json.dumps(metadata or {}),
        previous_hash=previous_hash,
        hash=current_hash
    )

    db.add(log_entry)
    db.commit()
    db.refresh(log_entry)
    return log_entry

def verify_audit_hash_chain(db: Session) -> Tuple[bool, str, int]:
    logs = db.query(AuditLog).order_by(AuditLog.id.asc()).all()
    if not logs:
        return True, "Chaîne d'audit vide et intègre.", 0

    expected_prev_hash = "GENESIS_HASH"
    for log in logs:
        if log.previous_hash != expected_prev_hash:
            return False, f"Rupture de chaîne détectée à l'entrée ID {log.id} (previous_hash invalide)", log.id

        recalculated_hash = calculate_audit_hash(
            log.previous_hash, log.event_id, log.date.isoformat(),
            log.acteur, log.action, log.object_id, log.result
        )

        if log.hash != recalculated_hash:
            return False, f"Altération détectée à l'entrée ID {log.id} (hash ne correspond pas au contenu)", log.id

        expected_prev_hash = log.hash

    return True, f"Chaîne d'audit 100% intègre et certifiée ({len(logs)} entrées vérifiées).", 0

# ── 6. Matrice de Permissions RBAC et Séparation des Tâches (SoD) ──────────────
PERMISSIONS_MATRIX = {
    RoleUtilisateur.client.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": True,
        "VIEW_ASSIGNED_DOSSIERS": False,
        "PREPARE_ACCOUNTING_ENTRY": False,
        "VALIDATE_ACCOUNTING_ENTRY": False,
        "PREPARE_INVOICE": False,
        "VALIDATE_INVOICE": False,
        "VIEW_AUDIT_LOGS": False,
        "MANAGE_USERS": False,
    },
    RoleUtilisateur.assistant_comptable.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": True,
        "VIEW_ASSIGNED_DOSSIERS": True,
        "PREPARE_ACCOUNTING_ENTRY": True,
        "VALIDATE_ACCOUNTING_ENTRY": False,
        "PREPARE_INVOICE": True,
        "VALIDATE_INVOICE": False,
        "VIEW_AUDIT_LOGS": False,
        "MANAGE_USERS": False,
    },
    RoleUtilisateur.comptable.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": True,
        "VIEW_ASSIGNED_DOSSIERS": True,
        "PREPARE_ACCOUNTING_ENTRY": True,
        "VALIDATE_ACCOUNTING_ENTRY": False,
        "PREPARE_INVOICE": True,
        "VALIDATE_INVOICE": False,
        "VIEW_AUDIT_LOGS": False,
        "MANAGE_USERS": False,
    },
    RoleUtilisateur.expert_comptable.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": False,
        "VIEW_ASSIGNED_DOSSIERS": True,
        "PREPARE_ACCOUNTING_ENTRY": False,
        "VALIDATE_ACCOUNTING_ENTRY": True,
        "PREPARE_INVOICE": False,
        "VALIDATE_INVOICE": True,
        "VIEW_AUDIT_LOGS": True,
        "MANAGE_USERS": False,
    },
    RoleUtilisateur.auditeur.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": False,
        "VIEW_ASSIGNED_DOSSIERS": True,
        "PREPARE_ACCOUNTING_ENTRY": False,
        "VALIDATE_ACCOUNTING_ENTRY": False,
        "PREPARE_INVOICE": False,
        "VALIDATE_INVOICE": False,
        "VIEW_AUDIT_LOGS": True,
        "MANAGE_USERS": False,
    },
    RoleUtilisateur.admin.value: {
        "VIEW_OWN_DASHBOARD": True,
        "UPLOAD_DOCUMENTS": True,
        "VIEW_ASSIGNED_DOSSIERS": True,
        "PREPARE_ACCOUNTING_ENTRY": True,
        "VALIDATE_ACCOUNTING_ENTRY": True,
        "PREPARE_INVOICE": True,
        "VALIDATE_INVOICE": True,
        "VIEW_AUDIT_LOGS": True,
        "MANAGE_USERS": True,
    },
}

def check_permission(role: str, action: str) -> bool:
    role_perms = PERMISSIONS_MATRIX.get(role, {})
    return role_perms.get(action, False)

def enforce_sod_check(invoice: Facture, user: Utilisateur, action: str = "VALIDATE_INVOICE") -> Tuple[bool, str]:
    """
    Règle de Séparation des Tâches (SoD) :
    L'utilisateur qui a préparé/créé la facture ne peut pas la valider lui-même.
    """
    if action in ["VALIDATE_INVOICE", "VALIDATE_ACCOUNTING_ENTRY"]:
        if invoice.cree_par_id and invoice.cree_par_id == user.id:
            return False, "Violation de la Séparation des Tâches (SoD) : L'auteur du document ne peut pas le valider lui-même."
    return True, "Séparation des tâches conforme."

# ── 7. Téléversement Sécurisé & Inspection des Magic Bytes (SEC-05) ─────────────
ALLOWED_MAGIC_BYTES = {
    "application/pdf": [b"%PDF"],
    "image/jpeg": [b"\xff\xd8\xff"],
    "image/png": [b"\x89PNG\r\n\x1a\n"],
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": [b"PK\x03\x04"],
}

MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024 # 10 MB limit

def inspect_file_security(file_bytes: bytes, filename: str) -> Tuple[bool, str, str]:
    if len(file_bytes) == 0:
        return False, "Le fichier soumis est vide.", "unknown"

    if len(file_bytes) > MAX_FILE_SIZE_BYTES:
        return False, "Fichier trop volumineux. La limite maximale est de 10 Mo.", "unknown"

    detected_mime = None
    for mime, signatures in ALLOWED_MAGIC_BYTES.items():
        for sig in signatures:
            if file_bytes.startswith(sig):
                detected_mime = mime
                break
        if detected_mime:
            break

    if not detected_mime:
        return False, "Format de fichier non autorisé ou corrompu. Seuls PDF, PNG, JPG et XLSX sont acceptés.", "unauthorized"

    sample = file_bytes[:1024].lower()
    if b"<script" in sample or b"<?php" in sample or b"eval(" in sample:
        return False, "Menace de sécurité détectée dans l'en-tête du fichier (Analyse Antivirus).", "malware_detected"

    return True, f"Fichier validé avec succès (Type: {detected_mime}).", detected_mime
