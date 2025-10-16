# AyoAyo System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Mobile Client Layer                          │
│                      (Flutter - Dart/iOS/Android)                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │  UI/Screens      │  │  Providers       │  │  Services        │  │
│  │  • Scanner       │  │  • Device        │  │  • Recognition   │  │
│  │  • Passport      │  │  • Diagnosis     │  │  • User          │  │
│  │  • Home          │  │  • Auth          │  │  • Database      │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  │
│           │                     │                      │             │
│           └─────────────────────┴──────────────────────┘             │
│                                 │                                    │
│                                 ▼                                    │
│                    ┌─────────────────────────┐                      │
│                    │   API Service Layer     │                      │
│                    │   (Optional Toggle)     │                      │
│                    └─────────────────────────┘                      │
│                                 │                                    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  │
                                  │ HTTP/REST
                                  │ (JSON)
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Backend API Layer                            │
│                      (Laravel 10 - PHP 8.1)                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │  API Routes      │  │  Controllers     │  │  Middleware      │  │
│  │  • /auth/*       │  │  • Auth          │  │  • Sanctum       │  │
│  │  • /device-*     │  │  • Recognition   │  │  • CORS          │  │
│  │  • /passports/*  │  │  • Passport      │  │  • Throttle      │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  │
│           │                     │                      │             │
│           └─────────────────────┴──────────────────────┘             │
│                                 │                                    │
│                                 ▼                                    │
│                    ┌─────────────────────────┐                      │
│                    │   Eloquent ORM Models   │                      │
│                    │   • User                │                      │
│                    │   • Device              │                      │
│                    │   • DevicePassport      │                      │
│                    │   • Diagnosis           │                      │
│                    └─────────────────────────┘                      │
│                                 │                                    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  │
                                  │ SQL
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Data Storage Layer                           │
│                          (MySQL 5.7+)                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  users       │  │  devices     │  │  device_     │              │
│  │              │  │              │  │  passports   │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                 │                 │                       │
│         └─────────────────┴─────────────────┘                       │
│                           │                                          │
│  ┌──────────────┐  ┌──────┴───────┐  ┌──────────────┐              │
│  │  diagnoses   │  │  device_     │  │  value_      │              │
│  │              │  │  images      │  │  estimations │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Data Flow: Device Scanning

### Step-by-Step Process

```
1. USER ACTION
   ┌─────────────────────────┐
   │  User opens scanner     │
   │  Takes device photos    │
   └───────────┬─────────────┘
               │
               ▼
2. CAMERA CAPTURE
   ┌─────────────────────────┐
   │  CameraDeviceScanner    │
   │  • ImagePicker          │
   │  • File storage         │
   └───────────┬─────────────┘
               │
               ▼
3. AI RECOGNITION
   ┌─────────────────────────┐
   │  Gemini AI Analysis     │
   │  • Device model         │
   │  • Manufacturer         │
   │  • Confidence score     │
   └───────────┬─────────────┘
               │
               ▼
4. SAVE DECISION (Feature Flag)
   ┌─────────────────────────┐
   │  if (useBackendApi)     │
   │    → Laravel API        │
   │  else                   │
   │    → Local SQLite       │
   └───────────┬─────────────┘
               │
               ▼
5A. BACKEND SAVE              5B. LOCAL SAVE
   ┌─────────────────────┐       ┌─────────────────────┐
   │  POST /device-      │       │  DatabaseService    │
   │  recognition/save   │       │  SQLite insert      │
   │                     │       │                     │
   │  Creates:           │       │  Creates:           │
   │  • Device           │       │  • Local record     │
   │  • Diagnosis        │       │                     │
   │  • Value Est.       │       │                     │
   │  • Passport         │       │                     │
   │  • Images           │       │                     │
   │  • History          │       │                     │
   └─────────┬───────────┘       └─────────┬───────────┘
             │                             │
             └──────────────┬──────────────┘
                            │
                            ▼
6. UI UPDATE
   ┌─────────────────────────┐
   │  DeviceProvider         │
   │  • Refresh list         │
   │  • Show success         │
   │  • Update UI            │
   └─────────────────────────┘
```

## Authentication Flow

### OAuth Sign-In (Google)

```
┌───────────┐                                                    ┌───────────┐
│  Flutter  │                                                    │  Laravel  │
│    App    │                                                    │  Backend  │
└─────┬─────┘                                                    └─────┬─────┘
      │                                                                │
      │  1. User clicks "Sign in with Google"                         │
      ├───────────────────────────────────────────────────────────────┤
      │                                                                │
      │  2. RealGoogleAuth.signIn()                                   │
      │     • Opens Google OAuth                                      │
      │     • User selects account                                    │
      │     • Returns oauthUserData                                   │
      │                                                                │
      │  3. if (useBackendApi)                                        │
      │     POST /auth/oauth-signin                                   │
      ├──────────────────────────────────────────────────────────────▶│
      │     {                                                          │
      │       uid, email, display_name,                               │
      │       photo_url, auth_provider                                │
      │     }                                                          │
      │                                                                │
      │                                              4. Check DB       │
      │                                                 • Find by uid  │
      │                                                 • Or create    │
      │                                                 • Update login │
      │                                                                │
      │  5. Returns user + token                                      │
      │◀──────────────────────────────────────────────────────────────│
      │     {                                                          │
      │       success: true,                                           │
      │       user: {...},                                             │
      │       token: "xyz..."                                          │
      │     }                                                          │
      │                                                                │
      │  6. ApiService.setToken(token)                                │
      │     Save user session                                         │
      │                                                                │
      │  7. Navigate to home                                          │
      │                                                                │
```

## Database Schema Relationships

```
┌──────────────────┐
│      users       │
├──────────────────┤
│ • id             │───┐
│ • uid            │   │
│ • email          │   │
│ • display_name   │   │
│ • auth_provider  │   │
└──────────────────┘   │
                       │
                       │ 1:N
                       │
        ┌──────────────┼────────────────┬──────────────────────┐
        │              │                │                      │
        ▼              ▼                ▼                      ▼
┌──────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐
│device_       │ │ diagnoses   │ │ device_      │ │ device_recog_    │
│passports     │ │             │ │ images       │ │ history          │
├──────────────┤ ├─────────────┤ ├──────────────┤ ├──────────────────┤
│• id          │ │• id         │ │• device_id   │ │• user_id         │
│• user_id     │─┐│• user_id   │ │• uploaded_by │ │• device_model    │
│• device_id   │ ││• device_id │ │              │ │• manufacturer    │
│• passport_   │ ││             │ │              │ │• confidence      │
│  uuid        │ │└─────────────┘ └──────────────┘ └──────────────────┘
│• last_diag_  │ │
│  nosis_id    │ │
└──────────────┘ │
        │        │
        │ N:1    │ 1:N
        │        │
        ▼        ▼
┌──────────────────┐
│     devices      │
├──────────────────┤
│ • id             │
│ • device_model   │
│ • manufacturer   │
│ • year_of_       │
│   release        │
│ • operating_     │
│   system         │
└──────────────────┘
```

## Component Interaction Matrix

| Flutter Component | Calls | Backend Endpoint | Returns |
|-------------------|-------|------------------|---------|
| `RealGoogleAuth.signIn()` | → | `POST /auth/oauth-signin` | User + Token |
| `saveRecognizedDevice()` | → | `POST /device-recognition/save` | Device Passport ID |
| `DeviceProvider.loadDevices()` | → | `GET /device-passports` | List<DevicePassport> |
| `DeviceProvider.removeDevice()` | → | `DELETE /device-passports/{id}` | Success |
| `UserService.getCurrentUser()` | → | `GET /auth/user` | User data |

## Technology Stack

### Frontend (Flutter)
```
┌─────────────────────────────────────┐
│  Framework: Flutter 3.x             │
│  Language: Dart 3.x                 │
│  State: Provider                    │
│  Storage: SQLite (sqflite)          │
│  HTTP: http package                 │
│  AI: google_generative_ai           │
│  Camera: image_picker               │
│  Auth: google_sign_in               │
└─────────────────────────────────────┘
```

### Backend (Laravel)
```
┌─────────────────────────────────────┐
│  Framework: Laravel 10.x            │
│  Language: PHP 8.1+                 │
│  Auth: Laravel Sanctum              │
│  ORM: Eloquent                      │
│  Validation: Request Validation     │
│  CORS: laravel/cors                 │
│  API: RESTful JSON                  │
└─────────────────────────────────────┘
```

### Database (MySQL)
```
┌─────────────────────────────────────┐
│  RDBMS: MySQL 5.7+ / MariaDB        │
│  Charset: utf8mb4                   │
│  Engine: InnoDB                     │
│  Indexes: Optimized for queries     │
│  Migrations: Version controlled     │
└─────────────────────────────────────┘
```

## Security Architecture

```
┌────────────────────────────────────────────┐
│           Security Layers                   │
├────────────────────────────────────────────┤
│                                             │
│  1. Transport Layer                         │
│     • HTTPS/TLS encryption                  │
│     • Certificate validation                │
│                                             │
│  2. Authentication Layer                    │
│     • Laravel Sanctum tokens                │
│     • OAuth 2.0 (Google)                    │
│     • Password hashing (bcrypt)             │
│                                             │
│  3. Authorization Layer                     │
│     • Middleware guards                     │
│     • User ownership checks                 │
│     • API rate limiting                     │
│                                             │
│  4. Data Validation Layer                   │
│     • Request validation                    │
│     • Input sanitization                    │
│     • SQL injection prevention (ORM)        │
│                                             │
│  5. CORS Layer                              │
│     • Allowed origins                       │
│     • Credentials support                   │
│     • Method restrictions                   │
│                                             │
└────────────────────────────────────────────┘
```

## Deployment Architecture

### Development
```
┌─────────────────┐
│  Flutter App    │
│  localhost:*    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Laravel API    │
│  localhost:8000 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  MySQL          │
│  localhost:3306 │
└─────────────────┘
```

### Production (Example)
```
┌──────────────────┐
│  Mobile Apps     │
│  iOS/Android     │
└────────┬─────────┘
         │
         │ HTTPS
         ▼
┌──────────────────┐
│  Load Balancer   │
│  AWS ELB/ALB     │
└────────┬─────────┘
         │
         ├─────────────┬─────────────┐
         ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Laravel     │ │ Laravel     │ │ Laravel     │
│ Server 1    │ │ Server 2    │ │ Server 3    │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       └───────────────┼───────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  MySQL Cluster  │
              │  Master/Replica │
              └─────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  Redis Cache    │
              │  (optional)     │
              └─────────────────┘
```

## API Request/Response Flow

```
1. Client Request
   ┌────────────────────────────────┐
   │  POST /device-recognition/save │
   │  Headers:                       │
   │    Authorization: Bearer token  │
   │    Content-Type: application/  │
   │                  json           │
   │  Body: {...}                    │
   └────────────────┬───────────────┘
                    │
                    ▼
2. Laravel Middleware Stack
   ┌────────────────────────────────┐
   │  • HandleCors                   │
   │  • EnsureFrontendRequests       │
   │    AreStateful                  │
   │  • ThrottleRequests             │
   │  • SubstituteBindings           │
   │  • Authenticate (Sanctum)       │
   └────────────────┬───────────────┘
                    │
                    ▼
3. Controller
   ┌────────────────────────────────┐
   │  DeviceRecognitionController    │
   │  • Validate request             │
   │  • Process business logic       │
   │  • Call models                  │
   └────────────────┬───────────────┘
                    │
                    ▼
4. Models (Eloquent ORM)
   ┌────────────────────────────────┐
   │  • Device::create()             │
   │  • Diagnosis::create()          │
   │  • ValueEstimation::create()    │
   │  • DevicePassport::create()     │
   └────────────────┬───────────────┘
                    │
                    ▼
5. Database
   ┌────────────────────────────────┐
   │  MySQL INSERT queries           │
   │  • Transactions                 │
   │  • Foreign key checks           │
   │  • Indexes                      │
   └────────────────┬───────────────┘
                    │
                    ▼
6. Response
   ┌────────────────────────────────┐
   │  HTTP 201 Created               │
   │  {                              │
   │    "success": true,             │
   │    "message": "...",            │
   │    "devicePassportId": "123"    │
   │  }                              │
   └────────────────────────────────┘
```

## Scalability Considerations

### Horizontal Scaling
- Multiple Laravel instances behind load balancer
- Stateless API (Sanctum tokens)
- Database connection pooling

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize database queries
- Add Redis caching layer

### Database Optimization
- Proper indexing on foreign keys
- Query optimization (N+1 problem)
- Database replication (read replicas)

### Caching Strategy
```
┌──────────────────────────┐
│  Cache Layer (Redis)     │
├──────────────────────────┤
│  • User sessions         │
│  • Device listings       │
│  • AI responses          │
│  • API rate limits       │
└──────────────────────────┘
```

## Monitoring & Logging

```
┌─────────────────────────────────────┐
│  Application Logs                    │
│  • storage/logs/laravel.log          │
│  • Error tracking                    │
│  • Request/response logging          │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Monitoring Tools (Optional)         │
│  • Laravel Telescope                 │
│  • Sentry (error tracking)           │
│  • New Relic (APM)                   │
│  • DataDog (monitoring)              │
└─────────────────────────────────────┘
```

## Summary

This architecture provides:
- ✅ **Separation of Concerns**: Clear layers
- ✅ **Scalability**: Horizontal & vertical
- ✅ **Security**: Multiple layers
- ✅ **Maintainability**: Clean code structure
- ✅ **Flexibility**: Toggle backend on/off
- ✅ **Performance**: Optimized queries & caching
