# AyoAyo - AI-Powered Device Diagnosis System

## Overview

This enhanced diagnosis system uses a Retrieval-Augmented Generation (RAG) model powered by Google's Gemini AI to provide comprehensive mobile device health assessments and value estimations.

## Features

### 🤖 AI-Powered Analysis
- **RAG Model Integration**: Uses Gemini AI with comprehensive knowledge base
- **Image Analysis**: Analyzes device photos to identify physical damage
- **Smart Valuation**: Philippine market-specific pricing and recommendations
- **Confidence Scoring**: AI provides confidence levels for assessments

### 📱 Device Assessment
- **Battery Health**: Accurate battery condition assessment
- **Screen Analysis**: Identifies cracks, dead pixels, touch issues
- **Hardware Evaluation**: Overall device condition rating
- **Issue Detection**: Automatic identification of common problems

### 💰 Value Engine
- **Current Market Value**: Real-time Philippine peso valuations
- **Post-Repair Value**: Estimated value after repairs
- **Parts Value**: Component value for recycling
- **Repair Cost Estimation**: Accurate repair cost predictions

### 🛠️ Smart Recommendations
- **Prioritized Actions**: AI-ranked repair/disposal recommendations
- **Local Market Context**: Davao-specific market considerations
- **Cost-Benefit Analysis**: ROI calculations for repairs vs replacement

## Architecture

### Core Components

1. **Models** (`/lib/models/`)
   - `device_diagnosis.dart`: Data models for diagnosis and results
   - `pathway.dart`: Existing pathway enumerations

2. **Services** (`/lib/services/`)
   - `gemini_diagnosis_service.dart`: RAG implementation with Gemini AI

3. **Providers** (`/lib/providers/`)
   - `diagnosis_provider.dart`: State management for diagnosis flow

4. **Widgets** (`/lib/widgets/diagnosis/`)
   - `diagnosis_form.dart`: Enhanced form with image upload
   - `results_view.dart`: AI-powered results display
   - `image_upload_placeholder.dart`: Camera/gallery image picker

5. **Configuration** (`/lib/config/`)
   - `api_config.dart`: API key and demo mode settings

### RAG Implementation

The system implements RAG using:

1. **Knowledge Base**: Comprehensive device diagnostic database including:
   - Common device issues and symptoms
   - Philippines market pricing data
   - Repair cost estimates
   - Regional market conditions

2. **Retrieval**: Context-aware information retrieval based on:
   - Device model and brand
   - Identified issues from images
   - User-provided symptoms
   - Market conditions

3. **Generation**: AI-powered analysis combining:
   - Retrieved knowledge base information
   - Image analysis results
   - Market data
   - User context

## Setup Instructions

### 1. API Configuration

Edit `/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with your actual Gemini API key
  static const String geminiApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
  
  // Set to false for production with real API key
  static const bool useDemoMode = false;
  
  // Enable image analysis (requires API key)
  static const bool enableImageAnalysis = true;
}
```

### 2. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Replace the placeholder in `api_config.dart`

### 3. Demo Mode

The system includes a sophisticated demo mode that:
- Provides realistic assessments without API calls
- Uses device model to generate appropriate valuations
- Simulates AI analysis with market-specific data
- Perfect for development and testing

## Usage

### Basic Diagnosis Flow

1. **Input Device Info**: User enters device model and optional details
2. **Image Upload**: Optional photos for visual analysis
3. **AI Processing**: RAG model analyzes input and generates assessment
4. **Results Display**: Comprehensive diagnosis with recommendations

### Image Analysis

The system can analyze device images to detect:
- Physical damage (cracks, dents, scratches)
- Screen condition
- Water damage indicators
- Wear patterns
- Component condition

### Value Assessment

Provides accurate market valuations considering:
- Device age and model
- Condition assessment
- Local market demand (Philippines/Davao)
- Repair costs vs. replacement value

## Technical Features

### State Management
- Uses Provider pattern for reactive state management
- Clean separation of UI and business logic
- Efficient state updates and rebuilds

### Error Handling
- Graceful fallback to demo mode on API failures
- User-friendly error messages
- Retry mechanisms for network issues

### Image Processing
- Automatic image compression and optimization
- Support for camera and gallery selection
- Multiple image upload (up to 3 images)
- Smart image analysis with AI

### Performance
- Async operations with loading states
- Efficient memory management
- Optimized API calls
- Local caching capabilities

## Market Integration

### Philippines-Specific Features
- Philippine Peso (₱) currency formatting
- Davao City market conditions
- Local repair shop partnerships
- Regional pricing considerations

### Device Database
Comprehensive coverage of popular devices:
- iPhone models (8 through 15)
- Samsung Galaxy series
- Xiaomi/Redmi devices
- OPPO/Vivo smartphones
- Huawei devices

## Future Enhancements

1. **Enhanced RAG**
   - Real-time market data integration
   - User feedback learning
   - Expanded knowledge base

2. **Advanced Features**
   - Barcode/QR code scanning
   - Serial number validation
   - Warranty check integration

3. **Social Features**
   - Community reviews
   - Technician ratings
   - Repair history tracking

## Development Notes

### Demo Mode Benefits
- No API costs during development
- Realistic testing scenarios
- Offline development capability
- Easy integration testing

### API Integration
- Structured prompts for consistent responses
- JSON parsing with fallback handling
- Rate limiting and error recovery
- Cost optimization strategies

## Support

For issues related to:
- **API Configuration**: Check `api_config.dart` settings
- **Image Upload**: Verify camera/storage permissions
- **Analysis Results**: Enable demo mode for testing
- **Performance**: Monitor API usage and optimize calls

## Contributing

When contributing to the diagnosis system:
1. Test with demo mode first
2. Validate with real devices when possible
3. Update knowledge base as needed
4. Maintain Philippines market focus
