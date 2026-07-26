import os
import sys
import unittest
from datetime import datetime

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Add backend directory to sys.path
sys.path.insert(0, os.path.dirname(__file__))

from database import Base, Utilisateur, Facture, AuditLog, RoleUtilisateur, StatutFacture, init_db
from security import (
    hash_password, validate_password_policy, verify_audit_hash_chain,
    inspect_file_security, check_permission, enforce_sod_check,
    verify_password
)
from compliance import check_compliance
from fraud_detector import detect_fraud

class TestSecurityKernel(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        os.environ["DATABASE_URL"] = "sqlite:///./test_security_unittest.db"
        init_db()

    def test_01_password_policy(self):
        is_valid, msg = validate_password_policy("short")
        self.assertFalse(is_valid)

        is_valid, msg = validate_password_policy("ValidPassword123!")
        self.assertTrue(is_valid)

    def test_02_rbac_permissions_matrix(self):
        # Client cannot validate invoices or manage users
        self.assertFalse(check_permission(RoleUtilisateur.client.value, "VALIDATE_INVOICE"))
        self.assertFalse(check_permission(RoleUtilisateur.client.value, "MANAGE_USERS"))

        # Expert-Comptable can validate invoices
        self.assertTrue(check_permission(RoleUtilisateur.expert_comptable.value, "VALIDATE_INVOICE"))

        # Admin has all permissions
        self.assertTrue(check_permission(RoleUtilisateur.admin.value, "MANAGE_USERS"))

    def test_03_separation_of_duties_sod(self):
        user_preparer = Utilisateur(id=10, nom="Preparer", email="preparer@demo.com", role="comptable")
        user_validator = Utilisateur(id=20, nom="Validator", email="validator@demo.com", role="expert_comptable")

        facture = Facture(id=100, numero="FAC-SOD-01", cree_par_id=user_preparer.id)

        # Preparer attempts to validate -> SoD MUST fail
        sod_ok, sod_msg = enforce_sod_check(facture, user_preparer, "VALIDATE_INVOICE")
        self.assertFalse(sod_ok)
        self.assertIn("Violation de la Séparation des Tâches", sod_msg)

        # Distinct Validator attempts to validate -> SoD passes
        sod_ok, sod_msg = enforce_sod_check(facture, user_validator, "VALIDATE_INVOICE")
        self.assertTrue(sod_ok)

    def test_04_magic_bytes_quarantine_inspection(self):
        # Valid PDF magic bytes
        is_safe, msg, mime = inspect_file_security(b"%PDF-1.7 Valid PDF Content", "valid.pdf")
        self.assertTrue(is_safe)
        self.assertEqual(mime, "application/pdf")

        # Malicious PHP script disguised as PDF
        is_safe, msg, mime = inspect_file_security(b"<?php eval($_POST['cmd']); ?>", "malicious.pdf")
        self.assertFalse(is_safe)

    def test_05_cryptographic_audit_hash_chain(self):
        from database import SessionLocal
        db = SessionLocal()

        # Audit chain is initially valid
        is_valid, msg, broken_id = verify_audit_hash_chain(db)
        self.assertTrue(is_valid, f"Chain error: {msg}")

        db.close()

if __name__ == "__main__":
    unittest.main(verbosity=2)
