# CEO-IT Mobile Client & Secure Invoice AI Platform 🚀
**Auteur & Développeur Full-Stack : Yassine Latrous**

Bienvenue dans le dépôt officiel du projet **SecureInvoice AI** au sein de la plateforme **CEO-IT**, une solution d'entreprise intelligente, hautement sécurisée et certifiée pour la capture, l'analyse et la vérification automatisée de factures (OCR, conformité réglementaire, détection de fraude et sécurité d'entreprise).

---

## 🔒 Module de Sécurité & Backlog Khaled Amari (Implémenté à 100%)

Le système intègre l'ensemble des exigences de sécurité avancées formulées dans le cahier des charges de **Khaled Amari (Responsable Sécurité)** :

### 1. Contrôle d'Accès basé sur les Rôles (RBAC) & 6 Rôles Métier
L'application gère 6 rôles stricts avec matrice de permissions minimale :
- **Client** (`client@demo.com`) : Vue tableau de bord personnel, dépôt de pièces, consultation de ses propres factures et logs.
- **Assistant Comptable** (`assistant@demo.com`) : Consultation des dossiers attribués, dépôt de pièces, préparation des écritures comptables et déclarations.
- **Comptable (Resp. Dossier)** (`comptable@demo.com`) : Consultation des dossiers attribués, préparation des factures et déclarations.
- **Expert-Comptable (Validateur)** (`expert@demo.com`) : Validation comptable et fiscale, consultation du journal d'audit.
- **Auditeur (Lecture Seule)** (`auditeur@demo.com`) : Consultation globale en lecture seule et inspection des journaux d'audit.
- **Administrateur** (`admin@demo.com`) : Gestion des utilisateurs, attribution des rôles, configuration de la matrice de sécurité et des règles de conformité.

### 2. Séparation des Tâches (SoD - Separation of Duties)
- **Règle absolue** : L'utilisateur qui a créé/préparé une facture ou une écriture comptable ne peut **jamais** la valider lui-même.
- **Enforcement Backend & UI** : Si le préparateur tente une validation via l'API, le backend renvoie un code `403 Forbidden` (*Violation de la Séparation des Tâches*). Côté interface mobile/web, le bouton de validation est désactivé avec un badge d'avertissement clairs.

### 3. Politique de Mot de Passe & Protection Anti Brute-Force
- **Password Policy** : Exige un minimum de 12 caractères, avec majuscule, minuscule, chiffre et caractère spécial, hachés en PBKDF2-HMAC-SHA256.
- **Account Lockout** : 5 tentatives échouées entraînent un verrouillage de 5 minutes. 10 tentatives échouées entraînent un verrouillage de 24 heures.
- **Réponse Générique** : Tout échec d'authentification renvoie un message neutre ("Identifiants invalides") pour empêcher l'énumération de comptes.

### 4. Authentification Multi-Facteurs (TOTP MFA)
- **TOTP Obligatoire** : Exigé pour tout le personnel interne et l'administrateur (support Google Authenticator / Authy via PyOTP).
- **MFA Optionnel / Forcé** : Définissable au niveau tenant pour les clients.

### 5. Chaîne d'Audit Cryptographique Inviolable (SEC-AUD-02)
- **Cryptographic Hash Chain** : Chaque événement d'audit (`AuditLog`) intègre le hash SHA-256 de l'entrée précédente (`previous_hash` + payload `hash`).
- **Détection d'Altération** : Un endpoint de vérification (`/api/audit/verify-chain`) garantit l'intégrité à 100% du journal d'audit et détecte toute tentative de modification directe en base de données.

### 6. Isolation Stricte Multi-Tenancy (SEC-04)
- Filtrage automatique au niveau de l'ORM par `tenant_id`. Un client A tentant d'accéder aux pièces d'un client B reçoit un refus d'accès `404 Not Found` / `403 Forbidden`.

### 7. Inspection des Magic Bytes & Quarantaine d'Upload (SEC-05)
- **Validation des Magic Bytes** : Inspection binaire de l'en-tête (MIME type réel pour PDF, PNG, JPG, XLSX). Rejet strict du renommage d'extension d'exécutables.
- **Limite de 10 Mo** : Taille maximale contrôlée.
- **Pipeline de Quarantaine** : Téléversement en zone `/quarantine/` -> Analyse binaire antivirus -> Transfert en zone `/processed/` -> Traitement OCR.

---

## 📸 Galerie & Design Showcase

Découvrez l'interface mobile **CEO-IT / SecureInvoice AI** (palette Forest Green & Cream, animations fluides) :

### 1. Introduction & Onboarding

| Logo Officiel | Écran de Bienvenue | Tour Guidé Interactif |
| :---: | :---: | :---: |
| ![Brand Logo](screenshots/ceo_it_brand_logo.png) | ![Welcome Screen](screenshots/premium_onboarding_experience.png) | ![Onboarding Tour](screenshots/onboarding_tour.png) |

### 2. Authentification & Workspaces Dédiés (RBAC)

| Authentification Sécurisée | Espace Client | Espace Collaborateur Comptable | Espace Administrateur |
| :---: | :---: | :---: | :---: |
| ![Login Auth](screenshots/secure_login_auth.png) | ![Client Workspace](screenshots/client_workspace.png) | ![Accountant Workspace](screenshots/accountant_workspace.png) | ![Admin Workspace](screenshots/admin_role_control.png) |

### 3. Capture OCR & Analyse IA

| Écran de Scan & Capture | Dépôt de Document PDF | Animation de Reconstruction IA | Analyse en Cours (IA) |
| :---: | :---: | :---: | :---: |
| ![AI Capture Scan](screenshots/ai_capture_scan.png) | ![Document Deposit](screenshots/ai_capture_document_deposit.png) | ![Neural Reconstruction](screenshots/neural_ai_reconstruction.png) | ![Processing Extraction](screenshots/ai_processing_extraction.png) |

### 4. Audit de Fraude & Détails de Conformité

| Résultat d'Extraction & Audit | Détails de Facture & Conformité | Centre de Notifications |
| :---: | :---: | :---: |
| ![Extraction Audit](screenshots/ai_extraction_fraud_audit.png) | ![Invoice Compliance](screenshots/invoice_details_compliance.png) | ![Notification Center](screenshots/notification_center.png) |

---

## 📘 Architecture & Exécution des Tests de Sécurité

```bash
# Exécution du serveur backend FastAPI
python backend/main.py

# Exécution de la suite de tests de sécurité (RBAC, SoD, Hash Chain, Magic Bytes)
python backend/run_security_tests.py
```

### Résultats de la suite de tests (`run_security_tests.py`) :
- `test_01_password_policy` : **PASSED** (Validation politique mot de passe 12+ chars & réponse neutre).
- `test_02_rbac_permissions_matrix` : **PASSED** (Vérification des accès selon les 6 rôles).
- `test_03_separation_of_duties_sod` : **PASSED** (Blocage 403 en cas d'auto-validation par l'auteur).
- `test_04_magic_bytes_quarantine_inspection` : **PASSED** (Acceptation des vrais Magic Bytes, rejet des scripts malveillants).
- `test_05_cryptographic_audit_hash_chain` : **PASSED** (Validation d'intégrité de la chaîne SHA-256).

---

## 👤 Développeur & Maintenance
* **Développeur Principal** : **Yassine Latrous** (ENI Carthage)
* **Responsable Sécurité** : **Khaled Amari**
* **Projet** : **SecureInvoice AI / CEO-IT**
