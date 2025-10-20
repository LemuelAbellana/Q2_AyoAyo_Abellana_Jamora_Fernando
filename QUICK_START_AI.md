# 🚀 AI Assistant - Quick Start Guide

## ⚡ 3-Minute Setup

### Step 1: Get API Key (1 minute)
1. Go to: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key (starts with `AIza...`)

### Step 2: Create .env File (1 minute)
Create file `.env` in project root:
```env
GEMINI_API_KEY=paste_your_key_here
```

### Step 3: Test (1 minute)
```bash
# Test setup
dart test_ai_setup.dart

# Or run on Windows
test-ai-setup.bat

# Run app
flutter run
```

## ✅ Verify It's Working

### In Console:
```
✅ AI Chatbot: Gemini 1.5 Flash ready
✅ Diagnosis Service: Gemini 1.5 Flash ready
✅ Image Analysis: Gemini 1.5 Flash Vision ready
```

### In App:
- AI Chatbot gives detailed responses (not "Demo Mode")
- Device diagnosis includes AI analysis
- Image analysis identifies actual device models

## 🎯 What You Get

### Gemini 1.5 Flash Powers:
- ✅ **AI Chatbot** - Technical assistance
- ✅ **Device Diagnosis** - Smart analysis
- ✅ **Image Analysis** - Device recognition
- ✅ **Value Estimation** - AI pricing
- ✅ **Repair Recommendations** - Smart suggestions
- ✅ **Upcycling Ideas** - Creative reuse
- ✅ **Resell Analysis** - Market insights

## 🆓 Free Tier

Gemini 1.5 Flash includes:
- 15 requests/minute
- 1,500 requests/day
- Perfect for development!

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| "Demo Mode Active" | Add API key to .env file |
| "Invalid API Key" | Check key starts with `AIza` |
| "Network Error" | Check internet connection |
| Still demo mode | Restart app after creating .env |

## 📚 More Info

- **Detailed Setup:** `SETUP_API_KEY.md`
- **Full Documentation:** `AI_ASSISTANT_FIXED.md`
- **Get Help:** Check console messages

---

**That's it!** Your AI Assistant should be working with Gemini 1.5 Flash. 🎉

