# 🔑 Quick API Key Setup Guide

## Step 1: Get Your Free Gemini API Key

1. Visit: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy your API key (starts with `AIza...`)

## Step 2: Create .env File

Create a file named `.env` in the root of the project (same folder as `pubspec.yaml`) with:

```env
GEMINI_API_KEY=AIzaSy...YOUR_ACTUAL_KEY_HERE
GOOGLE_OAUTH_CLIENT_ID=YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE
USE_BACKEND_API=false
BACKEND_URL=http://localhost:8000/api/v1
```

**Replace `AIzaSy...YOUR_ACTUAL_KEY_HERE` with your actual API key!**

## Step 3: Verify Setup

1. Save the `.env` file
2. Run the app
3. Go to the AI Chatbot screen
4. Send a message - you should see real AI responses instead of "Demo Mode"

## ✅ That's it!

The AI Assistant will now use Google's Gemini 1.5 Flash API for:
- Device diagnosis
- Technical chatbot
- Value estimation
- Repair recommendations
- Image analysis

## 🆓 Gemini API is FREE
- 15 requests per minute
- 1 million requests per day
- Perfect for development and testing

---

**Need help?** Make sure the `.env` file is in the root directory, not in a subfolder!

