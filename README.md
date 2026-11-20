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

## Firebase / Google Cloud Console — Firestore sync

> Connected project: **kirayadar** (Android app `com.kirayadar.app`).
> `android/app/google-services.json` and `lib/firebase_options.dart` are
> configured on the dev machine only and are gitignored — never commit them.

### (a) Works fully offline / without Firebase

The app is **offline-first**. All data (properties, ledger, expenses,
settings) is saved locally in SharedPreferences first, so every feature
works with no Firebase project at all. The Dashboard and Profile screens
show **"Saved locally"** in that case. `FirebaseService.init()` catches
any missing-config error and the app never crashes without
`google-services.json` / `GoogleService-Info.plist`.

When Firebase *is* configured, the same local save happens first, then
the change syncs to Firestore in the background (fire-and-forget). On
startup the app loads local data instantly, then pulls Firestore and
merges: Firestore wins only for a record whose `updatedAt` is newer than
the local copy, otherwise local is kept. If Firestore is empty and local
has data, local data is pushed up to Firestore instead of being wiped.
The indicator then reads **"Saved to Firebase • last synced HH:MM"**
— tap it to force a manual sync. Firestore offline persistence is
enabled, so reads/writes also work with no network and sync later.

### (b) To enable Firebase (go live)

1. Create a project in the Firebase Console (console.firebase.google.com)
   — this also creates a Google Cloud project.
2. Add an Android app (package `com.kirayadar.app`) and download
   `google-services.json` into `android/app/`.
3. Add an iOS app (bundle id `com.kirayadar.app`) and download
   `GoogleService-Info.plist` into `ios/Runner/`.
4. Recommended: run `flutterfire configure --project=<your-project-id>`
   (install with `dart pub global activate flutterfire_cli`). It
   generates a real `lib/firebase_options.dart`. A commented template is
   at `lib/firebase_options.dart.template` — copy it to
   `lib/firebase_options.dart` and paste the values from Firebase
   Console → Project settings → Your apps, if you do it manually.
5. In Firebase Console enable **Authentication → Phone** (the OTP login
   flow will use this later; no anonymous sign-in is done by the app)
   and **Firestore Database** (start in production mode, then add the
   rules below).
6. `firebase_core`, `cloud_firestore` and `firebase_auth` are already in
   `pubspec.yaml`. Run `flutter pub get` again after configuring.

Do NOT commit `google-services.json`, `GoogleService-Info.plist`,
`firebase_options.dart` (the real one), API keys, or any real
credentials. No real keys are included in this repo.

### Firestore rules

Start with test mode while developing, then lock it down. In
Firestore Console → Rules, use the locked rules below (each landlord
only sees their own data; the landlord ID is the signed-in user's UID,
or the stable local ID when not signed in):

```
// Locked mode — each landlord reads/writes only their own tree.
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /landlords/{landlordId}/{document=**} {
      allow read, write: if request.auth != null
        && request.auth.uid == landlordId;
    }
  }
}
```

For a quick local test *before* Phone Auth is wired up, use test mode
for at most 30 days (Console → Rules → test mode, expires automatically):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 12, 20);
    }
  }
}
```

Note: with the locked rules above, data only syncs after the landlord
signs in (Phone Auth). Until then the app keeps working locally and
shows "Saved locally".

### (c) Data model / collections

```
landlords/{landlordId}/properties/{propertyId}
  ├─ fields: id, title, subtitle, location, tenantName, tenantPhone,
  │           tenantCnic, rent, status, dueDay, receivedNote, monthsLeft,
  │           security, leaseStart, leaseEnd, tenantSince, beds, updatedAt
  └─ ledger/{ledgerEntryId}   (subcollection per property)
        fields: id, unitId, month, amount, status, method, date,
                receipt, updatedAt
landlords/{landlordId}/expenses/{expenseId}
  fields: id, propertyTitle, category, title, amount, date, method,
          paidTo, notes, updatedAt
landlords/{landlordId}/settings/profile   (single document)
  fields: whatsappReminders, graceDays, language, updatedAt
```

`landlordId` is the FirebaseAuth UID when signed in, otherwise the
stable local ID `local-landlord-muhammad-asif-khan` stored in
SharedPreferences (`landlordId` key). `updatedAt` is a Firestore
Timestamp (with an `updatedAtMs` mirror for merging).

### (d) How to verify data is saving in Firestore

1. Configure Firebase as in (b) and run the app.
2. In the app, mark a rent as Paid, record a payment, or add an expense.
   The Dashboard/Profile indicator should change to
   "Saved to Firebase • last synced HH:MM".
3. Open Firebase Console → Firestore Database → Data. You should see:
   `landlords` → `<landlordId>` → `properties` → the unit you changed,
   with its `ledger` subcollection, plus `expenses` and
   `settings/profile`.
4. If the indicator stays on "Saved locally", Firebase is not
   configured yet (missing `google-services.json` /
   `GoogleService-Info.plist` / `firebase_options.dart`) — the app is
   still fully working locally, and no data is lost.
