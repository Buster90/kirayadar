# Kiraya Manager — Kirayadar

Flutter rental / kiraya management app rebuilt from the Figma design "Kiraya Manager".
Design tokens: dark green #00362A, mint #B5EFDA, Plus Jakarta Sans, 390px frame, white cards, dark-green primary buttons.

## How to run

```bash
export PATH=$HOME/sdk/flutter/bin:$PATH
cd kirayadar
flutter pub get
flutter run
# or build:
flutter build apk --debug
flutter build web --release
```

## Demo login

- Welcome → Get Started → Phone & OTP
- Enter any mobile number, then OTP **4820** (shown as a demo hint in the app).
- Wrong code shows an error. Correct code → Onboarding → Dashboard.
- Login state persists with SharedPreferences. Log Out (Account tab) returns to Welcome.

## Screens (12)

1. Welcome — 2. Phone & OTP Login — 3. Onboarding Walkthrough — 4. Dashboard — 5. My Properties — 6. Property & Tenant Details — 7. Record Payment — 8. Add New Property — 9. Agreement Generator (Kirayanama) — 10. Reports & Analytics — 11. Profile & Settings — 12. Add Expense

Bottom nav (4 tabs): Home, Properties, Reports, Account. Auth / forms have no bottom nav.

## Seed data

6 units: Gulshan Flat B-4 (Tariq Jameel, Rs. 45,000, Paid), House 14-B Defence Phase 6 (Muhammad Aslam, Rs. 75,000, Paid), Shop #3 Saddar (Usman Ali Motors, Rs. 60,000, Paid), Flat B-2 Clifton Block 5 (Tariq Mehmood, Rs. 55,000, Overdue, CNIC 42101-7654321-9, Mobile 0321-9876543), Upper Portion G-9 Islamabad (Rashid Khan, Rs. 35,000, Due), Flat 402 Al-Rehman Heights (Farhan Zaidi, Rs. 60,000, Paid).
Dashboard collected / pending totals are computed from unit statuses, not hardcoded.
Ledger for Flat B-2 and 3 seed expenses are included. Data persists in SharedPreferences (JSON); seeded on first run only.

## Working features

- Search + All/Due/Paid/Overdue chips filter the dashboard and properties lists.
- Tapping a rent row opens Tenant Details. Mark Paid updates status, ledger, totals and progress.
- Record Payment saves to the ledger; Save & Send opens WhatsApp (wa.me) with a prefilled receipt; Save Only saves locally.
- Add Property validates required fields and adds the unit to the dashboard/properties.
- Agreement: term / notice update the preview; Download PDF generates a real PDF (pdf + share_plus); Share via WhatsApp opens wa.me.
- Reports: monthly bar chart and expenses donut are drawn with custom painters from real data. Add Expense updates reports. Export shares CSV / FBR statement text.
- Profile: WhatsApp toggle, language, grace-period stepper persist; copy buttons copy bank details; Log Out works.

## Firebase / Google Cloud Console (optional)

The app runs fully without Firebase — `FirebaseService.init()` catches any missing-config error and falls back to local storage only.

To enable Firebase:
1. Create a project in the Firebase Console (console.firebase.google.com) — this also creates a Google Cloud project.
2. Add an Android app (package `com.kirayadar.app`) and download `google-services.json` into `android/app/`.
3. Add an iOS app and download `GoogleService-Info.plist` into `ios/Runner/`.
4. In Firebase Console enable Authentication (Phone) and Cloud Firestore.
5. `firebase_core`, `cloud_firestore` and `firebase_auth` are already in `pubspec.yaml`.

Do NOT commit `google-services.json`, API keys, or any real credentials. No real keys are included in this repo.
