# Laravel Backend Quick Setup Guide

## ⚠️ IMPORTANT: Installation Error?

If you see: `Could not open input file: artisan`

**Please follow [BACKEND_SETUP_FIXED.md](../BACKEND_SETUP_FIXED.md) instead.**

This file assumes Laravel is already installed. If you're starting fresh, use the fixed guide.

---

## Prerequisites

Before you begin, ensure you have:

- ✅ PHP 8.1 or higher
- ✅ Composer (PHP dependency manager)
- ✅ MySQL 5.7+ or PostgreSQL 10+

### Check Your Prerequisites

```bash
# Check PHP version (should be 8.1+)
php -v

# Check Composer
composer --version

# Check MySQL
mysql --version
```

## Fresh Installation (First Time Setup)

### Option 1: Use Automated Script

From the project root directory:
```bash
cd "f:\Downloads\MobileDev_AyoAyo"
install-backend.bat
```

### Option 2: Manual Installation

See [BACKEND_SETUP_FIXED.md](../BACKEND_SETUP_FIXED.md) for detailed manual steps.

---

## Quick Setup (If Laravel Already Installed)

### Step 1: Navigate to Backend Directory

```bash
cd "f:\Downloads\MobileDev_AyoAyo\backend"
```

### Step 2: Install Dependencies

```bash
composer install
```

### Step 3: Copy Environment File

```bash
# Windows
copy .env.example .env

# Mac/Linux
cp .env.example .env
```

### Step 4: Generate Application Key

```bash
php artisan key:generate
```

### Step 5: Configure Database

Open `.env` file and update these lines:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=ayoayo_db
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
```

### Step 6: Create Database

```bash
# Option 1: Using MySQL command line
mysql -u root -p -e "CREATE DATABASE ayoayo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Option 2: Using phpMyAdmin
# Go to http://localhost/phpmyadmin
# Click "New" and create database named "ayoayo_db"
```

### Step 7: Run Migrations

```bash
php artisan migrate
```

You should see output like:
```
Migration table created successfully.
Migrating: 2024_01_01_000001_create_users_table
Migrated:  2024_01_01_000001_create_users_table (45.67ms)
...
```

### Step 8: Start the Server

```bash
php artisan serve
```

You should see:
```
Starting Laravel development server: http://127.0.0.1:8000
```

### Step 9: Test the API

Open a new terminal and test:

```bash
curl http://localhost:8000/api/v1/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "AyoAyo API is running",
  "version": "1.0.0",
  "timestamp": "2024-..."
}
```

## Troubleshooting

### Issue: "php command not found"

**Solution**: Install PHP or add it to your PATH
- Windows: Download from https://windows.php.net/download/
- Mac: `brew install php@8.1`
- Linux: `sudo apt install php8.1`

### Issue: "composer command not found"

**Solution**: Install Composer from https://getcomposer.org/download/

### Issue: "Access denied for user"

**Solution**: Check MySQL credentials in `.env` file

### Issue: "SQLSTATE[HY000] [2002] Connection refused"

**Solution**: Ensure MySQL is running
```bash
# Windows (XAMPP)
Start XAMPP Control Panel → Start MySQL

# Mac
brew services start mysql

# Linux
sudo systemctl start mysql
```

### Issue: Port 8000 already in use

**Solution**: Use a different port
```bash
php artisan serve --port=8001
```

## Next Steps

After setup is complete:

1. ✅ Read [README.md](./README.md) for API documentation
2. ✅ Read [../LARAVEL_INTEGRATION_GUIDE.md](../LARAVEL_INTEGRATION_GUIDE.md) for Flutter integration
3. ✅ Test API endpoints using Postman or curl
4. ✅ Integrate with Flutter app

## Development Workflow

### Daily Workflow

```bash
# 1. Start the backend server
cd backend
php artisan serve

# 2. In a new terminal, watch logs
tail -f storage/logs/laravel.log

# 3. Run Flutter app
cd ..
flutter run
```

### Resetting Database

```bash
# Drop all tables and re-run migrations
php artisan migrate:fresh

# With seeders (if you add them later)
php artisan migrate:fresh --seed
```

### Checking Migration Status

```bash
php artisan migrate:status
```

## Project Structure

```
backend/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── Api/
│   │           ├── AuthController.php
│   │           ├── DeviceRecognitionController.php
│   │           └── DevicePassportController.php
│   └── Models/
│       ├── User.php
│       ├── Device.php
│       ├── DevicePassport.php
│       └── ...
├── database/
│   └── migrations/
│       ├── 2024_01_01_000001_create_users_table.php
│       ├── 2024_01_01_000002_create_devices_table.php
│       └── ...
├── routes/
│   └── api.php  (API endpoints)
├── config/
│   ├── cors.php
│   └── ...
├── .env  (Configuration)
└── composer.json  (Dependencies)
```

## Testing the Integration

### 1. Test Authentication

```bash
# Register a user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Test Device Recognition

```bash
# Save a recognized device (use token from registration)
curl -X POST http://localhost:8000/api/v1/device-recognition/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userId": "local_1234567890_abc123",
    "deviceModel": "iPhone 14 Pro",
    "manufacturer": "Apple",
    "yearOfRelease": 2022,
    "operatingSystem": "iOS",
    "confidence": 0.92,
    "analysisDetails": "Test device recognition",
    "imageUrls": []
  }'
```

### 3. Test Device Passport Retrieval

```bash
# Get device passports
curl -X GET "http://localhost:8000/api/v1/device-passports?userId=local_1234567890_abc123" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Production Deployment

When ready for production:

1. Update `.env`:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   ```

2. Optimize Laravel:
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

3. Deploy to server (AWS, DigitalOcean, etc.)

4. Set up SSL/HTTPS

5. Update Flutter app with production URL

## Support

For detailed API documentation, see [README.md](./README.md)

For Flutter integration, see [LARAVEL_INTEGRATION_GUIDE.md](../LARAVEL_INTEGRATION_GUIDE.md)
