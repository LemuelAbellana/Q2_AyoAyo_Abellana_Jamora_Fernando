# Fix: Google Sign-In `NotInitializedError` on Web

## The Error You're Seeing

```
❌ Google Sign-In error: Instance of 'NotInitializedError'
❌ OAuth sign-in was cancelled by user
❌ Google sign-in returned null user
```

## What This Means

The Google Sign-In library is not properly initialized for **web**. This happens because the Client ID in `web/index.html` doesn't match your Google Cloud Console configuration.

---

## ✅ Solution: Update Google Cloud Console Client ID

### Step 1: Get Your Web Client ID from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Select your project (or create a new one)
3. Click **"+ CREATE CREDENTIALS"** → **"OAuth 2.0 Client ID"**
4. Choose **"Web application"**
5. Configure:
   - **Name:** "AyoAyo Web Client"
   - **Authorized JavaScript origins:**
     - `http://localhost:3000`
     - `http://localhost:8080`
     - `http://127.0.0.1:3000`
   - **Authorized redirect URIs:**
     - `http://localhost:3000/auth.html`
     - `http://localhost:8080/auth.html`
6. Click **"CREATE"**
7. **Copy the Client ID** (format: `xxxxx-xxxxx.apps.googleusercontent.com`)

### Step 2: Update web/index.html

Open [web/index.html](web/index.html) and find line 32:

**Current (placeholder):**
```html
<meta name="google-signin-client_id" content="583476631419-3ar76b3sl0adai5vh0p42c467tn1f3s0.apps.googleusercontent.com">
```

**Replace with YOUR Client ID:**
```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_CLIENT_ID_HERE.apps.googleusercontent.com">
```

**Example:**
```html
<meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
```

### Step 3: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Step 4: Test Google Sign-In

1. Open the app in Chrome
2. Click "Sign in with Google"
3. Select your Google account
4. ✅ You should now see: `✅ Google Sign-In successful: your-email@example.com`

---

## Alternative: Test on Mobile Instead

If you don't want to set up web OAuth right now, you can test on **Android/iOS** instead:

### For Android:

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Run: `flutter run -d <device-name>`

### For iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to your Xcode project
3. Run: `flutter run -d <device-name>`

---

## Why This Happened

### The Change Made:

In [lib/services/oauth_service.dart](lib/services/oauth_service.dart), I changed:

**Before:**
```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: kIsWeb ? ApiConfig.googleOAuthClientId : null,  // ❌ Read from .env
  forceCodeForRefreshToken: !kIsWeb,
);
```

**After:**
```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: null,  // ✅ Use platform-specific config
  forceCodeForRefreshToken: !kIsWeb,
);
```

### Why the Change:

1. **For Web:** The `google_sign_in` package reads the Client ID from the `<meta>` tag in `web/index.html`
2. **For Mobile:** The package reads from `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
3. **Setting `clientId: null`** tells the package to use the platform-specific configuration

The `.env` file approach doesn't work well for web because the Client ID needs to be embedded in the HTML before the app loads.

---

## Complete Setup Checklist

### ✅ Web Setup:

- [ ] Create OAuth 2.0 Client ID in Google Cloud Console (Web Application type)
- [ ] Add authorized JavaScript origins: `http://localhost:3000`, `http://localhost:8080`
- [ ] Copy the Client ID
- [ ] Update `web/index.html` line 32 with your Client ID
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `flutter run -d chrome`
- [ ] Test Google Sign-In

### ✅ Android Setup:

- [ ] Enable Google Sign-In in Firebase Console
- [ ] Download `google-services.json`
- [ ] Place in `android/app/google-services.json`
- [ ] Add SHA-1 fingerprint to Firebase Console
- [ ] Run `flutter run` on Android device/emulator

### ✅ iOS Setup:

- [ ] Enable Google Sign-In in Firebase Console
- [ ] Download `GoogleService-Info.plist`
- [ ] Add to Xcode project
- [ ] Update `Info.plist` with URL scheme
- [ ] Run `flutter run` on iOS device/simulator

---

## Troubleshooting

### Issue: "popup blockers are disabled" message

**Solution:**
- Check Chrome settings: `chrome://settings/content/popups`
- Allow popups for `localhost`

### Issue: "Access blocked: This app's request is invalid"

**Solution:**
- Verify the Client ID in `web/index.html` matches Google Cloud Console
- Check authorized JavaScript origins include your localhost URL

### Issue: Still getting `NotInitializedError`

**Solution:**
1. Clear browser cache (Ctrl+Shift+Del)
2. Hard reload (Ctrl+Shift+R)
3. Run: `flutter clean && flutter pub get`
4. Restart browser

### Issue: "The OAuth client was not found"

**Solution:**
- Make sure you created a **Web Application** OAuth client, not Android/iOS
- Wait 5-10 minutes for Google's servers to propagate the changes

---

## Quick Reference: Required Files

### Web OAuth:
- **File:** `web/index.html`
- **Line:** 32
- **What to update:** `<meta name="google-signin-client_id" content="YOUR_CLIENT_ID">`

### Android OAuth:
- **File:** `android/app/google-services.json`
- **Get from:** Firebase Console → Project Settings → Download

### iOS OAuth:
- **File:** `ios/Runner/GoogleService-Info.plist`
- **Get from:** Firebase Console → Project Settings → Download

---

## Testing Without Backend

Make sure `.env` has:
```env
USE_BACKEND_API=false
```

This ensures OAuth works locally without needing the Laravel backend.

---

## Expected Console Output (Success)

```
🚀 Starting Google sign-in from login screen...
🎯 You can now select any Google account to sign in with
🔐 Starting OAuth sign-in process for provider: google
🔐 Attempting Google OAuth...
🚀 Starting Google Sign-In process...
🌐 Running on web - ensure popup blockers are disabled
📋 Make sure web/index.html has correct Client ID in meta tag
✅ Google Sign-In successful: your-email@example.com
✅ OAuth authentication successful for user: your-email@example.com
⚠️ Backend API is disabled - using local OAuth data only
💾 User data saved locally
```

---

## Summary

**The Fix:**
1. Get Web Client ID from Google Cloud Console
2. Update `web/index.html` line 32 with your Client ID
3. Run `flutter clean && flutter pub get`
4. Test in Chrome

**Files Modified:**
- [lib/services/oauth_service.dart](lib/services/oauth_service.dart) - Changed `clientId` to `null` for platform-specific config
- [web/index.html](web/index.html) - Need to update with YOUR Client ID

**That's it!** Google Sign-In will work once you update the Client ID.

Need help getting the Client ID? See the detailed steps in **Step 1** above.
