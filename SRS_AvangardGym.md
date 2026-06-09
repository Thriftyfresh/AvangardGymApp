# Software Requirements Specification (SRS)
## Avangard Gym Management System
**Version:** 1.0  
**Author:** Fahad Hussain  
**Date:** May 2026  

---

## 1. Introduction

### 1.1 Purpose
This document describes the software requirements for the Avangard Gym Management System, a cross-platform mobile and web application built to manage gym memberships, track payments, and monitor member activity for Avangard Gym.

### 1.2 Scope
The Avangard Gym Management System is a Flutter-based application that provides:
- Separate management dashboards for Men's and Women's gym sections
- Member lifecycle management (add, edit, delete, freeze/unfreeze)
- Google Sheets two-way synchronization
- Role-based access control for multiple admins
- Analytics and reporting features
- Push notifications for expiring memberships
- WhatsApp integration for member reminders

### 1.3 Definitions and Acronyms
| Term | Definition |
|------|-----------|
| SRS | Software Requirements Specification |
| BLoC | Business Logic Component (state management pattern) |
| CPR | Civil Population Register (member ID number) |
| FCM | Firebase Cloud Messaging |
| RBAC | Role-Based Access Control |
| APK | Android Package Kit |

### 1.4 Technologies Used
- **Frontend:** Flutter (Dart)
- **State Management:** BLoC Pattern
- **Backend:** Firebase (Auth, Firestore)
- **Integration:** Google Sheets API v4
- **Notifications:** Flutter Local Notifications
- **Charts:** FL Chart
- **Communication:** URL Launcher (WhatsApp, Phone)

---

## 2. Overall Description

### 2.1 Product Perspective
The system replaces manual Excel-based membership tracking with a real-time cloud-based solution. It integrates with existing Google Sheets workflows to ensure a smooth transition.

### 2.2 Product Functions
1. Admin authentication and authorization
2. Member management (CRUD operations)
3. Membership status tracking (Active, Inactive, Frozen)
4. Google Sheets synchronization (bidirectional)
5. Analytics and charts
6. Daily reports by receptionist
7. Push notifications for expiring memberships
8. WhatsApp reminders
9. Audit logging
10. Membership history tracking

### 2.3 User Classes
| User Class | Description | Access Level |
|-----------|-------------|--------------|
| Superadmin | Full system access | All features |
| Admin | Member management only | Limited features |

### 2.4 Operating Environment
- **Mobile:** Android 5.0 (API 21) and above
- **Web:** Chrome, Edge (modern browsers)
- **Backend:** Firebase Cloud (Google Cloud Platform)
- **Internet:** Required for all operations

---

## 3. Functional Requirements

### 3.1 Authentication Module

#### FR-01: Admin Login
- The system shall allow admins to log in using email and password
- The system shall validate credentials against Firebase Authentication
- The system shall display an error message for invalid credentials
- The system shall auto-login if a valid session exists

#### FR-02: Role-Based Access
- The system shall assign roles (superadmin/admin) to each user
- Superadmins shall have access to all features
- Regular admins shall not access Admin Management, Charts, or Audit Log
- The system shall fetch the user role from Firestore on login

#### FR-03: Logout
- The system shall allow admins to log out from the drawer
- The system shall clear the session and redirect to the login screen

---

### 3.2 Member Management Module

#### FR-04: Add Member
- The system shall allow admins to add new members with the following fields:
  - Full Name (required)
  - CPR (Civil ID)
  - Phone Number
  - Birthday (date picker)
  - Membership Type (dropdown: 1 day, 1 month, 2 weeks, 3 month, 6 month, 1 year, special)
  - Package (dropdown: gym, 2in1, Boxing, crossfit, gym & Box)
  - Status (dropdown: active, inactive, frozen)
  - Start Date and End Date (date pickers)
  - Recept/Receptionist (dropdown: Sultan, Harris, Mikel, Abubakar, Andrey, Ashiraf, Astemir, Fahad, Nik, Zahra)
  - Benefit, Cash, Credit Card amounts
  - Referral source
- The system shall save the member to Firestore
- The system shall automatically append the member to the Google Sheet

#### FR-05: Edit Member
- The system shall allow admins to edit all member fields
- The system shall update the record in Firestore

#### FR-06: Delete Member
- Only superadmins shall be able to delete members
- The system shall show a confirmation dialog before deletion
- The system shall log the deletion in the audit log

#### FR-07: Freeze/Unfreeze Member
- The system shall allow admins to freeze or unfreeze a member's membership
- The system shall update the member status in Firestore
- The system shall show a confirmation dialog

#### FR-08: Member Search
- The system shall allow searching members by name, phone, or CPR
- Search results shall update in real-time as the user types

#### FR-09: Member History
- The system shall store all previous membership records as history
- The member detail screen shall display full membership history
- History shall include dates, package, payment details, and receptionist

---

### 3.3 Dashboard Module

#### FR-10: Statistics Overview
- The dashboard shall display:
  - Total members count
  - Active members count
  - Inactive members count
  - Frozen members count

#### FR-11: Expiring Soon
- The dashboard shall display members whose membership expires within 7 days
- Each expiring member card shall be tappable to send a WhatsApp reminder

---

### 3.4 Google Sheets Sync Module

#### FR-12: Sync from Sheets
- The system shall fetch all rows from the Google Sheet
- New members (new CPR) shall be added to Firestore
- Existing members with a newer datePaid shall be updated
- Old data shall be moved to the history subcollection before updating
- Members without CPR shall be skipped

#### FR-13: Add to Sheet
- When a new member is added from the app, the system shall automatically append a row to the Google Sheet with all member details in the correct column order

---

### 3.5 Notifications Module

#### FR-14: Expiry Notifications
- The system shall send local push notifications for memberships expiring in 7, 3, and 1 day
- Notifications shall be triggered on app launch and manually from the dashboard

---

### 3.6 WhatsApp Integration

#### FR-15: WhatsApp Reminder
- The system shall open WhatsApp with a pre-written message when the admin taps "Remind via WhatsApp"
- The message shall include the member's name and days remaining
- Phone numbers shall be automatically prefixed with +973 (Bahrain country code)

#### FR-16: Direct Call
- The system shall allow admins to call a member directly from the member detail screen

---

### 3.7 Charts & Analytics Module (Superadmin Only)

#### FR-17: Charts
- The system shall provide the following charts:
  - Membership Status Pie Chart (Active/Inactive/Frozen)
  - New Members Per Month Bar Chart
  - Revenue Breakdown Pie Chart (Cash/Card/Benefit)
  - Monthly Revenue Trend Line Chart
  - Package Distribution Pie Chart
- All charts shall support filtering by year and month

---

### 3.8 Daily Report Module

#### FR-18: Daily Report
- The system shall display a daily report showing members who paid on a selected date
- The report shall group members by receptionist
- The report shall show member name, package, membership type, and payment
- The system shall default to today's date with an option to pick any date

---

### 3.9 Admin Management Module (Superadmin Only)

#### FR-19: Add Admin
- Superadmins shall be able to add new admins with email, name, and role
- New admins shall be created in Firebase Authentication with a default password
- The system shall re-authenticate the current superadmin after creating the new admin

#### FR-20: Manage Admins
- Superadmins shall be able to change admin roles (admin/superadmin)
- Superadmins shall be able to remove admins

---

### 3.10 Audit Log Module (Superadmin Only)

#### FR-21: Audit Logging
- The system shall log all add, edit, and delete actions
- Each log entry shall include: admin email, action type, member name, details, and timestamp
- Logs shall be displayed in reverse chronological order

---

### 3.11 Women's Section

#### FR-22: Separate Women's Dashboard
- The system shall provide a completely separate dashboard for the women's gym section
- The women's section shall use a pink color theme
- The women's section shall have its own Firestore collection (women_members)
- The women's section shall sync with a separate Google Sheet

#### FR-23: Women's Features
- All features available in the men's section shall also be available in the women's section
- The women's drawer shall be accessible from the right side of the screen

---

## 4. Non-Functional Requirements

### 4.1 Performance
- The app shall load the member list within 5 seconds on a standard internet connection
- Search results shall appear within 1 second of typing
- Sync operations shall complete within 10 minutes for up to 8,000 rows

### 4.2 Security
- All data shall be transmitted over HTTPS
- Firebase Authentication shall be used for all admin access
- Service account credentials shall be stored as app assets (not exposed publicly)
- Role-based access shall be enforced at the UI level

### 4.3 Usability
- The app shall support both dark and light modes
- The app shall be responsive and work on various screen sizes
- All overflow issues shall be handled with scrollable layouts

### 4.4 Reliability
- Firebase Firestore shall serve as the single source of truth
- Google Sheets serves as a secondary backup/mirror
- Sync failures shall not affect Firestore data integrity

### 4.5 Maintainability
- The codebase shall follow the BLoC architecture pattern
- Code shall be organized into layers: data, bloc, presentation
- All sensitive configuration shall be stored in constants

---

## 5. System Architecture

### 5.1 Architecture Pattern
The application follows the **BLoC (Business Logic Component)** pattern:
- **Presentation Layer:** Screens and Widgets
- **BLoC Layer:** Events, States, and Business Logic
- **Data Layer:** Repositories and Models

### 5.2 Folder Structure
```
lib/
├── bloc/           # BLoC state management
│   ├── admin/
│   ├── audit/
│   ├── auth/
│   ├── member/
│   ├── sync/
│   └── women/
├── core/           # Constants, services, theme
├── data/
│   ├── models/     # Data models
│   └── repositories/  # Data access layer
├── presentation/
│   ├── screens/    # App screens
│   │   ├── charts/
│   │   └── women/
│   └── widgets/    # Reusable widgets
└── main.dart
```

### 5.3 Database Structure (Firestore)
```
firestore/
├── admins/
│   └── {adminId}/
│       ├── name, email, role, createdAt
├── members/
│   └── {memberId}/
│       ├── cpr, name, phone, birthday, email
│       ├── membership, package, status
│       ├── startDate, endDate, datePaid, monthPaid
│       ├── recept, benefit, cash, creditCard
│       ├── createdBy, lastEditedBy
│       └── history/ (subcollection)
├── women_members/
│   └── {memberId}/ (same structure as members)
└── audit_logs/
    └── {logId}/
        ├── adminEmail, action, memberName
        ├── memberId, details, timestamp
```

---

## 6. External Interfaces

### 6.1 Google Sheets API
- **API Version:** v4
- **Authentication:** Service Account (OAuth 2.0)
- **Scopes:** spreadsheets (read/write)
- **Men's Sheet ID:** Stored in AppConstants
- **Women's Sheet ID:** Stored in AppConstants

### 6.2 Firebase Services
- **Firebase Authentication:** Email/Password sign-in
- **Cloud Firestore:** NoSQL document database
- **Firebase Cloud Messaging:** Push notifications

### 6.3 WhatsApp
- **Integration:** URL Launcher with wa.me deep links
- **Format:** `https://wa.me/{phone}?text={message}`

---

## 7. Constraints

1. Internet connection is required for all operations
2. The app is designed for Bahrain phone numbers (+973)
3. Google Sheets must be shared with the service account email
4. Firebase project must have Authentication and Firestore enabled
5. Android minimum SDK version is 21 (Android 5.0)

---

## 8. Appendix

### 8.1 Member Status Definitions
| Status | Description |
|--------|-------------|
| Active | Membership is valid and not expired |
| Inactive | Membership has expired |
| Frozen | Membership is temporarily suspended |

### 8.2 Receptionist List
Sultan, Harris, Mikel, Abubakar, Andrey, Ashiraf, Astemir, Fahad, Nik, Zahra

### 8.3 Package Types
gym, 2in1, Boxing, crossfit, gym & Box

### 8.4 Membership Types
1 day, 1 month, 2 weeks, 3 month, 6 month, 1 year, special
