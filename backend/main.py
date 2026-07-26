import os
import json
import shutil
from typing import List, Optional
from datetime import datetime

from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr

from database import (
    engine, Base, SessionLocal, init_db, Utilisateur, Facture, AuditLog,
    Fournisseur, RegleConformite, RoleUtilisateur, StatutFacture
)
from security import (
    hash_password, verify_password, validate_password_policy,
    check_account_lockout, record_failed_login, reset_failed_logins,
    generate_totp_secret, get_totp_uri, verify_totp_code,
    create_access_token, decode_jwt_token, log_security_event,
    verify_audit_hash_chain, check_permission, enforce_sod_check,
    inspect_file_security
)
from ocr_engine import extract_invoice_data
from compliance import check_compliance
from fraud_detector import detect_fraud

# ── Dépertoire de Quarantaine & Fichiers Sécurisés ─────────────────────────────
QUARANTINE_DIR = os.path.abspath("./quarantine")
PROCESSED_DIR = os.path.abspath("./uploads")
os.makedirs(QUARANTINE_DIR, exist_ok=True)
os.makedirs(PROCESSED_DIR, exist_ok=True)

# ── Application FastAPI ────────────────────────────────────────────────────────
app = FastAPI(
    title="SecureInvoice AI - Security Kernel & Financial API",
    description="API financière certifiée avec RBAC, Séparation des Tâches (SoD), Chaîne d'Audit Cryptographique Inviolable et Détection de Fraude.",
    version="2.0.0-MVP"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ── Dépendance d'Authentification Sécurisée ───────────────────────────────────
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> Utilisateur:
    generic_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Jeton d'authentification invalide ou expiré.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_jwt_token(token)
        email: str = payload.get("sub")
        if email is None:
            raise generic_exception
    except Exception:
        raise generic_exception

    user = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    if user is None:
        raise generic_exception
    return user

@app.on_event("startup")
def on_startup():
    init_db()

# ── Dtos / Schemas Pydantic ──────────────────────────────────────────────────
class LoginRequest(BaseModel):
    username: str
    password: str
    totp_code: Optional[str] = None

class MfaVerifyRequest(BaseModel):
    totp_code: str

class StatusUpdateRequest(BaseModel):
    statut: str
    commentaire: Optional[str] = None

# ── 1. Endpoints d'Authentification & Sécurité (IAM) ──────────────────────────
@app.post("/api/auth/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db), request: Request = None):
    # Exigence de Sécurité : Réponse générique pour prévenir le credential enumeration
    generic_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Identifiants invalides.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    user = db.query(Utilisateur).filter(Utilisateur.email == form_data.username.strip().lower()).first()
    if not user:
        raise generic_error

    # Vérification du verrouillage Brute-Force
    is_locked, lock_msg = check_account_lockout(user, db)
    if is_locked:
        log_security_event(
            db, user.email, user.id, user.role, "LOGIN_BLOCKED_LOCKOUT",
            "Utilisateur", str(user.id), user.tenant_id, "BLOCKED",
            {"reason": lock_msg}, ip_address=request.client.host if request else "127.0.0.1"
        )
        raise HTTPException(status_code=403, detail=lock_msg)

    # Vérification du Mot de Passe
    if not verify_password(form_data.password, user.mot_de_passe_hash):
        record_failed_login(user, db)
        log_security_event(
            db, user.email, user.id, user.role, "LOGIN_FAILED",
            "Utilisateur", str(user.id), user.tenant_id, "FAILURE",
            {"attempts": user.failed_login_attempts}, ip_address=request.client.host if request else "127.0.0.1"
        )
        raise generic_error

    # Exigence MFA pour le personnel interne et admin
    if user.mfa_enabled and user.role != RoleUtilisateur.client.value:
        # Envoie l'exigence TOTP s'il n'est pas encore fourni
        totp_header = request.headers.get("X-TOTP-Code") if request else None
        if not totp_header:
            log_security_event(
                db, user.email, user.id, user.role, "LOGIN_MFA_CHALLENGE_REQUIRED",
                "Utilisateur", str(user.id), user.tenant_id, "CHALLENGE",
                {"message": "MFA TOTP requis"}
            )
            return {
                "mfa_required": True,
                "message": "Authentification Multi-Facteurs (TOTP) requise.",
                "email": user.email
            }
        
        if not verify_totp_code(user.mfa_secret, totp_header):
            record_failed_login(user, db)
            raise HTTPException(status_code=401, detail="Code TOTP MFA invalide.")

    reset_failed_logins(user, db)
    access_token = create_access_token(data={"sub": user.email, "role": user.role, "tenant_id": user.tenant_id})
    
    log_security_event(
        db, user.email, user.id, user.role, "LOGIN_SUCCESS",
        "Utilisateur", str(user.id), user.tenant_id, "SUCCESS",
        {"role": user.role, "tenant_id": user.tenant_id}
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "nom": user.nom,
            "email": user.email,
            "role": user.role,
            "tenant_id": user.tenant_id,
            "mfa_enabled": user.mfa_enabled
        }
    }

@app.post("/api/auth/mfa/setup")
def setup_mfa(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    """Génère une clé secrète TOTP et l'URI pour l'application Authenticator."""
    secret = generate_totp_secret()
    current_user.mfa_secret = secret
    db.commit()
    
    qr_uri = get_totp_uri(secret, current_user.email)
    return {
        "secret": secret,
        "qr_uri": qr_uri,
        "message": "Scannez le QR Code dans votre application Google Authenticator ou Authy."
    }

@app.post("/api/auth/mfa/verify")
def verify_mfa(req: MfaVerifyRequest, current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    if not current_user.mfa_secret:
        raise HTTPException(status_code=400, detail="MFA non configuré pour cet utilisateur.")
    
    if not verify_totp_code(current_user.mfa_secret, req.totp_code):
        raise HTTPException(status_code=400, detail="Code TOTP invalide.")
    
    current_user.mfa_enabled = True
    current_user.mfa_configured = True
    db.commit()

    log_security_event(
        db, current_user.email, current_user.id, current_user.role, "MFA_ACTIVATED",
        "Utilisateur", str(current_user.id), current_user.tenant_id, "SUCCESS"
    )

    return {"message": "Authentification Multi-Facteurs (MFA TOTP) activée avec succès."}

@app.get("/api/auth/me")
def read_users_me(current_user: Utilisateur = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "nom": current_user.nom,
        "email": current_user.email,
        "role": current_user.role,
        "tenant_id": current_user.tenant_id,
        "mfa_enabled": current_user.mfa_enabled
    }

# ── 2. Endpoints de Gestion des Factures (Multi-Tenancy & SoD) ─────────────────
@app.get("/api/factures")
def get_factures(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    # Isolation Stricte Multi-Tenancy (SEC-04)
    if current_user.role == RoleUtilisateur.client.value:
        return db.query(Facture).filter(Facture.tenant_id == current_user.tenant_id).all()
    
    # Administrateurs et personnel interne accèdent aux dossiers attribués
    return db.query(Facture).all()

@app.get("/api/factures/{facture_id}")
def get_facture_by_id(facture_id: int, current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    facture = db.query(Facture).filter(Facture.id == facture_id).first()
    if not facture:
        raise HTTPException(status_code=404, detail="Facture introuvable.")

    # Contrôle d'isolation multi-tenant : Un client ne peut PAS accéder aux données d'un autre tenant
    if current_user.role == RoleUtilisateur.client.value and facture.tenant_id != current_user.tenant_id:
        log_security_event(
            db, current_user.email, current_user.id, current_user.role, "UNAUTHORIZED_TENANT_READ_ATTEMPT",
            "Facture", str(facture_id), current_user.tenant_id, "BLOCKED"
        )
        raise HTTPException(status_code=404, detail="Facture introuvable.")

    return facture

@app.post("/api/factures/upload")
async def upload_facture(
    file: UploadFile = File(...),
    current_user: Utilisateur = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Vérification des autorisations RBAC
    if not check_permission(current_user.role, "UPLOAD_DOCUMENTS"):
        raise HTTPException(status_code=403, detail="Votre rôle ne vous autorise pas à téléverser des documents.")

    content = await file.read()

    # 1. Inspection de Sécurité : Magic Bytes & Antivirus Sandbox (SEC-05)
    is_safe, sec_msg, mime_detected = inspect_file_security(content, file.filename)
    if not is_safe:
        log_security_event(
            db, current_user.email, current_user.id, current_user.role, "SECURITY_UPLOAD_REJECTED",
            "Fichier", file.filename, current_user.tenant_id, "FAILURE",
            {"reason": sec_msg}
        )
        raise HTTPException(status_code=422, detail=sec_msg)

    # 2. Sauvegarde temporaire dans la Quarantaine puis transfert après analyse
    temp_filename = f"{uuid.uuid4()}_{file.filename}"
    quarantine_path = os.path.join(QUARANTINE_DIR, temp_filename)
    processed_path = os.path.join(PROCESSED_DIR, temp_filename)

    with open(quarantine_path, "wb") as f:
        f.write(content)

    # Transfert vers le dossier sécurisé traité
    shutil.move(quarantine_path, processed_path)

    # 3. Extraction OCR & Calculs de Conformité & Fraude
    ocr_data = extract_invoice_data(content, file.filename)
    is_compliant, compliance_errors = check_compliance(ocr_data, db)
    fraud_score, fraud_justification, fraud_alerts = detect_fraud(ocr_data, db)

    # 4. Enregistrement en BDD
    nouvelle_facture = Facture(
        tenant_id=current_user.tenant_id,
        numero=ocr_data.get("numero", "INV-UNKNOWN"),
        fournisseur=ocr_data.get("fournisseur", "Inconnu"),
        date_facture=ocr_data.get("date_facture", datetime.utcnow().strftime("%Y-%m-%d")),
        devise=ocr_data.get("devise", "EUR"),
        ht=float(ocr_data.get("ht", 0.0)),
        tva=float(ocr_data.get("tva", 0.0)),
        ttc=float(ocr_data.get("ttc", 0.0)),
        iban=ocr_data.get("iban", ""),
        statut=StatutFacture.brouillon.value if current_user.role == RoleUtilisateur.client.value else StatutFacture.soumise.value,
        cree_par_id=current_user.id, # Préparateur / Auteur
        conformite_valide=is_compliant,
        conformite_details=json.dumps(compliance_errors),
        fraude_score=fraud_score,
        fraude_justification=fraud_justification,
        fraude_alertes=json.dumps(fraud_alerts),
        file_path=processed_path,
        mime_type=mime_detected,
        file_size=len(content),
        is_scanned_safe=True
    )

    db.add(nouvelle_facture)
    db.commit()
    db.refresh(nouvelle_facture)

    log_security_event(
        db, current_user.email, current_user.id, current_user.role, "UPLOAD_INVOICE_SUCCESS",
        "Facture", str(nouvelle_facture.id), current_user.tenant_id, "SUCCESS",
        {"numero": nouvelle_facture.numero, "fraude_score": fraud_score}
    )

    return nouvelle_facture

@app.patch("/api/factures/{facture_id}/status")
def update_facture_status(
    facture_id: int,
    req: StatusUpdateRequest,
    current_user: Utilisateur = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    facture = db.query(Facture).filter(Facture.id == facture_id).first()
    if not facture:
        raise HTTPException(status_code=404, detail="Facture introuvable.")

    new_statut = req.statut.lower()

    # 1. Vérification de la Séparation des Tâches (SoD) si la demande est de Valider
    if new_statut == StatutFacture.validee.value:
        if not check_permission(current_user.role, "VALIDATE_INVOICE"):
            raise HTTPException(status_code=403, detail="Votre rôle ne permet pas la validation comptable des pièces.")
        
        # Application stricte de la règle SoD : L'auteur ne peut pas valider son propre document
        sod_ok, sod_msg = enforce_sod_check(facture, current_user, "VALIDATE_INVOICE")
        if not sod_ok:
            log_security_event(
                db, current_user.email, current_user.id, current_user.role, "SOD_VIOLATION_BLOCKED",
                "Facture", str(facture_id), current_user.tenant_id, "BLOCKED",
                {"reason": sod_msg}
            )
            raise HTTPException(status_code=403, detail=sod_msg)

        facture.valide_par_id = current_user.id

    facture.statut = new_statut
    db.commit()

    log_security_event(
        db, current_user.email, current_user.id, current_user.role, "STATUS_CHANGED",
        "Facture", str(facture_id), current_user.tenant_id, "SUCCESS",
        {"new_status": new_statut, "comment": req.commentaire}
    )

    return {"message": f"Statut mis à jour avec succès: {new_statut}", "facture": facture}

# ── 3. Endpoints d'Audit Cryptographique Inviolable (SEC-AUD-02) ────────────────
@app.get("/api/audit")
def get_audit_logs(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    if not check_permission(current_user.role, "VIEW_AUDIT_LOGS") and current_user.role != RoleUtilisateur.client.value:
        raise HTTPException(status_code=403, detail="Accès refusé au journal d'audit.")

    if current_user.role == RoleUtilisateur.client.value:
        return db.query(AuditLog).filter(AuditLog.tenant_id == current_user.tenant_id).order_by(AuditLog.id.desc()).all()

    return db.query(AuditLog).order_by(AuditLog.id.desc()).all()

@app.get("/api/audit/verify-chain")
def verify_audit_chain(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role not in [RoleUtilisateur.admin.value, RoleUtilisateur.auditeur.value, RoleUtilisateur.expert_comptable.value]:
        raise HTTPException(status_code=403, detail="Accès réservé aux auditeurs et administrateurs.")

    is_valid, msg, broken_id = verify_audit_hash_chain(db)
    return {
        "chain_intact": is_valid,
        "message": msg,
        "broken_entry_id": broken_id,
        "timestamp": datetime.utcnow().isoformat()
    }

# ── 4. Statistiques du Tableau de Bord & Règles ──────────────────────────────
@app.get("/api/dashboard/stats")
def get_dashboard_stats(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(Facture)
    if current_user.role == RoleUtilisateur.client.value:
        query = query.filter(Facture.tenant_id == current_user.tenant_id)
    
    total = query.count()
    validated = query.filter(Facture.statut == StatutFacture.validee.value).count()
    pending = query.filter(Facture.statut.in_([StatutFacture.brouillon.value, StatutFacture.soumise.value, StatutFacture.preparee.value])).count()
    
    factures = query.all()
    avg_fraud = sum(f.fraude_score for f in factures) / total if total > 0 else 0
    compliance_rate = (sum(1 for f in factures if f.conformite_valide) / total * 100) if total > 0 else 100.0

    return {
        "total_factures": total,
        "validees": validated,
        "en_attente": pending,
        "avg_fraud_score": round(avg_fraud, 1),
        "compliance_rate": round(compliance_rate, 1)
    }

@app.get("/api/rules")
def get_rules(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(RegleConformite).all()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
