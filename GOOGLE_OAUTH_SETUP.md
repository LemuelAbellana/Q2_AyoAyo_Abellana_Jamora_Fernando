# Google OAuth Setup Guide for AyoAyo App

## 🚀 Quick Setup (3 minutes)

### Step 1: Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable required APIs:
   - Google+ API
   - Google Sign-In API

### Step 2: Create OAuth Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Configure OAuth consent screen (if prompted)
4. Choose application type: "Web application"
5. Add authorized origins:
   - `http://localhost:5000` (for development)
   - Add your production domain when deploying
6. Click "Create"
7. Copy the **Client ID** (format: `123456789012-abc123def456.apps.googleusercontent.com`)

### Step 3: Configure Your App

#### For Web:
Update `web/index.html`:
```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com">
```

#### For Mobile (Android):
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

### Step 4: Test
1. Run your app: `flutter run -d chrome --web-port=5000`
2. Open browser developer tools (F12) to see console logs
3. Click the Google Sign-In button
4. Check console for detailed logs and error messages
5. If popup doesn't work, try the troubleshooting steps below

## 🔧 Troubleshooting

### Error: "ClientID not set"
- Check that the meta tag in `web/index.html` has your actual client ID
- Make sure the client ID format is correct

### Error: "redirect_uri_mismatch"
- Add `http://localhost:5000` to Authorized origins in Google Cloud Console
- For production, add your domain

### Error: "Access blocked: This app's request is invalid"
- Make sure your OAuth consent screen is configured
- Check that the project is not in "Testing" mode

### Popup Issues (Most Common)
- **Popup blocked**: Disable popup blockers in your browser
- **Popup closes immediately**: Check browser console for JavaScript errors
- **CORS errors**: Make sure your domain is in authorized origins
- **Mixed content**: Ensure you're using HTTPS in production

### Browser-Specific Fixes
- **Chrome**: Allow popups for localhost in site settings
- **Firefox**: Check popup settings in privacy settings
- **Safari**: Allow popups and redirects in preferences

### Debug Steps
1. Open browser developer tools (F12)
2. Go to Console tab
3. Try Google Sign-In and check for detailed error logs
4. Look for network errors in Network tab
5. Check Application tab for local storage issues

### People API Error (Common)
If you see "People API has not been used...SERVICE_DISABLED":
- **Don't worry!** This is handled automatically by the app
- The app will fall back to basic authentication
- No manual intervention needed
- If you want full profile data, enable People API:
  1. Go to: https://console.cloud.google.com/apis/library
  2. Search for "People API"
  3. Click "Google People API"
  4. Click "ENABLE"

## 📱 Platform-Specific Notes

### Web
- Uses meta tag configuration
- Works with Flutter web hot reload
- Requires proper CORS setup for production

### Mobile (Android/iOS)
- Uses `google-services.json` configuration
- Automatic client ID detection
- Requires SHA-1 fingerprint for release builds

## 🔐 Security Notes

- Never commit your actual client ID to version control
- Use environment variables for production deployments
- Regularly rotate your OAuth credentials

## 🆘 Need Help?

If you encounter issues:
1. Check the browser console for detailed error messages
2. Verify your client ID format and configuration
3. Make sure APIs are enabled in Google Cloud Console
4. Test with a simple HTML page first (outside Flutter)
