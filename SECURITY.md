# Security Policy for Secure Invoice AI

This document outlines the security policies, procedures, and best practices for the **Secure Invoice AI** project. We take the security of our application, user data, and financial records very seriously.

## Supported Versions

Currently, we provide security updates for the following versions of the application:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it immediately. We appreciate your efforts to responsibly disclose your findings.

### How to Report
1. Do **not** create a public GitHub issue for security vulnerabilities.
2. Email your findings directly to the project lead and security maintainer: **Yassine Latrous**.
3. Include the following details in your report:
   - A description of the vulnerability and its potential impact.
   - Steps to reproduce the issue (including any relevant payloads or scripts).
   - Potential mitigation or remediation if known.

### Response Timeline
- We will acknowledge receipt of your vulnerability report within **48 hours**.
- We will provide a status update or a preliminary assessment within **7 days**.
- If a patch or update is required, we will strive to release it as promptly as possible, and you will be credited for the discovery in the release notes (unless you prefer to remain anonymous).

## Security Architecture & Best Practices

**Secure Invoice AI** is built on a clean architecture model designed to inherently mitigate common security risks:

### 1. Data Encryption
- **In Transit**: All communications between the mobile application and backend services must be encrypted using TLS 1.2 or higher.
- **At Rest**: Sensitive user data, including mocked database states and authentication tokens, must be stored securely using platform-specific secure storage mechanisms (e.g., iOS Keychain, Android Keystore).

### 2. Authentication & Authorization
- The application uses Role-Based Access Control (RBAC) to restrict access to workspaces.
- Available roles include:
  - **Admin**: Full control over roles, settings, and workspace rules.
  - **Accountant**: Access restricted to validation, auditing, and processing of invoices.
  - **Client**: Access restricted to depositing and viewing their own invoices.
- Authentication tokens must have a limited lifespan and be securely refreshed.

### 3. Application Security (Mobile App)
- **Code Obfuscation**: Release builds must use code obfuscation (e.g., ProGuard/R8 on Android, proper stripping on iOS) to deter reverse engineering.
- **Input Validation**: All inputs (especially scanned OCR data and manual edits) are validated on the client side to prevent injection attacks and on the server side (when integrated).
- **Dependency Management**: All third-party Flutter and Dart dependencies must be regularly audited for vulnerabilities using `dart pub outdated` and `dart pub upgrade`.

## Continuous Integration & Security Scanning

We employ automated tools in our CI/CD pipelines to ensure code quality and security:
- **Linting**: Strict Dart linting rules are enforced to prevent insecure coding patterns.
- **Static Analysis**: The codebase is continuously analyzed for potential vulnerabilities and deprecated API usage.

## Acknowledgment
Security is a continuous process. We thank our community and contributors for helping us maintain the highest security standards for **Secure Invoice AI**.

---
*Maintained by Yassine Latrous*
