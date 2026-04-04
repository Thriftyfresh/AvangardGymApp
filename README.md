# Avangard Gym - Management System

A comprehensive gym membership management application built with Flutter, following the BLoC architecture pattern.

## Features

### 🔐 Authentication & Roles
- Firebase Auth with email/password login
- Role-based access control (Superadmin / Admin)
- Auto-login with splash screen

### 👥 Member Management
- Add, edit, delete, freeze/unfreeze members
- Search by name, phone, or CPR
- Year-grouped member list with status tabs (All, Active, Inactive, Frozen)
- Upcoming birthdays tab
- Member detail screen with full history

### 📊 Charts & Analytics
- Membership status pie chart
- New members per month bar chart
- Revenue breakdown (Cash vs Card vs Benefit)
- Monthly revenue trend line chart
- Package distribution chart
- Filter by year and month

### 🔄 Google Sheets Integration
- Two-way sync with Google Sheets
- Smart sync: new members added, existing members updated with history
- Auto-append new members to Google Sheet when added from app

### 🔔 Notifications
- Local push notifications for expiring memberships (7, 3, 1 day warnings)
- Manual notification check from dashboard

### 💬 WhatsApp Integration
- Send membership reminders via WhatsApp
- Pre-formatted messages with member name and expiry details
- Direct call member from detail screen

### 📋 Audit Log
- Tracks all add, edit, delete actions
- Records which admin performed the action
- Timestamped activity feed

### 🎨 UI/UX
- Material Design 3
- Dark / Light mode toggle
- Custom splash screen with gym branding
- Responsive layout with overflow handling
- Navigation drawer with role-based menu items

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **BLoC Pattern** - State management
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Google Sheets API** - Spreadsheet integration
- **FL Chart** - Data visualization
- **URL Launcher** - WhatsApp & phone integration
- **Flutter Local Notifications** - Push notifications

## Architecture

```
lib/
├── bloc/           # BLoC state management
│   ├── admin/
│   ├── audit/
│   ├── auth/
│   ├── member/
│   └── sync/
├── core/           # Constants, services, theme
├── data/
│   ├── models/     # Data models
│   └── repositories/  # Data access layer
├── presentation/
│   ├── screens/    # App screens
│   └── widgets/    # Reusable widgets
└── main.dart
```

## Setup

1. Clone the repository
2. Create a Firebase project and enable Auth + Firestore
3. Run `flutterfire configure` to generate `firebase_options.dart`
4. Add your `serviceAccount.json` to `assets/`
5. Update the Google Sheet ID in `lib/core/constants.dart`
6. Run `flutter pub get`
7. Run `flutter run`

## Screenshots

*Coming soon*

## Author

**Fahad Hussain**

## License

This project is for portfolio/demonstration purposes.
