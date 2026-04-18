# Firebase Setup Guide - Phase 1 Complete

## Automated Installations Done ✓
- ✅ Added Firebase dependencies to `pubspec.yaml`
- ✅ Created `lib/services/firebase_service.dart` (initialization singleton)
- ✅ Created `lib/services/firebase_options.dart` (template config)
- ✅ Updated `lib/main.dart` to initialize Firebase on app startup
- ✅ Updated Android Gradle files for Firebase plugin support

---

## Next Steps (Manual - REQUIRED before running app)

### **Step 1: Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"** 
3. Name it (e.g., "Poultry Farm Management")
4. Accept terms → **Create project** (wait ~2 min)

### **Step 2: Register Android App**

1. In Firebase Console, click **"Add app"** → **Android**
2. **Android package name**: `com.example.first_app` (from `android/app/build.gradle.kts`)
3. **App nickname**: "Poultry Farm Mobile" (optional but helps)
4. Click **"Register app"** → **Next**

### **Step 3: Download google-services.json**

1. Firebase Console shows: **"Download google-services.json"**
2. Click **Download** 
3. Move downloaded file to: `android/app/google-services.json`
   - Path must be: `d:\6th semester\MAD\flutter_app\Project\android\app\google-services.json`

### **Step 4: Generate firebase_options.dart**

Run this command in your project root:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

This auto-generates `lib/services/firebase_options.dart` with your actual Firebase config.

**If flutterfire CLI is not found:**
```bash
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure
```

### **Step 5: Enable Authentication & Firestore**

Back in Firebase Console:

1. **Authentication Tab**
   - Click **"Get Started"**
   - Enable **Email/Password** 
   - (Optional) Enable **Phone** or **Google Sign-in**

2. **Firestore Database Tab**
   - Click **"Create Database"**
   - Select **"Start in production mode"** (you'll define rules in Step 6)
   - Location: Choose your region (e.g., us-central1)
   - Click **"Create"**

3. **Storage Tab** (for image uploads)
   - Click **"Get Started"**
   - Accept default security rules
   - Click **"Done"**

### **Step 6: Set Firestore Security Rules**

In Firebase Console → **Firestore Database** → **Rules tab**, replace all with:

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow only authenticated users to access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Allow nested collections under user (farms, inventory, etc.)
      match /{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

Click **Publish** to apply rules.

### **Step 7: Test Firebase Connection**

Run your app:

```bash
flutter clean
flutter pub get
flutter run
```

**Expected console output:**
```
✓ Firebase initialized successfully
```

**Errors?**
- If `google-services.json` not found → check file path in Step 3
- If authentication error → re-download `google-services.json`
- If Firestore permission denied → check security rules in Step 6

---

## What Firebase Provides (Now Ready)

✅ **Authentication**: Login/register with email + phone verification
✅ **Firestore Database**: Real-time cloud storage for inventory, batches, feed
✅ **Storage**: Image uploads for poultry, batches, profiles
✅ **Security**: User-scoped data (each user only sees their farm)
✅ **Real-time Sync**: Multi-device updates without refresh

---

## Phase 1 Verification

After completing all steps above:

- [ ] `google-services.json` exists at `android/app/google-services.json`
- [ ] `lib/services/firebase_options.dart` has real Firebase config (not placeholders)
- [ ] `flutter run` shows no Firebase initialization errors
- [ ] Firestore Database ✅ created in Firebase Console
- [ ] Authentication (Email/Password) ✅ enabled in Firebase Console
- [ ] Firestore Security Rules ✅ published
- [ ] Firebase Storage ✅ created

Once all checks pass, you're ready for **Phase 2: Authentication Integration** 🎉

---

## Troubleshooting

**"google-services.json not found"**
- Verify exact path: `android/app/google-services.json`
- Re-download from Firebase Console

**"Invalid Firebase API key"**
- Delete and re-download `google-services.json`
- Wait 5 sec after downloading, then try again

**"Firestore permission denied"**
- Ensure security rules are published in Firebase Console (Step 6)
- Try adding test rule temporarily: `allow read, write;` (production change later)

**"flutterfire_cli not found"**
- Run: `dart pub global activate flutterfire_cli` (note: uses `dart`, not `flutter`)
- Then: `dart pub global run flutterfire_cli:flutterfire configure`

---

## Need help?

Firebase docs: https://firebase.flutter.dev
Firestore security rules: https://firebase.google.com/docs/firestore/security/start
