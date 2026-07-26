import os
import json
import uuid
import hashlib
from datetime import datetime, timedelta
from enum import Enum

from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./secure_invoice.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ── Enums pour le contrôle des rôles et statuts ────────────────────────────────
class RoleUtilisateur(str, Enum):
    client = "client"
    assistant_comptable = "assistant_comptable"
    comptable = "comptable"
    expert_comptable = "expert_comptable"
    auditeur = "auditeur"
    admin = "admin"

class StatutFacture(str, Enum):
    brouillon = "brouillon"
    soumise = "soumise"
    preparee = "preparee"
    validee = "validee"
    rejetee = "rejetee"
    archivee = "archivee"

# ── Modèles de Données ──────────────────────────────────────────────────────────
class Utilisateur(Base):
    __tablename__ = "utilisateurs"

    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, index=True, nullable=False)
    mot_de_passe_hash = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False, default=RoleUtilisateur.client.value)
    tenant_id = Column(String(50), nullable=False, default="tenant_default")
    mfa_enabled = Column(Boolean, default=False)
    mfa_secret = Column(String(100), nullable=True)
    mfa_configured = Column(Boolean, default=False)
    failed_login_attempts = Column(Integer, default=0)
    locked_until = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Facture(Base):
    __tablename__ = "factures"

    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), nullable=False, default="tenant_default")
    numero = Column(String(100), nullable=False)
    fournisseur = Column(String(150), nullable=False)
    date_facture = Column(String(20), nullable=False)
    devise = Column(String(10), default="EUR")
    ht = Column(Float, nullable=False, default=0.0)
    tva = Column(Float, nullable=False, default=0.0)
    ttc = Column(Float, nullable=False, default=0.0)
    iban = Column(String(50), nullable=True)
    statut = Column(String(50), default=StatutFacture.brouillon.value)
    
    # Séparation des tâches (SoD) : Auteur (Préparateur) vs Validateur
    cree_par_id = Column(Integer, ForeignKey("utilisateurs.id"), nullable=True)
    valide_par_id = Column(Integer, ForeignKey("utilisateurs.id"), nullable=True)
    
    conformite_valide = Column(Boolean, default=True)
    conformite_details = Column(Text, default="[]")
    fraude_score = Column(Integer, default=0)
    fraude_justification = Column(Text, default="")
    fraude_alertes = Column(Text, default="[]")
    
    file_path = Column(String(255), nullable=True)
    mime_type = Column(String(100), nullable=True)
    file_size = Column(Integer, nullable=True)
    is_scanned_safe = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    createur = relationship("Utilisateur", foreign_keys=[cree_par_id])
    validateur = relationship("Utilisateur", foreign_keys=[valide_par_id])

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String(50), unique=True, default=lambda: str(uuid.uuid4()))
    date = Column(DateTime, default=datetime.utcnow)
    acteur = Column(String(150), nullable=False)
    actor_id = Column(Integer, nullable=True)
    actor_role = Column(String(50), nullable=False)
    ip_address = Column(String(50), default="127.0.0.1")
    user_agent = Column(String(255), default="System")
    action = Column(String(100), nullable=False)
    object_type = Column(String(50), nullable=False)
    object_id = Column(String(50), nullable=False)
    tenant_id = Column(String(50), default="tenant_default")
    result = Column(String(50), default="SUCCESS")
    metadata_json = Column(Text, default="{}")
    
    # Tamper-Proof Cryptographic Hash Chain (SEC-AUD-02)
    previous_hash = Column(String(64), nullable=False, default="GENESIS_HASH")
    hash = Column(String(64), nullable=False)

class Fournisseur(Base):
    __tablename__ = "fournisseurs"

    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(100), nullable=False)
    nom_complet = Column(String(200), nullable=True)
    iban_officiel = Column(String(50), nullable=False)
    montant_moyen_mensuel = Column(Float, default=1000.0)
    devise = Column(String(10), default="EUR")
    statut_confiance = Column(String(50), default="VERIFIE")
    siret = Column(String(50), nullable=True)

class RegleConformite(Base):
    __tablename__ = "regles_conformite"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False)
    nom = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    active = Column(Boolean, default=True)

# ── Helper pour calculer le Hash Cryptographique d'un Log d'Audit ──────────────
def calculate_audit_hash(previous_hash: str, event_id: str, date_str: str, actor: str, action: str, object_id: str, result: str) -> str:
    raw_payload = f"{previous_hash}|{event_id}|{date_str}|{actor}|{action}|{object_id}|{result}"
    return hashlib.sha256(raw_payload.encode("utf-8")).hexdigest()

# ── Fonction d'Initialisation de la BDD ───────────────────────────────────────
def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.query(Utilisateur).count() > 0:
            print("[INFO] Base de données déjà initialisée.")
            return

        print("[INFO] Initialisation complète de la base de données sécurisée...")
        
        # Import tardif pour éviter les dépendances circulaires
        from security import hash_password

        # ── 1. Création des 6 utilisateurs de démonstration (RBAC complet) ─────
        users_seed = [
            Utilisateur(
                nom="Yassine Client",
                email="client@demo.com",
                mot_de_passe_hash=hash_password("Client123456!"),
                role=RoleUtilisateur.client.value,
                tenant_id="tenant_alpha",
                mfa_enabled=False
            ),
            Utilisateur(
                nom="Sarra Assistant",
                email="assistant@demo.com",
                mot_de_passe_hash=hash_password("Assistant123!"),
                role=RoleUtilisateur.assistant_comptable.value,
                tenant_id="cabinet_internal",
                mfa_enabled=True,
                mfa_configured=True
            ),
            Utilisateur(
                nom="Mohamed Comptable",
                email="comptable@demo.com",
                mot_de_passe_hash=hash_password("Comptable123!"),
                role=RoleUtilisateur.comptable.value,
                tenant_id="cabinet_internal",
                mfa_enabled=True,
                mfa_configured=True
            ),
            Utilisateur(
                nom="Khaled Expert",
                email="expert@demo.com",
                mot_de_passe_hash=hash_password("Expert123456!"),
                role=RoleUtilisateur.expert_comptable.value,
                tenant_id="cabinet_internal",
                mfa_enabled=True,
                mfa_configured=True
            ),
            Utilisateur(
                nom="Sami Auditeur",
                email="auditeur@demo.com",
                mot_de_passe_hash=hash_password("Auditeur1234!"),
                role=RoleUtilisateur.auditeur.value,
                tenant_id="cabinet_internal",
                mfa_enabled=True,
                mfa_configured=True
            ),
            Utilisateur(
                nom="Yassine Admin",
                email="admin@demo.com",
                mot_de_passe_hash=hash_password("Admin1234567!"),
                role=RoleUtilisateur.admin.value,
                tenant_id="cabinet_internal",
                mfa_enabled=True,
                mfa_configured=True
            ),
        ]
        db.add_all(users_seed)
        db.flush()

        # ── 2. Fournisseurs connus ──────────────────────────────────────────────
        suppliers_seed = [
            Fournisseur(
                nom="STEG",
                nom_complet="Société Tunisienne de l'Électricité et du Gaz",
                iban_officiel="TN5910006035183598983943",
                montant_moyen_mensuel=1500.0,
                devise="TND",
                statut_confiance="VERIFIE",
                siret="0011223344"
            ),
            Fournisseur(
                nom="Orange Business",
                nom_complet="Orange Business Services S.A.",
                iban_officiel="FR7630006000011234567890189",
                montant_moyen_mensuel=3200.0,
                devise="EUR",
                statut_confiance="VERIFIE",
                siret="38012986400034"
            ),
            Fournisseur(
                nom="Amazon Web Services",
                nom_complet="Amazon Web Services EMEA SARL",
                iban_officiel="LU9630001234567890123456",
                montant_moyen_mensuel=4500.0,
                devise="EUR",
                statut_confiance="VERIFIE",
                siret="LU20192837"
            ),
        ]
        db.add_all(suppliers_seed)
        db.flush()

        # ── 3. Règles de conformité ────────────────────────────────────────────
        rules_seed = [
            RegleConformite(
                code="CHAMPS_OBLIGATOIRES",
                nom="Champs obligatoires",
                description="Vérifie la présence du numéro, date, fournisseur et montants.",
                active=True
            ),
            RegleConformite(
                code="COHERENCE_TVA",
                nom="Cohérence TVA (HT + TVA = TTC)",
                description="Vérifie l'équation mathématique HT + TVA = TTC (tolérance 0.05).",
                active=True
            ),
            RegleConformite(
                code="FORMAT_IBAN",
                nom="Structure de l'IBAN",
                description="Valide le format et la clé de contrôle de l'IBAN.",
                active=True
            ),
            RegleConformite(
                code="SEPARATION_TACHES",
                nom="Séparation des Tâches (SoD)",
                description="Interdit à l'auteur/préparateur d'une facture de la valider lui-même.",
                active=True
            )
        ]
        db.add_all(rules_seed)
        db.flush()

        # ── 4. Factures de démonstration avec SoD ─────────────────────────────
        # User 1 = Client, User 2 = Assistant, User 3 = Comptable, User 4 = Expert
        inv1 = Facture(
            tenant_id="tenant_alpha",
            numero="STEG-2026-001",
            fournisseur="STEG",
            date_facture="2026-07-20",
            devise="TND",
            ht=1000.0,
            tva=190.0,
            ttc=1190.0,
            iban="TN5910006035183598983943",
            statut=StatutFacture.validee.value,
            cree_par_id=users_seed[1].id, # Préparé par Assistant
            valide_par_id=users_seed[3].id, # Validé par Expert (SoD respectée)
            conformite_valide=True,
            conformite_details=json.dumps([]),
            fraude_score=4,
            fraude_justification="Paiement conforme. Fournisseur de confiance.",
            fraude_alertes=json.dumps([])
        )

        inv2 = Facture(
            tenant_id="tenant_alpha",
            numero="OBS-2026-992",
            fournisseur="Orange Business",
            date_facture="2026-07-24",
            devise="EUR",
            ht=2500.0,
            tva=500.0,
            ttc=3100.0, # Erreur TVA intentionnelle
            iban="FR7630006000011234567890189",
            statut=StatutFacture.preparee.value,
            cree_par_id=users_seed[2].id, # Préparé par Comptable Mohamed
            valide_par_id=None, # En attente de validation par Expert/Admin
            conformite_valide=False,
            conformite_details=json.dumps(["Calcul TVA incorrect : 2500.0 + 500.0 = 3000.0 (TTC reçu: 3100.0)"]),
            fraude_score=15,
            fraude_justification="Anomalie de calcul TVA détectée.",
            fraude_alertes=json.dumps([])
        )

        db.add_all([inv1, inv2])
        db.flush()

        # ── 5. Chaîne d'Audit Cryptographique Initiale (SEC-AUD-02) ─────────────
        prev_hash = "GENESIS_HASH"
        logs_data = [
            ("system@secureinvoice.ai", RoleUtilisateur.admin.value, "INITIALIZE_SECURITY_MATRIX", "System", "SYS-001", "SUCCESS", {"status": "RBAC & HashChain Active"}),
            ("client@demo.com", RoleUtilisateur.client.value, "USER_LOGIN", "User", "1", "SUCCESS", {"auth_method": "JWT_PASSWORD"}),
            ("assistant@demo.com", RoleUtilisateur.assistant_comptable.value, "PREPARE_INVOICE", "Facture", str(inv1.id), "SUCCESS", {"numero": inv1.numero}),
            ("expert@demo.com", RoleUtilisateur.expert_comptable.value, "VALIDATE_INVOICE", "Facture", str(inv1.id), "SUCCESS", {"sod_check": "PASSED"}),
        ]

        for actor, role, action, obj_type, obj_id, result, meta in logs_data:
            evt_id = str(uuid.uuid4())
            now_dt = datetime.utcnow()
            dt_str = now_dt.isoformat()
            current_hash = calculate_audit_hash(prev_hash, evt_id, dt_str, actor, action, obj_id, result)
            
            audit_entry = AuditLog(
                event_id=evt_id,
                date=now_dt,
                acteur=actor,
                actor_role=role,
                ip_address="127.0.0.1",
                user_agent="SecureInvoice-SecurityKernel/1.0",
                action=action,
                object_type=obj_type,
                object_id=obj_id,
                tenant_id="tenant_alpha",
                result=result,
                metadata_json=json.dumps(meta),
                previous_hash=prev_hash,
                hash=current_hash
            )
            db.add(audit_entry)
            prev_hash = current_hash

        db.commit()
        print("[SUCCESS] Base de données et Chaîne de Hash Cryptographique initialisées.")
    except Exception as e:
        db.rollback()
        print(f"[ERROR] Erreur lors de l'initialisation de la BDD : {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
